import 'package:screen_capturer/screen_capturer.dart';
import 'package:pasteboard/pasteboard.dart';
import 'dart:typed_data';

class ScreenshotService {
	static Future<Uint8List?> captureScreen() async {
		try {
			await screenCapturer.capture(
				mode: CaptureMode.region, 
				copyToClipboard: true, 
			);

			return Pasteboard.image; 
		} catch (e) {
			return null;
		}
	}
}
