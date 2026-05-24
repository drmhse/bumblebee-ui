import 'dart:convert';
import 'dart:io';

class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    required this.newerReleaseAvailable,
    required this.compatibleAssetAvailable,
    required this.platformLabel,
    this.assetName,
    this.assetUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final bool newerReleaseAvailable;
  final bool compatibleAssetAvailable;
  final String platformLabel;
  final String? assetName;
  final String? assetUrl;

  bool get available => newerReleaseAvailable && compatibleAssetAvailable;
}

class UpdateService {
  static const latestReleaseApi =
      'https://api.github.com/repos/drmhse/bumblebee-ui/releases/latest';
  static const releasesUrl = 'https://github.com/drmhse/bumblebee-ui/releases';

  Future<UpdateInfo> check(String currentVersion) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(Uri.parse(latestReleaseApi));
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'Bumblebee Desktop');
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200) {
        throw StateError('GitHub returned HTTP ${response.statusCode}');
      }
      final body = await utf8.decodeStream(response);
      final json = jsonDecode(body);
      if (json is! Map) throw StateError('Unexpected GitHub response shape');
      final tag = (json['tag_name'] ?? '').toString();
      final url = (json['html_url'] ?? releasesUrl).toString();
      final latest = _cleanVersion(tag);
      final current = _cleanVersion(currentVersion);
      final asset = _selectCompatibleAsset(json['assets']);
      final newer = isNewerVersion(latest, current);
      return UpdateInfo(
        currentVersion: current,
        latestVersion: latest.isEmpty ? tag : latest,
        releaseUrl: url.isEmpty ? releasesUrl : url,
        newerReleaseAvailable: newer,
        compatibleAssetAvailable: asset != null,
        platformLabel: currentPlatformLabel(),
        assetName: asset?.name,
        assetUrl: asset?.url,
      );
    } finally {
      client.close(force: true);
    }
  }

  static bool isNewerVersion(String latest, String current) {
    return _compareVersions(_cleanVersion(latest), _cleanVersion(current)) > 0;
  }

  static String currentPlatformLabel() {
    if (Platform.isMacOS && _isArm64()) return 'Apple Silicon Mac';
    if (Platform.isMacOS) return 'Intel Mac';
    if (Platform.isLinux) return 'Linux x64';
    if (Platform.isWindows) return 'Windows x64';
    return 'this platform';
  }

  static UpdateAsset? compatibleAssetFromReleaseAssets(Object? value) {
    return _selectCompatibleAsset(value);
  }

  static String _cleanVersion(String value) {
    final withoutBuild = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return withoutBuild.split('+').first;
  }

  static int _compareVersions(String a, String b) {
    final left = _parts(a);
    final right = _parts(b);
    for (var i = 0; i < 3; i++) {
      final diff = left[i].compareTo(right[i]);
      if (diff != 0) return diff;
    }
    return 0;
  }

  static List<int> _parts(String value) {
    final parts = value.split('.');
    return List.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index].replaceAll(RegExp(r'[^0-9].*$'), '')) ??
          0;
    });
  }

  static UpdateAsset? _selectCompatibleAsset(Object? value) {
    if (value is! List) return null;
    final pattern = _assetPattern();
    if (pattern == null) return null;
    for (final item in value) {
      if (item is! Map) continue;
      final name = (item['name'] ?? '').toString();
      final url = (item['browser_download_url'] ?? '').toString();
      if (name.isEmpty || url.isEmpty) continue;
      if (pattern.hasMatch(name.toLowerCase())) {
        return UpdateAsset(name: name, url: url);
      }
    }
    return null;
  }

  static RegExp? _assetPattern() {
    if (Platform.isMacOS && _isArm64()) {
      return RegExp(r'(arm64|aarch64).*\.dmg$');
    }
    if (Platform.isMacOS) {
      return RegExp(r'(x64|x86_64|intel).*\.dmg$');
    }
    if (Platform.isLinux) {
      return RegExp(r'(linux).*(x64|x86_64|amd64).*\.(tar\.gz|appimage|deb)$');
    }
    if (Platform.isWindows) {
      return RegExp(r'(windows|win).*(x64|x86_64|amd64).*\.(exe|msix|zip)$');
    }
    return null;
  }

  static bool _isArm64() {
    return Platform.version.toLowerCase().contains('arm64');
  }
}

class UpdateAsset {
  const UpdateAsset({required this.name, required this.url});

  final String name;
  final String url;
}
