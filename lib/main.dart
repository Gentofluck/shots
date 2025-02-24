import 'package:flutter/material.dart';
import 'screenshot_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screenshot App"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Вызов метода для захвата экрана
            await ScreenshotService.captureScreen();
          },
          child: const Text("Сделать скриншот"),
        ),
      ),
    );
  }
}
