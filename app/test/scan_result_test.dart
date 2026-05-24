import 'package:bumblebee_desktop/data/models/bumblebee_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('complete summary is required for authoritative scan result', () {
    final result = ScanResult(
      id: 'local',
      startedAt: DateTime(2026),
      completedAt: DateTime(2026, 1, 1, 0, 0, 1),
      packages: [
        BumblebeeRecord('package', {
          'record_type': 'package',
          'package_name': 'safe',
        }),
      ],
      summary: BumblebeeRecord('scan_summary', {
        'record_type': 'scan_summary',
        'status': 'partial',
        'counts': {'package': 1, 'finding': 0},
        'findings_emitted': 0,
      }),
      exitCode: 1,
    );

    expect(result.status, 'partial');
    expect(result.hasCompleteSummary, isFalse);
    expect(result.packageRecordsChecked, 1);
  });

  test('findings-only summary counts suppressed packages as checked', () {
    final result = ScanResult(
      id: 'local',
      startedAt: DateTime(2026),
      summary: BumblebeeRecord('scan_summary', {
        'record_type': 'scan_summary',
        'status': 'complete',
        'counts': {'package': 0, 'finding': 3},
        'package_records_emitted': 0,
        'package_records_suppressed': 3,
        'findings_emitted': 3,
      }),
    );

    expect(result.hasCompleteSummary, isTrue);
    expect(result.packageCount, 0);
    expect(result.packageRecordsSuppressed, 3);
    expect(result.packageRecordsChecked, 3);
    expect(result.findingsCount, 3);
  });
}
