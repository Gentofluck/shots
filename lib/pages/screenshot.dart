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
  String _tool = 'pen';
  final DrawingService _drawingService = DrawingService();
  Offset _cursorPosition = Offset.zero;
  final GlobalKey _imageKey = GlobalKey();
  final TextEditingController _brushSizeController = TextEditingController();
  

  @override
  void initState() {
      super.initState();
      _brushSizeController.text = '15';
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

    // Получаем фактический размер изображения
    final img = await decodeImageFromList(widget.screenshot!);
    final actualSize = Size(img.width.toDouble(), img.height.toDouble());

    // Получаем размер отображаемого изображения
    final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final displayedSize = renderBox.size;

    // Вычисляем коэффициенты масштабирования
    double scaleX = actualSize.width / displayedSize.width;
    double scaleY = actualSize.height / displayedSize.height;

    // Генерируем изображение с рисунком, увеличенным по этим коэффициентам
    final scaledDrawing = await _drawingService.generateDrawingImage(
      Size(actualSize.width, actualSize.height),
      scaleX: scaleX,
      scaleY: scaleY,
    );

    // Объединяем изображение
    final combinedImage = await _combineImages(widget.screenshot!, scaledDrawing);

    // Загружаем объединенное изображение
    final response = await widget.shotsClient.uploadImage(combinedImage);

    if (response.isNotEmpty && response != 'ERROR') {
      await Clipboard.setData(ClipboardData(text: response));
      setState(() {
        _isUploaded = true;
      });
    } else {
      print('Ошибка при отправке скриншота');
    }
  }


  Future<Uint8List> _combineImages(Uint8List screenshot, Uint8List drawingImage) async {
    final screenshotImage = await decodeImageFromList(screenshot);
    final drawingImageData = await decodeImageFromList(drawingImage);

    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset(0, 0), Offset(screenshotImage.width.toDouble(), screenshotImage.height.toDouble())),
    );

    canvas.drawImage(screenshotImage, Offset(0, 0), Paint());

    canvas.drawImage(drawingImageData, Offset(0, 0), Paint());

    final picture = recorder.endRecording();
    final imgWithDrawing = await picture.toImage(screenshotImage.width, screenshotImage.height);

    final byteData = await imgWithDrawing.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
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
            width: 40,
            child: TextField(
              controller: _brushSizeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Размер',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              onChanged: (value) {
                double newSize = double.tryParse(value) ?? 5.0;
                if (newSize >= 1.0 && newSize <= 100.0) {
                  _drawingService.setBrushSize(newSize);
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
                : InteractiveViewer (
                    panEnabled: false, 
                    scaleEnabled: true, 
                    minScale: 0.1, 
                    maxScale: 5.0,
                  child: Container(
                    child: 
                    Listener(
                    onPointerDown: (details) {
                      _drawingService.addPoint((details.localPosition));
                      setState(() {});
                    },
                    onPointerMove: (details) {
                      _drawingService.addPoint(details.localPosition);
                      setState(() {
                        _cursorPosition = details.localPosition;
                      });
                    },

                    onPointerUp: (details) {
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
                         SizedBox(
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Image.memory(
                                widget.screenshot!,
                                fit: BoxFit.contain,
                                key: _imageKey,
                              ),
                              Positioned(
                                child: CustomPaint(
                                  painter: DrawingPainter(_drawingService),
                                ),
                              ),
                            ],
                          ),
                        ),

                          
                          if (_tool == 'pen')
                            Positioned(
                              left: _cursorPosition.dx - 10,
                              top: _cursorPosition.dy - 10,
                              child: CustomPaint(
                                size: Size(20, 20),
                                painter: CursorPainter(_drawingService.brushColor),
                              ),
                            ),
                        ],
                      ),
                    ),
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

class CursorPainter extends CustomPainter {
  final Color color;

  CursorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}



