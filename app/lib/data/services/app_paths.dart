import 'dart:io';

class AppPaths {
  static const bundleIdentifier = 'bumblebee.drmhse.com';

  Future<Directory> supportDir() async {
    final base = Directory(_applicationSupportPath());
    final dir = Directory('${base.path}/Bumblebee');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<Directory> catalogDir() async {
    final dir = Directory('${(await supportDir()).path}/threat_intel');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File> historyFile() async {
    return File('${(await supportDir()).path}/scan_history.json');
  }

  static String _applicationSupportPath() {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home/Library/Application Support/$bundleIdentifier';
      }
    }
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return '$appData/$bundleIdentifier';
      }
    }
    final xdgDataHome = Platform.environment['XDG_DATA_HOME'];
    if (xdgDataHome != null && xdgDataHome.isNotEmpty) {
      return '$xdgDataHome/$bundleIdentifier';
    }
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/.local/share/$bundleIdentifier';
    }
    return '${Directory.current.path}/$bundleIdentifier';
  }
}
