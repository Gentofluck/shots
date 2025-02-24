import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'screenshot_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScreenshotController screenshotController = ScreenshotController();
  String? savedPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screenshot App')),
      body: Screenshot(  // Оборачиваем весь Scaffold в Screenshot
        controller: screenshotController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.blueAccent,
                child: const Text(
                  'Нажмите кнопку ниже, чтобы сделать скриншот!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String path = await ScreenshotService.captureAndSave(screenshotController);
          setState(() {
            savedPath = path;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Скриншот сохранен: $savedPath')),
          );
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
