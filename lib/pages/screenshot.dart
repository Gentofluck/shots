import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';

import '../api/client.dart';
import '../services/drawing.dart';
import '../services/drawable_entities.dart';
import '../services/system_tray.dart';
import '../components/screenshot_toolbar.dart';
import '../components/cursor_painter.dart';
import '../components/color_picker.dart';
import '../components/screenshot_editor.dart';


class ScreenshotPage extends StatefulWidget {
	final Uint8List? screenshot;
	final ShotsClient shotsClient;
  	final Function(String) changePage;
	final VoidCallback makeShot;
  	final GlobalKey<ScreenshotEditorState>? editorKey;

	ScreenshotPage({this.screenshot, required this.shotsClient, required this.makeShot, required this.changePage, this.editorKey});

	@override
	_ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> with WindowListener {
	late final SystemTrayService _systemTrayService;
	
	bool _toogleMenu = true;
	bool _isUploaded = false;
	String _tool = 'pen';
	bool _shadowEnabled = false;
	bool _layerModifierEnabled = false;
	double _brushSize = 10.0;
	final DrawingService _drawingService = DrawingService();
	final TextEditingController _brushSizeController = TextEditingController();
	bool _isTextToolSelected = false;

	@override
	void initState() {
		super.initState();
		_brushSizeController.text = _brushSize.toString();
		_drawingService.setBrushSize(_brushSize);  
		windowManager.addListener(this);
		
		_systemTrayService = SystemTrayService(
			onShowWindow: showWindow,
			onHideWindow: hideWindow,
			onMakeShot: widget.makeShot,
			onOpenSettings: openSettings,
		);
		_systemTrayService.initTray();

		if (widget.screenshot != null) {
			_setWindowSizeToImageSize(widget.screenshot!);
		}
	}

	Future<void> _setWindowSizeToImageSize(Uint8List imageData) async {
		try {
			final mediaQuery = MediaQuery.of(context);
      		final devicePixelRatio = mediaQuery.devicePixelRatio;
      
			final codec = await instantiateImageCodec(imageData);
			final frame = await codec.getNextFrame();
			final image = frame.image;
			
			final width = image.width.toDouble() / devicePixelRatio;
			final height = image.height.toDouble() / devicePixelRatio;
			
			const toolbarHeight = 84.0; 
			await windowManager.setSize(Size(width, height + toolbarHeight));
			
			await windowManager.center();
			
			image.dispose();
		} catch (e) {
			print('Ошибка при установке размера окна: $e');
		}
	}

	@override
	void dispose() {
		windowManager.removeListener(this);
		super.dispose();
	}


	@override
	void didUpdateWidget(covariant ScreenshotPage oldWidget) {
		super.didUpdateWidget(oldWidget);

		if (widget.screenshot != oldWidget.screenshot) {
			_setWindowSizeToImageSize(widget.screenshot!);
			setIsUploaded(false);
		}
	}

	void setIsUploaded (bool isUploaded)
	{
		setState((){
			_isUploaded = isUploaded;
		});
	}

	Future<void> hideWindow() async {
		await windowManager.hide();
		await windowManager.setSkipTaskbar(true);
	}


	Future<void> showWindow() async {
		await windowManager.show();
		await windowManager.setSkipTaskbar(false);
	}

	void openSettings() {
		widget.changePage("settingsPage");
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

	void _showColorPicker(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => ColorPickerDialog(
				initialColor: _drawingService.brushColor,
				onColorChanged: (color) {
					setState(() {
					_drawingService.setBrushColor(color);
					});
				},
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return 
			Scaffold(
				appBar: AppBar(
					title: const Text(''),
					actions: [
						ScreenshotToolbar(
							brushSizeController: _brushSizeController,
							onBrushSizeChanged: _updateBrushSize,
							toggleShadow: () {
								setState(() {
									_shadowEnabled = !_shadowEnabled;
									_drawingService.setShadowEnabled(_shadowEnabled);
								});
							},
							shadowEnabled: _shadowEnabled,
							toggleLayerModifier: () {
								setState(() {
									_layerModifierEnabled = !_layerModifierEnabled;
									_drawingService.setLayerModifierEnabled(_layerModifierEnabled);
								});
							},
							layerModifierEnabled: _layerModifierEnabled,
							onToolSelected: (tool) {
								setState(() {
									_tool = tool;
									_isTextToolSelected = tool == 'text';
								});
							},
							undo: () => setState(() => _drawingService.undo()),
							redo: () => setState(() => _drawingService.redo()),
							clear: () => setState(() => _drawingService.clear()),
							showColorPicker: () => _showColorPicker(context),
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
						: ScreenshotEditor(
							tool: _tool,
							screenshot: widget.screenshot,
							setIsUploaded: setIsUploaded,
							drawingService: _drawingService,
							shotsClient: widget.shotsClient,
							hideWindow: hideWindow,
							brushSize: _brushSize,
							isTextToolSelected: _isTextToolSelected,
							key: widget.editorKey,
					),
			);
	}

}



