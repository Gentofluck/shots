import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../services/api/client.dart';
import '../services/drawing.dart';
import '../services/system_tray.dart';
import '../components/screenshot_toolbar.dart';
import '../components/color_picker.dart';
import '../components/screenshot_editor.dart';

class ScreenshotPage extends StatefulWidget {
  final Uint8List? screenshot;
  final ShotsClient shotsClient;
  final Function(String) changePage;
  final VoidCallback makeShot;
  final GlobalKey<ScreenshotEditorState>? editorKey;

  ScreenshotPage({
    this.screenshot,
    required this.shotsClient,
    required this.makeShot,
    required this.changePage,
    this.editorKey,
  });

  @override
  _ScreenshotPageState createState() => _ScreenshotPageState();
}

class _ScreenshotPageState extends State<ScreenshotPage> with WindowListener {
  late final SystemTrayService _systemTrayService;

  final double _toolbarHeight = 38;

  bool _isUploaded = false;
  String _tool = 'pen';
  bool _shadowEnabled = false;
  Color _toolColor = Colors.black;
  bool _layerModifierEnabled = false;
  int _brushSize = 10;
  final DrawingService _drawingService = DrawingService();
  final TextEditingController _brushSizeController = TextEditingController();

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
      onOpenAuth: openAuth,
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

      await windowManager.setSize(Size(width, height + _toolbarHeight + 28));

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
      _drawingService.clearCanvas();
      _setWindowSizeToImageSize(widget.screenshot!);
      setIsUploaded(false);
    }
  }

  void setIsUploaded(bool isUploaded) {
    setState(() {
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

  void openAuth() {
    widget.changePage("authPage");
  }

  void _updateBrushSize(String value) {
    int newSize = value == "первый" ? 1 : (int.tryParse(value) ?? 15);
    if (newSize >= 1 && newSize <= 100) {
      setState(() {
        _brushSize = newSize;
        _drawingService.setBrushSize(_brushSize);
      });
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ColorPickerDialog(
            initialColor: _drawingService.brushColor,
            onColorChanged: (color) {
              setState(() {
                _toolColor = color;
                _drawingService.setBrushColor(color);
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _toolbarHeight,
        actions: [
          ScreenshotToolbar(
            brushSize: _brushSize,
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
              });
            },
            tool: _tool,
            color: _toolColor,
            undo: () => setState(() => _drawingService.undo()),
            redo: () => setState(() => _drawingService.redo()),
            clear: () => setState(() => _drawingService.clear()),
            showColorPicker: () => _showColorPicker(context),
            uploadScreenshot:
                widget.editorKey?.currentState?.uploadScreenshot ??
                (() async {}),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3EFEF),
      body:
          widget.screenshot == null
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
                key: widget.editorKey,
              ),
    );
  }
}
