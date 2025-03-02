import 'package:screen_capturer/screen_capturer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart'; 

class ScreenshotService {
	static Future<String?> captureScreen() async {
		try {
			String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
			final directory = await getApplicationDocumentsDirectory();
			final filePath = '${directory.path}/screenshot_$timestamp.png';

			CapturedData? capturedData = await screenCapturer.capture(
				mode: CaptureMode.region, 
				imagePath: filePath, 
				copyToClipboard: true, 
			);

			if (capturedData != null) {
				return filePath; 
			} else {
				return null;
			}
		} catch (e) {
			return null;
		}
	}
}
