class BumblebeeRecord {
  BumblebeeRecord(this.type, this.payload);

  final String type;
  final Map<String, dynamic> payload;

  String stringValue(String key) => (payload[key] ?? '').toString();
  int intValue(String key) => _asInt(payload[key]);

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ScanResult {
  ScanResult({
    required this.id,
    required this.startedAt,
    this.completedAt,
    this.packages = const [],
    this.findings = const [],
    this.diagnostics = const [],
    this.summary,
    this.exitCode = 0,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<BumblebeeRecord> packages;
  final List<BumblebeeRecord> findings;
  final List<BumblebeeRecord> diagnostics;
  final BumblebeeRecord? summary;
  final int exitCode;

  String get status {
    final value = summary?.stringValue('status');
    if (value != null && value.isNotEmpty) return value;
    if (completedAt == null) return 'running';
    if (summary == null) return exitCode == 0 ? 'missing_summary' : 'error';
    return exitCode == 0 ? 'complete' : 'error';
  }

  bool get hasCompleteSummary =>
      summary != null && status == 'complete' && exitCode == 0;

  String get runId => summary?.stringValue('run_id') ?? id;
  String get profile => summary?.stringValue('profile') ?? 'baseline';
  int get packageCount => _summaryCount('package', packages.length);
  int get packageRecordsSuppressed =>
      summary?.intValue('package_records_suppressed') ?? 0;
  int get packageRecordsChecked => packageCount + packageRecordsSuppressed;
  int get findingsCount =>
      summary?.intValue('findings_emitted') ?? findings.length;
  int get diagnosticsCount =>
      summary?.intValue('diagnostics_count') ?? diagnostics.length;
  int get filesConsidered => summary?.intValue('files_considered') ?? 0;
  int get durationMs => summary?.intValue('duration_ms') ?? 0;

  String get endpoint {
    final value = summary?.payload['endpoint'];
    if (value is Map) return (value['hostname'] ?? 'unknown').toString();
    return 'unknown';
  }

  List<Map<String, dynamic>> get roots {
    final value = summary?.payload['roots'];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  int _summaryCount(String key, int fallback) {
    final counts = summary?.payload['counts'];
    if (counts is Map && counts[key] is num) {
      return (counts[key] as num).toInt();
    }
    return summary?.intValue('package_records_emitted') ?? fallback;
  }

  ScanResult copyWith({
    DateTime? completedAt,
    List<BumblebeeRecord>? packages,
    List<BumblebeeRecord>? findings,
    List<BumblebeeRecord>? diagnostics,
    BumblebeeRecord? summary,
    int? exitCode,
  }) {
    return ScanResult(
      id: id,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      packages: packages ?? this.packages,
      findings: findings ?? this.findings,
      diagnostics: diagnostics ?? this.diagnostics,
      summary: summary ?? this.summary,
      exitCode: exitCode ?? this.exitCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'packages': packages.map(_recordToJson).toList(),
      'findings': findings.map(_recordToJson).toList(),
      'diagnostics': diagnostics.map(_recordToJson).toList(),
      'summary': summary == null ? null : _recordToJson(summary!),
      'exitCode': exitCode,
    };
  }

  static ScanResult fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'].toString(),
      startedAt:
          DateTime.tryParse(json['startedAt'].toString()) ?? DateTime.now(),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      packages: _records(json['packages']),
      findings: _records(json['findings']),
      diagnostics: _records(json['diagnostics']),
      summary: _record(json['summary']),
      exitCode: BumblebeeRecord._asInt(json['exitCode']),
    );
  }

  static Map<String, dynamic> _recordToJson(BumblebeeRecord record) {
    return {'type': record.type, 'payload': record.payload};
  }

  static List<BumblebeeRecord> _records(Object? value) {
    if (value is! List) return const [];
    return value.map(_record).whereType<BumblebeeRecord>().toList();
  }

  static BumblebeeRecord? _record(Object? value) {
    if (value is! Map) return null;
    final payload = Map<String, dynamic>.from(
      value['payload'] as Map? ?? value,
    );
    return BumblebeeRecord(
      (value['type'] ?? payload['record_type'] ?? '').toString(),
      payload,
    );
  }
}
