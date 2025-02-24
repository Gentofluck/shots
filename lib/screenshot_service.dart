import 'package:screen_capturer/screen_capturer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ScreenshotService {
  // Метод для захвата экрана
  static Future<void> captureScreen() async {
    try {
      // Получаем директорию для сохранения
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/screenshot.png'; // Путь для сохранения скриншота

      // Запуск захвата экрана в режиме области (region), можно использовать CaptureMode.screen для захвата всего экрана
      CapturedData? capturedData = await screenCapturer.capture(
        mode: CaptureMode.region, // Можно использовать CaptureMode.screen для захвата всего экрана
        imagePath: filePath, // Указали путь для сохранения
        copyToClipboard: true, // Копировать в буфер обмена
      );

      if (capturedData != null) {
        print("Скриншот успешно сделан!");
        print("Сохранено в: $filePath"); // Выводим путь к файлу
      } else {
        print("Не удалось сделать скриншот");
      }
    } catch (e) {
      print("Ошибка: $e");
    }
  }
}
