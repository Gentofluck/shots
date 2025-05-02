import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';

import '../services/drawable_entities.dart';
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
	final bool isTextToolSelected;

	const ScreenshotEditor({
		super.key,
		required this.tool,
		this.screenshot,
		required this.setIsUploaded,
		required this.drawingService,
		required this.shotsClient,
		required this.hideWindow,
		required this.brushSize,
		required this.isTextToolSelected
	});

	@override
	State<ScreenshotEditor> createState() => ScreenshotEditorState();
}


class ScreenshotEditorState extends State<ScreenshotEditor> {
	final GlobalKey _imageKey = GlobalKey();
	Offset _cursorPosition = Offset.zero;
	Offset _textPosition = Offset.zero;
  	FocusNode _rawKeyboardFocusNode = FocusNode();
	TextEditingController _textController = TextEditingController();
	FocusNode _textFocusNode = FocusNode();
	double _imageWidth = 0.0;
	double _imageHeight = 0.0;
	double _textSize = 10.0;
	bool _isShiftPressed = false;

	@override
	void initState(){
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
			if (decodedImage != null) {
				setState(() {
					_imageWidth = decodedImage.width.toDouble();
					_imageHeight =  decodedImage.height.toDouble();
				});
			}
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

	Future<void> uploadScreenshot() async {
		if (widget.screenshot == null) return;

		final img = await decodeImageFromList(widget.screenshot!);
		final actualSize = Size(img.width.toDouble(), img.height.toDouble());
  
		final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
		if (renderBox == null) return;
		final displayedSize = renderBox.size;

		double scaleX = actualSize.width / displayedSize.width;
		double scaleY = actualSize.height / displayedSize.height;

		final scaledDrawing = await widget.drawingService.generateDrawingImage(
			Size(actualSize.width, actualSize.height),
			scaleX: scaleX,
			scaleY: scaleY,
		);

		final combinedImage = await _combineImages(widget.screenshot!, scaledDrawing);

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
	Widget build(BuildContext context)
	{
		double pixelRatio = MediaQuery.of(context).devicePixelRatio; 

		if (_imageWidth == 0 || _imageHeight == 0) {
			_getImageDimensions();
			return const Center(child: CircularProgressIndicator());
		}

		return (
			Scaffold (
				body: RawKeyboardListener(
					focusNode: _rawKeyboardFocusNode,
					onKey: (event) {
						if (event is RawKeyDownEvent) {
							final isCtrlOrCmdPressed = event.isControlPressed || event.isMetaPressed;
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
							} else if (isCtrlOrCmdPressed && event.logicalKey == LogicalKeyboardKey.keyZ) {
								if (_textFocusNode.hasFocus) return;
								if (isShiftPressed) {
									print('redo');
									widget.drawingService.redo(); 	
								} else {
									print('undo');
									widget.drawingService.undo();	
								}
								setState(() {});
							}
						}
						else if (event is RawKeyUpEvent) {
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
										if (widget.tool == 'text') {
											TextStroke? textStroke = widget.drawingService.getTextByPoint(details.localPosition);

											Offset start = details.localPosition - Offset(0, (double.tryParse(widget.brushSize.toString()) ?? 15.0) * 5.0 / 2);
											String currentText = '';
											if (textStroke != null)
											{
												DrawableEntity? currentStroke = widget.drawingService.currentStroke; 
												if ((currentStroke == textStroke) || (currentStroke is StrokeChange && currentStroke.stroke == textStroke)) return;

												widget.drawingService.createTextEditor(textStroke);
												start = textStroke.start + textStroke.getTotalTranslation();
												currentText = textStroke.currentText;
												_textSize = textStroke.size;
												print('textStroke: ${currentText}');
												print(_textSize);
											}
											else
											{
												widget.drawingService.addPoint(start, widget.tool, false);
												_textSize = widget.brushSize.toDouble() * 5.0;
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
											widget.drawingService.addPoint(details.localPosition, widget.tool, _isShiftPressed);
										}
										setState(() {});
									},
									onPointerMove: (details) {
										if(widget.tool == 'text' || widget.tool == 'text_num') return;
										widget.drawingService.addPoint(details.localPosition, widget.tool, _isShiftPressed);
										setState(() => _cursorPosition = details.localPosition);
									},
									onPointerUp: (details) {
										if(widget.tool == 'text' || widget.tool == 'text_num' || widget.tool == 'eraser') return;
										widget.drawingService.endDrawing(details.localPosition, widget.tool);
										setState(() {});
									},
									child: MouseRegion(
										cursor: widget.tool == 'pen' ? SystemMouseCursors.none : SystemMouseCursors.precise,
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
																		painter: DrawingPainter(widget.drawingService),
																	),
																),
															],
														),
													),
												),
												if (widget.isTextToolSelected) _buildInvisibleTextInput(),
												if (widget.tool == 'pen')
													Positioned(
														left: _cursorPosition.dx - widget.brushSize / 2,
														top: _cursorPosition.dy - widget.brushSize / 2,
														child: CustomPaint(
															size: Size(widget.brushSize.toDouble(), widget.brushSize.toDouble()),
															painter: CursorPainter(widget.drawingService.brushColor),
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
			)
		);
	}
}
