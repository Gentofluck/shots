import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class MoveTool extends DrawingTool {
  final GraphicEntity? Function(Offset) getPathByPoint;
  Offset? _startTranslation;

  MoveTool({required this.getPathByPoint})
    : super(
        name: 'move',
        color: const Color(0x00000000),
        size: 0,
        shadowEnabled: false,
      );
  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    if (currentStroke is StrokeChange && currentStroke.property == 'position') {
      if (currentStroke.stroke.translations.isEmpty) {
        return currentStroke;
      }
      return currentStroke;
    } else {
      final stroke = getPathByPoint(point);
      if (stroke == null) return null;

      _startTranslation = point;
      return StrokeChange('position', stroke);
    }
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    if (currentStroke is StrokeChange &&
        currentStroke.property == 'position' &&
        _startTranslation != null) {
      currentStroke.stroke.addTranslation(point, _startTranslation!);
      return null;
    }
    final stroke = getPathByPoint(point);
    if (stroke == null) return null;

    _startTranslation = point;
    return StrokeChange('position', stroke);
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    _startTranslation = null;
    return currentStroke;
  }
}
