import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'drawable_entities/main.dart';
import './painters/stroke_renderer.dart';

import 'tools/drawing_tool.dart';
import 'tools/tool_factory.dart';

class DrawingService {
  final List<DrawableEntity> _drawingHistory = [];
  List<DrawableEntity> _drawingHistoryRedo = [];
  DrawableEntity? _currentStroke;

  DrawingTool? _activeTool;
  String _activeToolName = 'pen';

  Color _brushColor = Colors.black;
  int _brushSize = 0;
  bool _shadowEnabled = false;
  bool _layerModifierEnabled = false;
  Offset startTranslation = Offset(0, 0);
  double _pixelRatio = 1;

  GraphicEntity? _selectedElement;

  void setPixelRatio(double pixelRatio) {
    _pixelRatio = pixelRatio;
  }

  void _clearRedo() {
    _drawingHistoryRedo = [];
  }

  void _pushHistory(DrawableEntity entity) {
    _drawingHistory.add(entity);
    _clearRedo();
  }

  void setActiveTool(String toolName) {
    if (_activeToolName != toolName) {
      _activeToolName = toolName;
      _selectedElement = null;
    }
  }

  void setBrushColor(Color color) {
    if (_brushColor != color) {
      _brushColor = color;
    }
  }

  void setBrushSize(int size) {
    if (_brushSize != size) {
      _brushSize = size;
    }
  }

  void setShadowEnabled(bool shadowEnabled) {
    if (_shadowEnabled != shadowEnabled) {
      _shadowEnabled = shadowEnabled;
    }
  }

  void setLayerModifierEnabled(bool isLayerModifierEnabled) {
    _layerModifierEnabled = isLayerModifierEnabled;
  }

  Color get brushColor => _brushColor;
  int get brushSize => _brushSize;
  DrawableEntity? get currentStroke => _currentStroke;
  GraphicEntity? get selectedElement => _selectedElement;
  String get activeToolName => _activeToolName;

  void setSelectedElement(GraphicEntity? element) {
    _selectedElement = element;
  }

  void clearSelectedElement() {
    _selectedElement = null;
  }

  TextStroke? extractTextStroke(DrawableEntity? entity, bool modifier) {
    return switch (entity) {
      TextStroke s => s,
      StrokeChange t when modifier && t.stroke is TextStroke =>
        t.stroke as TextStroke,
      _ => null,
    };
  }

  GraphicEntity? extractGrapthicEntity(DrawableEntity? entity) {
    return switch (entity) {
      GraphicEntity s => s,
      StrokeChange t when _layerModifierEnabled => t.stroke,
      _ => null,
    };
  }

  int getLastTextNum() {
    return _drawingHistory.isNotEmpty && _drawingHistory.last is TextNum
        ? int.tryParse((_drawingHistory.last as TextNum).currentText) ?? 0
        : 0;
  }

  Offset getTextSize(String text, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return Offset(textPainter.width, textPainter.height);
  }

  TextStroke? getTextByPoint(Offset point) {
    TextStroke? stroke = extractTextStroke(
      _currentStroke,
      _layerModifierEnabled,
    );

    if (stroke != null && stroke.isVisible() && stroke.containsPoint(point)) {
      return stroke;
    }

    for (final entity in _drawingHistory.reversed) {
      stroke = extractTextStroke(entity, _layerModifierEnabled);

      if (stroke != null && stroke.isVisible() && stroke.containsPoint(point)) {
        return stroke;
      }
    }

    return null;
  }

  GraphicEntity? getPathByPoint(Offset point) {
    GraphicEntity? stroke = extractGrapthicEntity(_currentStroke);

    if (stroke != null && stroke.isVisible() && stroke.containsPoint(point)) {
      return stroke;
    }

    for (var entity in _drawingHistory.reversed) {
      stroke = extractGrapthicEntity(entity);
      if (stroke != null && stroke.isVisible() && stroke.containsPoint(point)) {
        return stroke;
      }
    }

    return null;
  }

  void createTextEditor(TextStroke textStroke) {
    if (_currentStroke != null) {
      _drawingHistory.add(_currentStroke!);
    }
    _currentStroke = StrokeChange('text', textStroke);
  }

  void addText(String? text) {
    TextStroke? stroke = extractTextStroke(_currentStroke, true);

    if (stroke != null) {
      stroke.updateCurrentText(text!, getTextSize(text, stroke.size));
    }
  }

  void startInteraction(Offset point, bool isShiftPressed) {
    if (_currentStroke != null) {
      final finalized = _activeTool!.onEnd(
        point,
        _currentStroke,
        _pixelRatio,
        null,
      );
      if (finalized != null) {
        _pushHistory(finalized);
      }
    }

    _activeTool = ToolFactory.createTool(
      toolName: _activeToolName,
      color: _brushColor,
      size: _brushSize.toDouble(),
      shadowEnabled: _shadowEnabled,
      getTextSize: (String s) => getTextSize(s, _brushSize.toDouble()),
      getPathByPoint: (Offset p) => getPathByPoint(p),
      getTextByPoint: (Offset p) => getTextByPoint(p),
      getLastTextNum: () => getLastTextNum(),
    );

    final started = _activeTool!.onStart(point, _currentStroke);
    if (started != null) {
      _currentStroke = started;
      _clearRedo();

      updateSelectedElementForTool(point);
    }
  }

