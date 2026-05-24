import 'scan_config.dart';

class ScanRoot {
  const ScanRoot({required this.kind, required this.path});

  final String kind;
  final String path;

  String get label {
    if (kind == 'unknown') return 'explicit_root';
    return kind;
  }
}

class ScanScope {
  const ScanScope({
    required this.profile,
    required this.roots,
    required this.notes,
    required this.verifiedAt,
  });

  final ScanProfile profile;
  final List<ScanRoot> roots;
  final List<String> notes;
  final DateTime verifiedAt;

  bool matches(ScanConfig config) {
    if (profile != config.profile) return false;
    if (profile != ScanProfile.deep) return true;
    final expected = config.normalizedRoots;
    if (expected.length != roots.length) return false;
    final actual = roots.map((root) => root.path).toSet();
    return expected.every(actual.contains);
  }
}
