import 'dart:typed_data';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';
import 'package:flutter/services.dart';

class GnomeScreenshot implements SystemScreenCapturer {
  @override
  String get executable => 'gnome-screenshot';

  static const _platform = MethodChannel('dev.leanflutter.plugins/screen_capturer');

  @override
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    List<String> args = ['-c', '-a'];

    await ShellExecutor.global.exec(executable, args);

    final Uint8List? image = await _platform.invokeMethod<Uint8List>('readImageFromClipboard');

    return Uint8List.fromList(image ?? []);
  }
}

// Создаем экземпляр GnomeScreenshot
final gnomeScreenshot = GnomeScreenshot();
