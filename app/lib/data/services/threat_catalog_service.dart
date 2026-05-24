import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_paths.dart';

class ThreatCatalogInfo {
  const ThreatCatalogInfo({
    required this.name,
    required this.path,
    required this.entries,
    required this.modifiedAt,
  });

  final String name;
  final String path;
  final int entries;
  final DateTime modifiedAt;
}

class ThreatCatalogService {
  ThreatCatalogService(this._paths);

  final AppPaths _paths;

  static const catalogFiles = [
    'mini-shai-hulud.json',
    'laravel-lang-2026-05-23.json',
    'nx-console-vscode-2026-05-18.json',
    'antv-mini-shai-hulud.json',
    'node-ipc-credential-stealer.json',
    'shopsprint-decimal-typosquat.json',
    'gemstuffer.json',
  ];

  Future<Directory> ensureCatalogs() async {
    final dir = await _paths.catalogDir();
    for (final fileName in catalogFiles) {
      final file = File('${dir.path}/$fileName');
      if (file.existsSync()) continue;
      try {
        final text = await rootBundle.loadString(
          'assets/threat_intel/$fileName',
        );
        await file.writeAsString(text);
      } on FlutterError {
        // Older downloaded bundles may not include every upstream catalog yet.
      }
    }
    return dir;
  }

  Future<List<ThreatCatalogInfo>> listCatalogs() async {
    final dir = await ensureCatalogs();
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    return [for (final file in files) await _infoFor(file)];
  }

  Future<void> importCatalog(File source) async {
    final dir = await ensureCatalogs();
    final target = File('${dir.path}/${source.uri.pathSegments.last}');
    await source.copy(target.path);
  }

  Future<int> syncFromUpstream() async {
    final dir = await ensureCatalogs();
    var updated = 0;
    final client = HttpClient();
    try {
      for (final name in catalogFiles) {
        final uri = Uri.parse(
          'https://raw.githubusercontent.com/perplexityai/bumblebee/main/threat_intel/$name',
        );
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != 200) continue;
        final text = await utf8.decodeStream(response);
        await File('${dir.path}/$name').writeAsString(text);
        updated++;
      }
    } finally {
      client.close(force: true);
    }
    return updated;
  }

  Future<ThreatCatalogInfo> _infoFor(File file) async {
    final stat = await file.stat();
    var entries = 0;
    try {
      final json = jsonDecode(await file.readAsString());
      final value = json is Map ? json['entries'] : null;
      if (value is List) entries = value.length;
    } catch (_) {
      entries = 0;
    }
    return ThreatCatalogInfo(
      name: file.uri.pathSegments.last,
      path: file.path,
      entries: entries,
      modifiedAt: stat.modified,
    );
  }
}
