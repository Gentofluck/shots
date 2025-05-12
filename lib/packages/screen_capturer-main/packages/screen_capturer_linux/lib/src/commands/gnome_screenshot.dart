import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

class GnomeScreenshot implements SystemScreenCapturer {
  @override
  String get executable => 'gnome-screenshot';

  static const _platform = MethodChannel('dev.leanflutter.plugins/screen_capturer');

  Future<bool> _isCommandAvailable(String command) async {
    final result = await ShellExecutor.global.exec('which', [command]);
    return result.exitCode == 0;
  }

  Future<void> _copyImageToClipboard(String imagePath) async {
    final isWlCopyAvailable = await _isCommandAvailable('wl-copy');
    final isXclipAvailable = await _isCommandAvailable('xclip');

    if (isWlCopyAvailable) {
      await ShellExecutor.global.exec('bash', [
        '-c',
        'wl-copy < "$imagePath"'
      ]);
    } else if (isXclipAvailable) {
      await ShellExecutor.global.exec('bash', [
        '-c',
        'xclip -selection clipboard -t image/png -i "$imagePath"'
      ]);
    } else {
      throw Exception('Neither wl-copy nor xclip is available');
    }
  }

  @override
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    final tempFile = '/tmp/shot_${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      await ShellExecutor.global.exec(
        'bash',
        [
          '-c',
          'gnome-screenshot -a -f "$tempFile"'
        ],
      );

      if (copyToClipboard) {
        await _copyImageToClipboard(tempFile);
      }

      final Uint8List? image = await _platform.invokeMethod<Uint8List>('readImageFromClipboard');

      return Uint8List.fromList(image ?? []);
    } catch (e) {
      print('Error capturing screenshot: $e');
      return Uint8List(0);
    }
  }
}

final gnomeScreenshot = GnomeScreenshot();