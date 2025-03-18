import 'dart:typed_data';

import 'package:screen_capturer_platform_interface/src/capture_mode.dart';

abstract mixin class SystemScreenCapturer {
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  });
}
