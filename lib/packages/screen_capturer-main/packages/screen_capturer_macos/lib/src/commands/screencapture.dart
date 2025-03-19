import 'dart:io';
import 'dart:typed_data';

import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

final Map<CaptureMode, List<String>> _knownCaptureModeArgs = {
  CaptureMode.region: ['-i', '-r'],
  CaptureMode.screen: ['-C'],
  CaptureMode.window: ['-i', '-w'],
};

class _ScreenCapture extends Command with SystemScreenCapturer {
  @override
  String get executable {
    return '/usr/sbin/screencapture';
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
  }) async { // Добавляем async
    await exec( // Ожидаем выполнение команды
      [
        ..._knownCaptureModeArgs[mode]!,
        ...(copyToClipboard ? ['-c'] : []),
        ...(silent ? ['-x'] : []),
        ...(imagePath != null ? [imagePath] : []),
      ],
    );
    
    final result = await ScreenCapturerPlatform.instance.readImageFromClipboard();

    if (result == null) {
      return Uint8List(0);
    }

    return result;
  }
}

final screencapture = _ScreenCapture();
