import 'dart:io';

enum ScanProfile { baseline, project, deep }

class ScanConfig {
  const ScanConfig({
    this.profile = ScanProfile.baseline,
    this.roots = const [],
    this.ecosystems = const [],
    this.findingsOnly = false,
  });

  final ScanProfile profile;
  final List<String> roots;
  final List<String> ecosystems;
  final bool findingsOnly;

  String get profileValue => profile.name;

  List<String> get normalizedRoots {
    return roots
        .map((root) => _normalizeRoot(root))
        .where((root) => root.isNotEmpty)
        .toList();
  }

  ScanConfig copyWith({
    ScanProfile? profile,
    List<String>? roots,
    List<String>? ecosystems,
    bool? findingsOnly,
  }) {
    return ScanConfig(
      profile: profile ?? this.profile,
      roots: roots ?? this.roots,
      ecosystems: ecosystems ?? this.ecosystems,
      findingsOnly: findingsOnly ?? this.findingsOnly,
    );
  }

  static String _normalizeRoot(String value) {
    final trimmed = value.trim();
    if (trimmed == '~') return Platform.environment['HOME'] ?? trimmed;
    if (trimmed.startsWith('~/')) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home/${trimmed.substring(2)}';
      }
    }
    return trimmed;
  }
}
