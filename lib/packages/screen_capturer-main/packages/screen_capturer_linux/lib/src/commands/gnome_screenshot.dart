import 'dart:typed_data';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

class GnomeScreenshot implements SystemScreenCapturer {
  @override
  String get executable => 'gnome-screenshot';

  @override
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    List<String> args = [
      ...(copyToClipboard ? ['-c'] : []),
      ...(imagePath != null ? ['-f', imagePath] : []),
    ];

    final result = await ShellExecutor.global.exec(executable, args);
    if (result.exitCode != 0) {
      throw Exception('Error while taking screenshot: ${result.stderr}');
    }

    return Uint8List.fromList(result.stdout);
  }
}

// Создаем экземпляр GnomeScreenshot
final gnomeScreenshot = GnomeScreenshot();
