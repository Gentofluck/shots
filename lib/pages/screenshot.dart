import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../api/client.dart';
import '../services/drawing.dart';
import '../services/drawable_entities.dart';
import 'package:window_manager/window_manager.dart';

class ScreenshotPage extends StatefulWidget {
	final Uint8List? screenshot;
	final ShotsClient shotsClient;

	ScreenshotPage({this.screenshot, required this.shotsClient});

	@override
	_ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> with WindowListener {
	bool _isUploaded = false;
	String _tool = 'pen';
	bool _shadowEnabled = false;
	bool _layerModifierEnabled = false;
	double _brushSize = 10.0;
	double _imageWidth = 0.0;
	double _imageHeight = 0.0;
	bool _isShiftPressed = false;
	FocusNode _rawKeyboardFocusNode = FocusNode();
	final DrawingService _drawingService = DrawingService();
	Offset _cursorPosition = Offset.zero;

	Offset _textPosition = Offset.zero;

	final GlobalKey _imageKey = GlobalKey();
	final TextEditingController _brushSizeController = TextEditingController();


	TextEditingController _textController = TextEditingController();
	FocusNode _textFocusNode = FocusNode();
	bool _isTextToolSelected = false;

	Future<void> hideWindow() async {
		await windowManager.hide();
		await windowManager.setSkipTaskbar(true);
	}

	Future<void> showWindow() async {
		await windowManager.show();
		await windowManager.setSkipTaskbar(false);
	}

	Widget _buildInvisibleTextInput() {
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
								fontSize: _brushSize,
								color: Colors.transparent,
								letterSpacing: 0,
								height: 1.18,
							),
							textInputAction: TextInputAction.newline,
							keyboardType: TextInputType.multiline,
							maxLines: null,
							minLines: 1,
							onChanged: (text) {
								_drawingService.addText(text);
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
	void initState() {
		super.initState();
		_brushSizeController.text = _brushSize.toString();
		_drawingService.setBrushSize(_brushSize);  
		_rawKeyboardFocusNode.requestFocus();
		windowManager.addListener(this);
	}

	@override
	void dispose() {
		_rawKeyboardFocusNode.dispose();
		windowManager.removeListener(this);
		super.dispose();
	}


	void _getImageDimensions() async {
		if (widget.screenshot != null) {
			final decodedImage = await decodeImageFromList(widget.screenshot!);      
			if (decodedImage != null) {
				setState(() {
					_imageWidth = decodedImage.width.toDouble();
					_imageHeight =  decodedImage.height.toDouble();
				});
			}
		}
	}

	void _updateBrushSize(String value) {
		double newSize = double.tryParse(value) ?? 5.0;
		if (newSize >= 1.0 && newSize <= 100.0) {
			setState(() {
				_brushSize = newSize;
				_drawingService.setBrushSize(_brushSize);  
			});
		}
	}

	@override
	void didUpdateWidget(covariant ScreenshotPage oldWidget) {
		super.didUpdateWidget(oldWidget);

		if (widget.screenshot != oldWidget.screenshot) {
			_getImageDimensions();
			setState(() {
				_isUploaded = false;
			});
		}
	}

	Future<void> uploadScreenshot() async {
		if (widget.screenshot == null) return;

		final img = await decodeImageFromList(widget.screenshot!);
		final actualSize = Size(img.width.toDouble(), img.height.toDouble());

		final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
		if (renderBox == null) return;
		final displayedSize = renderBox.size;

		double scaleX = actualSize.width / displayedSize.width;
		double scaleY = actualSize.height / displayedSize.height;

		final scaledDrawing = await _drawingService.generateDrawingImage(
			Size(actualSize.width, actualSize.height),
			scaleX: scaleX,
			scaleY: scaleY,
		);

		final combinedImage = await _combineImages(widget.screenshot!, scaledDrawing);

		final response = await widget.shotsClient.uploadImage(combinedImage);

		if (response.isNotEmpty && response != 'ERROR') {
			await Clipboard.setData(ClipboardData(text: response));
			setState(() {
				_isUploaded = true;
			});
			hideWindow();
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
	double pixelRatio = MediaQuery.of(context).devicePixelRatio; 

	return Scaffold(
		appBar: AppBar(
			title: const Text('Редактирование скриншота'),
			actions: [
				SizedBox(
					width: 40,
					child: TextField(
						controller: _brushSizeController,
						keyboardType: const TextInputType.numberWithOptions(decimal: true),
						decoration: const InputDecoration(
							hintText: 'Размер',
							border: InputBorder.none,
							contentPadding: EdgeInsets.symmetric(vertical: 10.0),
						),
						onChanged: _updateBrushSize,
					),
				),
				IconButton(
					icon: Icon(_shadowEnabled ? Icons.visibility : Icons.visibility_off),
					onPressed: () {
						setState(() {
							_shadowEnabled = !_shadowEnabled;
							_drawingService.setShadowEnabled(_shadowEnabled);  
						});
					},
				),
				IconButton(
						icon: Icon(_layerModifierEnabled ? Icons.layers : Icons.layers_outlined),
						onPressed: () {
							setState(() {
								_layerModifierEnabled = !_layerModifierEnabled;
								_drawingService.setLayerModifierEnabled(_layerModifierEnabled);
							});
						},
				),
				IconButton(
					icon: const Icon(Icons.format_list_numbered),
					onPressed: () { 
						setState((){ 
							_tool = 'text_num';
						});
					},
				),
				IconButton(
					icon: const Icon(Icons.text_fields),
					onPressed: () { 
						setState((){ 
							_tool = 'text';
							_isTextToolSelected = true;
						});
					},
				),

				IconButton(
					icon: Icon(Icons.move_up),
					onPressed: () => setState(() => _tool = 'move'),
				),
				IconButton(
					icon: const Icon(Icons.brush),
					onPressed: () => setState(() => _tool = 'pen'),
				),
				IconButton(
					icon: const Icon(Icons.arrow_forward),
					onPressed: () => setState(() => _tool = 'arrow'),
				),
				IconButton(
					icon: const Icon(Icons.circle_outlined),
					onPressed: () => setState(() => _tool = 'oval'),
				),
				IconButton(
					icon: const Icon(Icons.square),
					onPressed: () => setState(() => _tool = 'square'),
				),
				IconButton(
					icon: const Icon(Icons.cleaning_services),
					onPressed: () => setState(() => _tool = 'eraser'),
				),
				IconButton(
					icon: const Icon(Icons.undo),
					onPressed: () => setState(() => _drawingService.undo()),
				),
				IconButton(
					icon: const Icon(Icons.redo),
					onPressed: () => setState(() => _drawingService.redo()),
				),
				IconButton(
					icon: const Icon(Icons.color_lens),
					onPressed: () => _showColorPicker(context),
				),
				IconButton(
					icon: const Icon(Icons.delete_forever),
					onPressed: () => setState(() => _drawingService.clear()),
				),
			],
		),
		backgroundColor: const Color(0xFFF3EFEF),
		body: widget.screenshot == null
				? const Center(
						child: Text(
							'Фото не сделано',
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
						),
					)
				: _isUploaded
						? const Center(
								child: Text(
									'Фото отправлено и скопировано в буфер',
									style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
								),
							)
						:  RawKeyboardListener(
							focusNode: _rawKeyboardFocusNode,
							onKey: (event) {
								if (event.runtimeType == RawKeyDownEvent) {
									if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
										setState(() {
											_isShiftPressed = true;	
										});
									}
								} else if (event.runtimeType == RawKeyUpEvent) {
									if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
										setState(() {
											_isShiftPressed = false;  
										});
									}
								}
							},
							child: InteractiveViewer(
								boundaryMargin: EdgeInsets.zero,
								minScale: 0.5,
								maxScale: 4.0,
								constrained: false, 
								child: SingleChildScrollView(
									scrollDirection: Axis.horizontal,
									child: SingleChildScrollView(
										scrollDirection: Axis.vertical,
										child: Align(
											alignment: Alignment.topLeft,
											child: Listener(
												onPointerDown: (details) {
													if (_tool == 'text') {
														TextStroke? textStroke = _drawingService.getTextByPoint(details.localPosition);

														Offset start = details.localPosition;
														String currentText = '';
														if (textStroke != null)
														{
															DrawableEntity? currentStroke = _drawingService.currentStroke; 
															if ((currentStroke == textStroke) || (currentStroke is StrokeChange && currentStroke.stroke == textStroke)) return;

															_drawingService.createTextEditor(textStroke);
															start = textStroke.start + textStroke.getTotalTranslation();
															currentText = textStroke.text.last;
														}
														else
														{
															_drawingService.addPoint(start, _tool, false);
														}
														_textController.text = currentText;
														_textPosition = start;
														_textFocusNode.unfocus();
														Future.delayed(Duration(milliseconds: 10), () { 
															_textFocusNode.requestFocus(); 
														});
													}
													else {
														_textController.text = '';
														_textPosition = Offset(0, 0);
														_textFocusNode.unfocus();
														_rawKeyboardFocusNode.requestFocus();
														_drawingService.addPoint(details.localPosition, _tool, _isShiftPressed);
													}
													setState(() {});
												},
												onPointerMove: (details) {
													if(_tool == 'text' || _tool == 'text_num') return;
													_drawingService.addPoint(details.localPosition, _tool, _isShiftPressed);
													setState(() => _cursorPosition = details.localPosition);
												},
												onPointerUp: (details) {
													if(_tool == 'text' || _tool == 'text_num' || _tool == 'eraser') return;
													_drawingService.endDrawing(details.localPosition, _tool);
													setState(() {});
												},
												child: MouseRegion(
													cursor: _tool == 'pen' ? SystemMouseCursors.none : SystemMouseCursors.precise,
													onHover: (event) {
														setState(() => _cursorPosition = event.localPosition);
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
																					painter: DrawingPainter(_drawingService),
																				),
																			),
																		],
																	),
																),
															),
															if (_isTextToolSelected) _buildInvisibleTextInput(),
															if (_tool == 'pen')
																Positioned(
																	left: _cursorPosition.dx - _brushSize / 2,
																	top: _cursorPosition.dy - _brushSize / 2,
																	child: CustomPaint(
																		size: Size(_brushSize, _brushSize),
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
							),
						),
		floatingActionButton: FloatingActionButton(
			onPressed: uploadScreenshot,
			backgroundColor: const Color(0xFF4AA37C),
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



