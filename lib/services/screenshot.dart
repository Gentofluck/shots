import 'package:screen_capturer/screen_capturer.dart';
import 'dart:typed_data';

class ScreenshotService {
  static bool isCaptured = false;
	static Future<Uint8List?> captureScreen() async {
    if (isCaptured) return null;
    isCaptured = true;
		try {
			return await screenCapturer.capture(
				mode: CaptureMode.region, 
				copyToClipboard: true, 
			);
		} catch (e) {
			return null;
		}
    finally {
      isCaptured = false;
    }
	}
}
