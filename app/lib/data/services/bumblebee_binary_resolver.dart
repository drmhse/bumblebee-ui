import 'dart:io';

import 'package:flutter/services.dart';

import 'app_paths.dart';

class BumblebeeBinaryResolver {
  Future<String> resolve() async {
    final envPath = Platform.environment['BUMBLEBEE_BIN'];
    if (_isExecutable(envPath)) return envPath!;

    for (final candidate in _candidatePaths()) {
      if (_isExecutable(candidate)) return candidate;
    }
    final bundled = await _extractBundledAsset();
    if (bundled != null) return bundled;
    final pathCandidate = _findOnPath();
    if (pathCandidate != null) return pathCandidate;
    throw StateError(
      'Could not find bumblebee. Set BUMBLEBEE_BIN or place the binary next to the app.',
    );
  }

  List<String> _candidatePaths() {
    final cwd = Directory.current.path;
    final ext = Platform.isWindows ? '.exe' : '';
    return ['$cwd/../bumblebee$ext', '$cwd/bumblebee$ext'];
  }

  Future<String?> _extractBundledAsset() async {
    final assetPlatform = _platformAssetName();
    if (assetPlatform == null) return null;
    final ext = Platform.isWindows ? '.exe' : '';
    final assetPath = 'assets/bin/$assetPlatform/bumblebee$ext';
    try {
      final bytes = await rootBundle.load(assetPath);
      final support = await AppPaths().supportDir();
      final helperDir = Directory('${support.path}/bin/$assetPlatform');
      if (!helperDir.existsSync()) helperDir.createSync(recursive: true);
      final helper = File('${helperDir.path}/bumblebee$ext');
      await helper.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      if (!Platform.isWindows) {
        await Process.run('chmod', ['755', helper.path]);
      }
      return helper.path;
    } catch (_) {
      return null;
    }
  }

  String? _platformAssetName() {
    if (Platform.isMacOS && Platform.version.contains('arm64')) {
      return 'macos-arm64';
    }
    if (Platform.isMacOS) return 'macos-x64';
    if (Platform.isLinux) return 'linux-x64';
    if (Platform.isWindows) return 'windows-x64';
    return null;
  }

  String? _findOnPath() {
    final path = Platform.environment['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';
    final ext = Platform.isWindows ? '.exe' : '';
    for (final dir in path.split(separator)) {
      final candidate = '$dir/bumblebee$ext';
      if (_isExecutable(candidate)) return candidate;
    }
    return null;
  }

  bool _isExecutable(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    final file = File(path);
    if (!file.existsSync()) return false;
    if (_isAppExecutable(file.path)) return false;
    if (Platform.isWindows) return true;
    return file.statSync().mode & 0x49 != 0;
  }

  bool _isAppExecutable(String path) {
    final current = _normalizedPath(Platform.resolvedExecutable);
    final candidate = _normalizedPath(path);
    return candidate == current;
  }

  String _normalizedPath(String path) {
    try {
      final resolved = File(path).resolveSymbolicLinksSync();
      return Platform.isMacOS ? resolved.toLowerCase() : resolved;
    } catch (_) {
      final absolute = File(path).absolute.path;
      return Platform.isMacOS ? absolute.toLowerCase() : absolute;
    }
  }
}
