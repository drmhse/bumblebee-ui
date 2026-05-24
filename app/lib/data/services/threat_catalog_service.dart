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
  static const upstreamContentsApi =
      'https://api.github.com/repos/perplexityai/bumblebee/contents/threat_intel?ref=main';
  static const upstreamRawBase =
      'https://raw.githubusercontent.com/perplexityai/bumblebee/main/threat_intel/';

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
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final names = await _upstreamCatalogFiles(client);
      for (final name in names) {
        final uri = Uri.parse('$upstreamRawBase$name');
        final request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.userAgentHeader, 'Bumblebee Desktop');
        final response = await request.close().timeout(
          const Duration(seconds: 12),
        );
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

  Future<List<String>> _upstreamCatalogFiles(HttpClient client) async {
    final request = await client.getUrl(Uri.parse(upstreamContentsApi));
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'Bumblebee Desktop');
    final response = await request.close().timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return catalogFiles;
    final body = await utf8.decodeStream(response);
    final json = jsonDecode(body);
    if (json is! List) return catalogFiles;
    final names = <String>[];
    for (final item in json) {
      if (item is! Map) continue;
      if (item['type'] != 'file') continue;
      final name = (item['name'] ?? '').toString();
      if (name.endsWith('.json')) names.add(name);
    }
    names.sort();
    return names.isEmpty ? catalogFiles : names;
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
