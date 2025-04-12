import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';
import 'package:flutter/widgets.dart';

final Map<CaptureMode, List<String>> _knownCaptureModeArgs = {
  CaptureMode.region: [''],
  CaptureMode.screen: ['-f'],
  CaptureMode.window: ['--dograb'],
};

class _Deepin extends Command with SystemScreenCapturer {
  @override
  String get executable {
    return 'deepin-screen-recorder';
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
    // Строим аргументы для команды deepin-screen-recorder
    List<String> args = [
      ..._knownCaptureModeArgs[mode]!,
      ...(imagePath != null ? ['-s', imagePath] : []),
      ...(silent ? ['-n'] : []),
    ];

    // Выполняем команду для захвата экрана
    final result = await ShellExecutor.global.exec(executable, args);
    
    if (result.exitCode != 0) {
      throw Exception('Error while taking screenshot: ${result.stderr}');
    }

    // После захвата экрана копируем изображение в буфер обмена
    if (copyToClipboard) {
      await _copyToClipboard();
    }

    // Возвращаем результат в виде Uint8List
    return Uint8List.fromList(result.stdout);
  }

  // Функция для копирования изображения в буфер обмена
  Future<void> _copyToClipboard() async {
    try {
      // Здесь будет ваш код для копирования изображения в буфер обмена
      // Примерный код может выглядеть так, как в случае с gnome-screenshot, но для deepin нужно будет найти соответствующие команды
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

// Экземпляр deepinScreenRecorder
final deepinScreenRecorder = _Deepin();
