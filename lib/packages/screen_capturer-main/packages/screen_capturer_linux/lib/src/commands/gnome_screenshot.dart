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
    // Генерируем уникальное имя временного файла
    final tempFile = '/tmp/shot_${DateTime.now().millisecondsSinceEpoch}.png';
    
    try {
      // Выполняем команду для создания скриншота и копирования в буфер
      await ShellExecutor.global.exec(
        'bash',
        [
          '-c',
          'gnome-screenshot -a -f "$tempFile" && wl-copy < "$tempFile" && rm "$tempFile"'
        ],
      );

      // Получаем изображение из буфера обмена
      final Uint8List? image = await _platform.invokeMethod<Uint8List>('readImageFromClipboard');

      return Uint8List.fromList(image ?? []);
    } catch (e) {
      print('Error capturing screenshot: $e');
      return Uint8List(0);
    }
  }
}

// Создаем экземпляр GnomeScreenshot
final gnomeScreenshot = GnomeScreenshot();