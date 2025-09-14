import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class PenTool extends DrawingTool {
  PenTool({
    required super.color,
    required super.size,
    required super.shadowEnabled,
  }) : super(name: 'pen');

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    return Stroke([point], color, size, shadowEnabled);
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    if (currentStroke is! Stroke) return null;

    currentStroke.addPoint(point, isShiftPressed);

    return null;
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    if (currentStroke is! Stroke || currentStroke.points.isEmpty) {
      return null;
    }

    return currentStroke;
  }
}
