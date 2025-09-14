import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class FigureTool extends DrawingTool {
  final String figureType;

  FigureTool({
    required this.figureType,
    required super.color,
    required super.size,
    required super.shadowEnabled,
  }) : super(name: figureType);

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    if (figureType == 'filled_square') {
      return FigureStroke(point, null, color, 0, figureType, shadowEnabled);
    }
    return FigureStroke(point, null, color, size, figureType, shadowEnabled);
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    if (currentStroke is! FigureStroke) return null;

    Offset adjustedPoint = point;

    if (isShiftPressed) {
      double dx = point.dx - currentStroke.start.dx;
      double dy = point.dy - currentStroke.start.dy;

      double minDiff = dx.abs() < dy.abs() ? dx.abs() : dy.abs();
      adjustedPoint = Offset(
        currentStroke.start.dx + minDiff * (dx < 0 ? -1 : 1),
        currentStroke.start.dy + minDiff * (dy < 0 ? -1 : 1),
      );
    }

    currentStroke.setEnd(adjustedPoint);
    return null;
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    if (currentStroke is! FigureStroke) return null;

    return currentStroke;
  }
}
