import 'dart:convert';

import '../models/bumblebee_record.dart';
import 'app_paths.dart';

class ScanHistoryStore {
  ScanHistoryStore(this._paths);

  final AppPaths _paths;

  Future<List<ScanResult>> load() async {
    final file = await _paths.historyFile();
    if (!file.existsSync()) return [];
    return _parseHistoryJson(await file.readAsString());
  }

  Future<void> save(List<ScanResult> results) async {
    final file = await _paths.historyFile();
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      encoder.convert(results.map((e) => e.toJson()).toList()),
    );
  }
}

List<ScanResult> _parseHistoryJson(String text) {
  final value = jsonDecode(text);
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => ScanResult.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
