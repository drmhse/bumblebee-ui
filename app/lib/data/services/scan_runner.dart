import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/bumblebee_record.dart';
import '../models/scan_config.dart';
import '../models/scan_scope.dart';
import 'bumblebee_binary_resolver.dart';

class ScanRunner {
  ScanRunner(this._resolver);

  final BumblebeeBinaryResolver _resolver;

  Future<ScanScope> resolveScope(ScanConfig config) async {
    _validateExplicitRoots(config);
    final binary = await _resolver.resolve();
    final process = await Process.run(binary, _scopeArgs(config));
    final stderr = process.stderr.toString().trim();
    if (process.exitCode != 0) {
      throw StateError(
        stderr.isEmpty ? 'Could not verify scan scope.' : stderr,
      );
    }
    final roots = process.stdout
        .toString()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_parseRoot)
        .whereType<ScanRoot>()
        .toList();
    if (roots.isEmpty) {
      throw StateError('Scope verification found no scannable roots.');
    }
    return ScanScope(
      profile: config.profile,
      roots: List.unmodifiable(roots),
      notes: List.unmodifiable(
        stderr.split('\n').where((line) => line.trim().isNotEmpty),
      ),
      verifiedAt: DateTime.now(),
    );
  }

  Future<ScanResult> run({
    required ScanConfig config,
    required Directory catalogDir,
    void Function(ScanResult result)? onUpdate,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    var result = ScanResult(id: id, startedAt: DateTime.now());
    final packages = <BumblebeeRecord>[];
    final findings = <BumblebeeRecord>[];
    final diagnostics = <BumblebeeRecord>[];
    BumblebeeRecord? summary;

    _validateExplicitRoots(config);
    final binary = await _resolver.resolve();
    final process = await Process.start(binary, _args(config, catalogDir.path));

    void publish() {
      result = result.copyWith(
        packages: List.unmodifiable(packages),
        findings: List.unmodifiable(findings),
        diagnostics: List.unmodifiable(diagnostics),
        summary: summary,
      );
      onUpdate?.call(result);
    }

    final outDone = _readLines(process.stdout, (line) {
      final record = _parse(line);
      if (record == null) return;
      switch (record.type) {
        case 'package':
          packages.add(record);
        case 'finding':
          findings.add(record);
        case 'scan_summary':
          summary = record;
      }
      publish();
    });
    final errDone = _readLines(process.stderr, (line) {
      final record = _parse(line);
      if (record != null) diagnostics.add(record);
      publish();
    });

    final exitCode = await process.exitCode;
    await Future.wait([outDone, errDone]);
    return result.copyWith(
      completedAt: DateTime.now(),
      packages: List.unmodifiable(packages),
      findings: List.unmodifiable(findings),
      diagnostics: List.unmodifiable(diagnostics),
      summary: summary,
      exitCode: exitCode,
    );
  }

  List<String> _args(ScanConfig config, String catalogPath) {
    final args = [
      'scan',
      '--profile',
      config.profileValue,
      '--exposure-catalog',
      catalogPath,
    ];
    if (config.findingsOnly) args.add('--findings-only');
    for (final root in config.normalizedRoots) {
      args.addAll(['--root', root]);
    }
    for (final ecosystem in config.ecosystems) {
      args.addAll(['--ecosystem', ecosystem]);
    }
    return args;
  }

  List<String> _scopeArgs(ScanConfig config) {
    final args = ['roots', '--profile', config.profileValue];
    for (final root in config.normalizedRoots) {
      args.addAll(['--root', root]);
    }
    return args;
  }

  Future<void> _readLines(
    Stream<List<int>> stream,
    void Function(String) onLine,
  ) {
    return stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(onLine);
  }

  BumblebeeRecord? _parse(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final json = jsonDecode(line);
      if (json is! Map) return null;
      final payload = Map<String, dynamic>.from(json);
      return BumblebeeRecord(
        (payload['record_type'] ?? '').toString(),
        payload,
      );
    } catch (_) {
      return null;
    }
  }

  ScanRoot? _parseRoot(String line) {
    final tab = line.indexOf('\t');
    if (tab <= 0 || tab == line.length - 1) return null;
    return ScanRoot(
      kind: line.substring(0, tab),
      path: line.substring(tab + 1),
    );
  }

  void _validateExplicitRoots(ScanConfig config) {
    for (final root in config.normalizedRoots) {
      if (!Directory(root).existsSync()) {
        throw StateError('Scan root does not exist: $root');
      }
    }
  }
}
