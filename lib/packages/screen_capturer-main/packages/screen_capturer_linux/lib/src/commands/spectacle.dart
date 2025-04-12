import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

final Map<CaptureMode, List<String>> _knownCaptureModeArgs = {
  CaptureMode.region: ['-r'],
  CaptureMode.screen: ['-f'],
  CaptureMode.window: ['-a'],
};

class _Spectacle extends Command with SystemScreenCapturer {
  @override
  String get executable {
    return 'spectacle';
  }

  @override
  Future<void> install() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    // Строим аргументы для команды spectacle
    List<String> args = [
      '-b', // Для захвата в фоновом режиме
      '-n', // Без окна (по умолчанию)
      ..._knownCaptureModeArgs[mode]!,
      ...(copyToClipboard ? ['-c'] : []),
      ...(imagePath != null ? ['-o', imagePath] : []),
    ];

    // Выполняем команду для захвата экрана
    final result = await ShellExecutor.global.exec(executable, args);
    
    if (result.exitCode != 0) {
      throw Exception('Error while taking screenshot: ${result.stderr}');
    }

    // После захвата экрана копируем изображение в буфер обмена, если указано
    if (copyToClipboard) {
      await _copyToClipboard();
    }

    // Возвращаем результат в виде Uint8List
    return Uint8List.fromList(result.stdout);
  }

  // Функция для копирования изображения в буфер обмена
  Future<void> _copyToClipboard() async {
    try {
      // Используем xclip для копирования в буфер обмена
      final result = await ShellExecutor.global.exec(
        'xclip',
        ['-selection', 'clipboard', '-t', 'image/png', '-i'],  // Пример для xclip
      );

      if (result.exitCode != 0) {
        throw Exception('Error copying to clipboard: ${result.stderr}');
      }
    } catch (e) {
      print('Error while copying image to clipboard: $e');
    }
  }
}

// Экземпляр для использования в коде
final spectacle = _Spectacle();
