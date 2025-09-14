import 'package:flutter/material.dart';
import '../drawable_entities/graphic/graphic_entity.dart';
import './stroke_renderer.dart';

class DrawingPainter extends CustomPainter {
  final List<GraphicEntity> strokes;
  final GraphicEntity? selectedElement;

  DrawingPainter(this.strokes, {this.selectedElement});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final shouldShowAnts = selectedElement == stroke;
      StrokeRenderer.drawStroke(canvas, stroke, shouldShowAnts);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.selectedElement != selectedElement;
  }
}
