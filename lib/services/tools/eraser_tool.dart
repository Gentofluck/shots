import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class EraserTool extends DrawingTool {
  final GraphicEntity? Function(Offset) getPathByPoint;

  EraserTool({required this.getPathByPoint})
    : super(
        name: 'eraser',
        color: const Color(0x00000000),
        size: 0,
        shadowEnabled: false,
      );

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    final stroke = getPathByPoint(point);
    if (stroke != null) {
      return StrokeChange('eraser', stroke);
    }
    return null;
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    return onStart(point, currentStroke);
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) => null;
}
