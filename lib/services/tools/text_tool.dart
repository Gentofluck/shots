import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class TextTool extends DrawingTool {
  final Offset Function(String) getTextSize;
  final TextStroke? Function(Offset) getTextByPoint;

  TextTool({
    required super.color,
    required super.size,
    required super.shadowEnabled,
    required this.getTextSize,
    required this.getTextByPoint,
  }) : super(name: 'text');

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    return TextStroke([''], point, [point], color, size * 5, shadowEnabled);
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    return null;
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    return currentStroke;
  }
}