  void continueInteraction(Offset point, bool isShiftPressed) {
    final started = _activeTool!.onMove(point, _currentStroke, isShiftPressed);
    if (started != null) {
      _currentStroke = started;
    }
  }

  void endInteraction(Offset end, ui.Image? image) {
    if (_activeToolName == 'text') return;

    _activeTool ??= ToolFactory.createTool(
      toolName: _activeToolName,
      color: _brushColor,
      size: _brushSize.toDouble(),
      shadowEnabled: _shadowEnabled,
      getTextSize: (String s) => getTextSize(s, _brushSize.toDouble()),
      getPathByPoint: (Offset p) => getPathByPoint(p),
      getTextByPoint: (Offset p) => getTextByPoint(p),
      getLastTextNum: () => getLastTextNum(),
    );

    final finalized = _activeTool!.onEnd(
      end,
      _currentStroke,
      _pixelRatio,
      image,
    );
    if (finalized != null) {
      _pushHistory(finalized);
    }
    _currentStroke = null;

    updateSelectedElementForTool(end);
  }

  List<GraphicEntity> getFilteredStrokes() {
    List<DrawableEntity> unitedStrokes = [
      ..._drawingHistory,
      if (_currentStroke != null) _currentStroke as DrawableEntity,
    ];

    int lastClearIndex = unitedStrokes.lastIndexWhere((e) => e is ClearAll);

    if (lastClearIndex != -1) {
      unitedStrokes = unitedStrokes.sublist(lastClearIndex + 1);
    }

    List<GraphicEntity> filteredStrokes = [];
    Set<GraphicEntity> usedStrokes = {};

    for (var stroke in unitedStrokes) {
      if (_layerModifierEnabled && stroke is StrokeChange) {
        if (usedStrokes.contains(stroke.stroke)) {
          filteredStrokes.removeWhere((item) => item == stroke.stroke);
        }
        filteredStrokes.add(stroke.stroke);
        usedStrokes.add(stroke.stroke);
      } else if (stroke is GraphicEntity) {
        filteredStrokes.add(stroke);
        usedStrokes.add(stroke);
      }
    }

    return filteredStrokes;
  }

  void removeLastEditing(lastStroke) {
    if (lastStroke is StrokeChange || lastStroke is ClearAll) lastStroke.undo();
  }

  void redoLastEditing(lastStroke) {
    if (lastStroke is StrokeChange || lastStroke is ClearAll) lastStroke.redo();
  }

  void undo() {
    if (_currentStroke != null) {
      removeLastEditing(_currentStroke);
      _drawingHistoryRedo.add(_currentStroke!);
      _currentStroke = null;
    } else if (_drawingHistory.isNotEmpty) {
      final lastItem = _drawingHistory.last;
      removeLastEditing(lastItem);
      _drawingHistoryRedo.add(lastItem);
      _drawingHistory.removeLast();
    }
  }

  void redo() {
    if (_drawingHistoryRedo.isNotEmpty) {
      redoLastEditing(_drawingHistoryRedo.last);
      _drawingHistory.add(_drawingHistoryRedo.last);
      _drawingHistoryRedo.removeLast();
    }
  }

  void clear() {
    if (_currentStroke != null) _drawingHistory.add(_currentStroke!);
    _drawingHistory.add(ClearAll(_drawingHistory));
    _clearRedo();
    _currentStroke = null;
  }

  void clearCanvas() {
    _drawingHistory.clear();
    _drawingHistoryRedo.clear();
    _currentStroke = null;
    _activeTool = null;
    _activeToolName = 'pen';
  }

  Future<Uint8List> generateDrawingImage(
    Size size, {
    double scaleX = 1.0,
    double scaleY = 1.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    List<GraphicEntity> strokes = getFilteredStrokes();

    canvas.scale(scaleX, scaleY);

    for (final stroke in strokes) {
      StrokeRenderer.drawStroke(canvas, stroke, false);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size.width * scaleX).toInt(),
      (size.height * scaleY).toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void updateSelectedElementForTool(Offset point) {
    switch (_activeToolName) {
      case 'move':
        if (_currentStroke is StrokeChange &&
            (_currentStroke as StrokeChange).property == 'position') {
          _selectedElement = (_currentStroke as StrokeChange).stroke;
        } else {
          _selectedElement = getPathByPoint(point);
        }
        break;

      case 'eraser':
        _selectedElement = getPathByPoint(point);
        break;

      case 'text':
        if (_currentStroke is StrokeChange &&
            (_currentStroke as StrokeChange).property == 'text') {
          _selectedElement = (_currentStroke as StrokeChange).stroke;
        } else {
          _selectedElement = getTextByPoint(point);
        }
        break;

      case 'cut':
        if (_currentStroke is CopiedRegion) {
          _selectedElement = _currentStroke as CopiedRegion;
        }
        break;

      default:
        _selectedElement = null;
        break;
    }
  }
}
