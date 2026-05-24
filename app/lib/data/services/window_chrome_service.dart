import 'dart:io';

import 'package:flutter/services.dart';

class WindowChromeService {
  const WindowChromeService._();

  static const MethodChannel _channel = MethodChannel(
    'bumblebee/window_chrome',
  );

  static Future<void> performTitlebarDoubleClick() async {
    if (!Platform.isMacOS) return;
    try {
      await _channel.invokeMethod<void>('performTitlebarDoubleClick');
    } on MissingPluginException {
      return;
    }
  }
}
