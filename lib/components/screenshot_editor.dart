import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/painters/drawing_painter.dart';
import '../services/drawable_entities/main.dart';
import '../services/drawing.dart';
import '../components/cursor_painter.dart';
import '../services/api/client.dart';

class ScreenshotEditor extends StatefulWidget {
  final String tool;
  final Uint8List? screenshot;
  final void Function(bool) setIsUploaded;
  final Future<void> Function() hideWindow;
  final DrawingService drawingService;
  final ShotsClient shotsClient;
  final int brushSize;

  const ScreenshotEditor({
    super.key,
    required this.tool,
    this.screenshot,
    required this.setIsUploaded,
    required this.drawingService,
    required this.shotsClient,
    required this.hideWindow,
    required this.brushSize,
  });

  @override
  State<ScreenshotEditor> createState() => ScreenshotEditorState();
}

class ScreenshotEditorState extends State<ScreenshotEditor> {
  final GlobalKey _imageKey = GlobalKey();
  Offset _cursorPosition = Offset.zero;
  Offset _textPosition = Offset.zero;
  final FocusNode _rawKeyboardFocusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  double _imageWidth = 0.0;
  double _imageHeight = 0.0;
  double _textSize = 10.0;
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    _rawKeyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _rawKeyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScreenshotEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.screenshot != oldWidget.screenshot) {
      _getImageDimensions();
    }
  }

  void _getImageDimensions() async {
    if (widget.screenshot != null) {
      final decodedImage = await decodeImageFromList(widget.screenshot!);
      setState(() {
        _imageWidth = decodedImage.width.toDouble();
        _imageHeight = decodedImage.height.toDouble();
      });
    }
  }

  Future<Uint8List?> _getCombinedImage() async {
    if (widget.screenshot == null) return null;

    final img = await decodeImageFromList(widget.screenshot!);
    final actualSize = Size(img.width.toDouble(), img.height.toDouble());

    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final displayedSize = renderBox.size;

    double scaleX = actualSize.width / displayedSize.width;
    double scaleY = actualSize.height / displayedSize.height;

    final scaledDrawing = await widget.drawingService.generateDrawingImage(
      Size(actualSize.width, actualSize.height),
      scaleX: scaleX,
      scaleY: scaleY,
    );

    return await _combineImages(widget.screenshot!, scaledDrawing);
  }

  Future<Uint8List> _combineImages(
    Uint8List screenshot,
    Uint8List drawingImage,
  ) async {
    final screenshotImage = await decodeImageFromList(screenshot);
    final drawingImageData = await decodeImageFromList(drawingImage);

    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0, 0),
        Offset(
          screenshotImage.width.toDouble(),
          screenshotImage.height.toDouble(),
        ),
      ),
    );

    canvas.drawImage(screenshotImage, Offset(0, 0), Paint());

    canvas.drawImage(drawingImageData, Offset(0, 0), Paint());

    final picture = recorder.endRecording();
    final imgWithDrawing = await picture.toImage(
      screenshotImage.width,
      screenshotImage.height,
    );

    final byteData = await imgWithDrawing.toByteData(
      format: ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> uploadScreenshot() async {
    final combinedImage = await _getCombinedImage();
    if (combinedImage == null) return;

    final response = await widget.shotsClient.uploadImage(combinedImage);

    if (response.isNotEmpty && response != 'ERROR') {
      await Clipboard.setData(ClipboardData(text: response));
      widget.setIsUploaded(true);
      widget.hideWindow();
    } else {
      print('Ошибка при отправке скриншота');
    }
  }

  Widget _buildInvisibleTextInput() {
    double fontSize = (_textSize);
    return Positioned(
      left: _textPosition.dx,
      top: _textPosition.dy,
      child: GestureDetector(
        onTap: () {},
        child: Opacity(
          opacity: 1.0,
          child: IntrinsicWidth(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.transparent,
                letterSpacing: 0,
                //1.35 windows
                height: 1.18,
              ),
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
              onChanged: (text) {
                widget.drawingService.addText(text);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    widget.drawingService.setPixelRatio(pixelRatio);

    if (_imageWidth == 0 || _imageHeight == 0) {
      _getImageDimensions();
      return const Center(child: CircularProgressIndicator());
    }

    return (Scaffold(
      body: RawKeyboardListener(
        focusNode: _rawKeyboardFocusNode,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            final isCtrlOrCmdPressed =
                event.isControlPressed || event.isMetaPressed;
            final isShiftPressed = event.isShiftPressed;

            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              setState(() {
                _isShiftPressed = true;
              });
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.setIsUploaded(false);
              widget.hideWindow();
              setState(() {});
            } else if (isCtrlOrCmdPressed &&
                event.logicalKey == LogicalKeyboardKey.keyZ) {
              if (_textFocusNode.hasFocus) return;
              if (isShiftPressed) {
                widget.drawingService.redo();
              } else {
                widget.drawingService.undo();
              }
              setState(() {});
            }
          } else if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              setState(() {
                _isShiftPressed = false;
              });
            }
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.topLeft,
              child: Listener(
                onPointerDown: (details) {
                  widget.drawingService.setActiveTool(widget.tool);
                  widget.drawingService.setBrushSize(widget.brushSize);

                  if (widget.tool == 'text') {
                    TextStroke? textStroke = widget.drawingService
                        .getTextByPoint(details.localPosition);

                    String currentText = '';
                    Offset start = details.localPosition;

                    if (textStroke != null) {
                      DrawableEntity? currentStroke =
                          widget.drawingService.currentStroke;
                      if ((currentStroke == textStroke) ||
                          (currentStroke is StrokeChange &&
                              currentStroke.stroke == textStroke)) {
                        return;
                      }

                      widget.drawingService.createTextEditor(textStroke);
                      start =
                          textStroke.start + textStroke.getTotalTranslation();
                      currentText = textStroke.currentText;
                      _textSize = textStroke.size;
                    } else {
                      start =
                          details.localPosition -
                          Offset(0, (widget.brushSize.toDouble() * 5.0) / 2);
                      widget.drawingService.startInteraction(start, false);
                      _textSize = widget.brushSize.toDouble() * 5.0;
                    }

                    _textController.text = currentText;
                    _textPosition = start;
                    _textFocusNode.unfocus();
                    Future.delayed(const Duration(milliseconds: 10), () {
                      _textFocusNode.requestFocus();
                    });
                  } else {
                    _textController.text = '';
                    _textPosition = Offset.zero;
                    _textFocusNode.unfocus();
                    _rawKeyboardFocusNode.requestFocus();
                    widget.drawingService.startInteraction(
                      details.localPosition,
                      _isShiftPressed,
                    );
                  }
                  setState(() {});
                },
                onPointerMove: (details) {
                  if (widget.tool == 'text') {
                    return;
                  }
                  widget.drawingService.continueInteraction(
                    details.localPosition,
                    _isShiftPressed,
                  );
                  setState(() {
                    _cursorPosition = details.localPosition;
                    // Обновляем выбранный элемент во время перетаскивания для move
                    if (widget.tool == 'move') {
                      widget.drawingService.updateSelectedElementForTool(
                        details.localPosition,
                      );
                    }
                  });
                },
                onPointerUp: (details) async {
                  if (widget.tool == 'cut') {
                    final combinedImage = await _getCombinedImage();
                    if (combinedImage == null) return;

                    final image = await decodeImageFromList(combinedImage);

                    widget.drawingService.endInteraction(
                      details.localPosition,
                      image,
                    );
                  } else {
                    widget.drawingService.endInteraction(
                      details.localPosition,
                      null,
                    );
                  }

                  setState(() {
                    // Обновляем выбранный элемент после завершения взаимодействия
                    if (widget.tool == 'move' ||
                        widget.tool == 'eraser' ||
                        widget.tool == 'text') {
                      widget.drawingService.updateSelectedElementForTool(
                        details.localPosition,
                      );
                    }
                  });
                },
                child: MouseRegion(
                  cursor:
                      widget.tool == 'pen'
                          ? SystemMouseCursors.none
                          : SystemMouseCursors.precise,
                  onHover: (event) {
                    setState(() {
                      _cursorPosition = event.localPosition;
                      // Обновляем выбранный элемент при hover для соответствующих инструментов
                      if (widget.tool == 'move' ||
                          widget.tool == 'eraser' ||
                          widget.tool == 'text') {
                        widget.drawingService.updateSelectedElementForTool(
                          event.localPosition,
                        );
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      ClipRect(
                        child: Container(
                          width: _imageWidth / pixelRatio,
                          height: _imageHeight / pixelRatio,
                          child: Stack(
                            children: [
                              Image.memory(
                                widget.screenshot!,
                                key: _imageKey,
                                scale: pixelRatio,
                              ),
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DrawingPainter(
                                    widget.drawingService.getFilteredStrokes(),
                                    selectedElement:
                                        widget.drawingService.selectedElement,
                                  ),
                                  size: Size.infinite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.tool == 'text') _buildInvisibleTextInput(),
                      if (widget.tool == 'pen')
                        Positioned(
                          left: _cursorPosition.dx - widget.brushSize / 2,
                          top: _cursorPosition.dy - widget.brushSize / 2,
                          child: CustomPaint(
                            size: Size(
                              widget.brushSize.toDouble(),
                              widget.brushSize.toDouble(),
                            ),
                            painter: CursorPainter(
                              widget.drawingService.brushColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
