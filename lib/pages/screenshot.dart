import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../api/client.dart'; 

class ScreenshotPage extends StatelessWidget {
	final String? screenshotPath;
	final ShotsClient shotsClient;  

	ScreenshotPage({this.screenshotPath, required this.shotsClient});

	Future<void> uploadScreenshot() async {
		if (screenshotPath == null) return;

		final fileBytes = await File(screenshotPath!).readAsBytes();

		final response = await shotsClient.uploadImage(fileBytes);

		if (response.isNotEmpty && response != 'ERROR') {
			await Clipboard.setData(ClipboardData(text: response));
		} else {
			print('Ошибка при отправке скриншота');
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Screenshot')),
			body: Center(
				child: screenshotPath == null
				? const Text('Нет скриншота.')
				: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Image.file(File(screenshotPath!)),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: uploadScreenshot,
							child: const Text('Отправить на сервер'),
						),
					],
				),
			),
		);
	}
}
