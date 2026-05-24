import 'package:bumblebee_desktop/data/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('semantic version comparison ignores build metadata', () {
    expect(UpdateService.isNewerVersion('v1.0.1', '1.0.0+4'), isTrue);
    expect(UpdateService.isNewerVersion('v1.0.0', '1.0.0+1'), isFalse);
    expect(UpdateService.isNewerVersion('v1.0.0-beta.1', '1.0.0'), isFalse);
  });

  test('compatible release asset is selected for current platform', () {
    final asset = UpdateService.compatibleAssetFromReleaseAssets([
      {
        'name': 'Bumblebee-1.0.1-2-arm64.dmg',
        'browser_download_url':
            'https://github.com/drmhse/bumblebee-ui/releases/download/v1.0.1/Bumblebee-1.0.1-2-arm64.dmg',
        'type': 'file',
      },
      {
        'name': 'Bumblebee-1.0.1-2-x64.dmg',
        'browser_download_url':
            'https://github.com/drmhse/bumblebee-ui/releases/download/v1.0.1/Bumblebee-1.0.1-2-x64.dmg',
        'type': 'file',
      },
      {
        'name': 'Bumblebee-1.0.1-2-linux-x64.tar.gz',
        'browser_download_url':
            'https://github.com/drmhse/bumblebee-ui/releases/download/v1.0.1/Bumblebee-1.0.1-2-linux-x64.tar.gz',
        'type': 'file',
      },
      {
        'name': 'Bumblebee-1.0.1-2-windows-x64.exe',
        'browser_download_url':
            'https://github.com/drmhse/bumblebee-ui/releases/download/v1.0.1/Bumblebee-1.0.1-2-windows-x64.exe',
        'type': 'file',
      },
    ]);

    expect(asset, isNotNull);
    expect(asset!.name, startsWith('Bumblebee-1.0.1-2-'));
  });
}
