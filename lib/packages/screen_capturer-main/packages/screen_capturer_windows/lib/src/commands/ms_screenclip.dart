import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'dart:typed_data';

class _MsScreenclip with SystemScreenCapturer {
  @override
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
      final Uint8List Image = await ScreenCapturerPlatform.instance.captureScreen(
        imagePath: '',
      );

      return Image;
  }
}

final msScreenclip = _MsScreenclip();
