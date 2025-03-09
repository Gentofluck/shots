import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/client.dart';

class ScreenshotPage extends StatefulWidget {
  final Uint8List? screenshot;
  final ShotsClient shotsClient;

  ScreenshotPage({this.screenshot, required this.shotsClient});

  @override
  _ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  bool _isUploaded = false;

  @override
  void didUpdateWidget(covariant ScreenshotPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.screenshot != oldWidget.screenshot) {
      setState(() {
        _isUploaded = false; 
      });
    }
  }

  Future<void> uploadScreenshot() async {
    if (widget.screenshot == null) return;

    final response = await widget.shotsClient.uploadImage(widget.screenshot!);

    if (response.isNotEmpty && response != 'ERROR') {
      await Clipboard.setData(ClipboardData(text: response));
      setState(() {
        _isUploaded = true;
      });
    } else {
      print('Ошибка при отправке скриншота');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EFEF),
      body: Center(
        child: widget.screenshot == null
            ? const Text(
                'Фото не сделано',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : _isUploaded
                ? const Text(
                    'Фото отправлено и скопировано в буфер',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.memory(
                          widget.screenshot!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          uploadScreenshot();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4AA37C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        ),
                        child: Text(
                          'Отправить на сервер',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
					const SizedBox(height: 20),

                ],
        ),
      ),
    );
  }
}
