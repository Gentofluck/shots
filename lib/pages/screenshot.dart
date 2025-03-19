import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import '../api/client.dart';
import '../services/drawing.dart';

class ScreenshotPage extends StatefulWidget {
  final Uint8List? screenshot;
  final ShotsClient shotsClient;

  ScreenshotPage({this.screenshot, required this.shotsClient});

  @override
  _ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> {
  bool _isUploaded = false;
  String _tool = 'pen'; // Текущий инструмент
  final DrawingService _drawingService = DrawingService();
  Offset _cursorPosition = Offset.zero; // Позиция курсора
  final TextEditingController _brushSizeController = TextEditingController();

  @override
  void initState() {
      super.initState();
      _brushSizeController.text = '15'; // Инициализация контроллера
  }

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
      print("Отправка");
      setState(() {
        _isUploaded = true;
      });
    } else {
      print('Ошибка при отправке скриншота');
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Выберите цвет'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _drawingService.brushColor,  
              onColorChanged: (color) {
                setState(() {
                  _drawingService.setBrushColor(color);  
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование скриншота'),
        actions: [
          Container(
            width: 70,
            child: TextField(
              controller: _brushSizeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Размер',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              onSubmitted: (value) {
                double newSize = double.tryParse(value) ?? 5.0;
                if (newSize >= 1.0 && newSize <= 20.0) {
                  //_setTool('pen', brushSize: newSize);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.brush),
            onPressed: () {
              setState(() {
                _tool = 'pen'; 
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () {
              setState(() {
                _drawingService.undo();  
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.color_lens), 
            onPressed: () {
              _showColorPicker(context);  
            },
          ),
          
        ],
      ),
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
                : GestureDetector(
                    onPanStart: (details) {
                      _drawingService.addPoint(details.localPosition);  
                      setState(() {});
                    },
                    onPanUpdate: (details) {
                      _drawingService.addPoint(details.localPosition);
                      setState(() {
                        _cursorPosition = details.localPosition;
                      });
                    },
                    onPanEnd: (details) {
                      _drawingService.endStroke();
                      setState(() {});
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.none,
                      onHover: (event) {
                        setState(() {
                          _cursorPosition = event.localPosition;
                        });
                      },
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,  
                            child: Image.memory(
                              widget.screenshot!,
                              fit: BoxFit.contain, 
                            ),
                          ),
                          CustomPaint(
                            painter: DrawingPainter(_drawingService),
                            child: Container(),
                          ),
                          // Если выбран инструмент "pen", рисуем кастомный курсор
                          if (_tool == 'pen')
                            Positioned(
                              left: _cursorPosition.dx - 10,
                              top: _cursorPosition.dy - 10,
                              child: CustomPaint(
                                size: Size(20, 20), // Размер круга
                                painter: CursorPainter(_drawingService.brushColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadScreenshot,
        backgroundColor: Color(0xFF4AA37C),
        child: const Icon(Icons.upload),
      ),
    );
  }
}

// Кастомный рисователь курсора
class CursorPainter extends CustomPainter {
  final Color color;

  CursorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Рисуем круг
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
