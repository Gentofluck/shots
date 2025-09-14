import 'dart:ui';
import '../drawable_entities/main.dart';

abstract class DrawingTool {
  final String name;
  final Color color;
  final double size;
  final bool shadowEnabled;

  DrawingTool({
    required this.name,
    required this.color,
    required this.size,
    required this.shadowEnabled,
  });

  //Добавление в currentStroke
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke);

  //изменение в currentStroke
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  );

  //Добавление в историю
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]);
}
