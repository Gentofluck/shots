import 'dart:ui';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class TextNumTool extends DrawingTool {
  final Offset Function(String) getTextSize;
  final int Function() getLastTextNum;

  TextNumTool({
    required super.color,
    required super.size,
    required super.shadowEnabled,
    required this.getTextSize,
    required this.getLastTextNum,
  }) : super(name: 'text_num');

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    int currentNum = getLastTextNum();
    if (currentStroke is TextNum) {
      currentNum = int.tryParse(currentStroke.currentText) ?? 0;
    }
    final afterNum = (currentNum + 1).toString();
    final textSize = getTextSize(afterNum);

    return TextNum(
      [afterNum],
      point - textSize * 5 / 2,
      [textSize * 5],
      color,
      size * 5,
      shadowEnabled,
    );
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    if (currentStroke is! TextNum) return null;
    currentStroke.setEnd(point);
    return null;
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    if (currentStroke is! TextNum) return null;
    currentStroke.setEnd(point);
    return currentStroke;
  }
}
