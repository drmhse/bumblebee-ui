import 'dart:io';

import 'package:bumblebee_desktop/data/models/scan_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expands current user home shorthand in scan roots', () {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) return;

    const config = ScanConfig(roots: ['~', '~/Developer', '/tmp']);

    expect(config.normalizedRoots, [home, '$home/Developer', '/tmp']);
  });
}
