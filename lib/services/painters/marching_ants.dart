import 'package:flutter/material.dart';

class MarchingAnts {
  static void draw(
    Canvas canvas,
    Path path, {
    double dashWidth = 6.0,
    double dashSpace = 3.0,
    List<Color> colors = const [Colors.black, Colors.white],
    double padding = 3.0,
  }) {
    final bounds = path.getBounds().inflate(padding);
    final rectPath = Path()..addRect(bounds);
    _drawDashedPath(canvas, rectPath, dashWidth, dashSpace, colors);
  }

  static void drawRect(
    Canvas canvas,
    Rect rect, {
    double dashWidth = 6.0,
    double dashSpace = 3.0,
    List<Color> colors = const [Colors.black, Colors.white],
  }) {
    final rectPath = Path()..addRect(rect);
    _drawDashedPath(canvas, rectPath, dashWidth, dashSpace, colors);
  }

  static void _drawDashedPath(
    Canvas canvas,
    Path path,
    double dashWidth,
    double dashSpace,
    List<Color> colors,
  ) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extract = metric.extractPath(
          distance,
          nextDistance.clamp(0.0, metric.length),
        );

        paint.color =
            colors[(distance ~/ (dashWidth + dashSpace)) % colors.length];
        canvas.drawPath(extract, paint);

        distance = nextDistance + dashSpace;
      }
      distance = 0.0;
    }
  }
}
