import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;

  Stroke(this.points, this.color);
}

class DrawingService {
  List<Stroke> _strokes = [];  
  List<Offset> _currentStroke = [];  
  Color _brushColor = Colors.black;  
  double _brushSize = 5.0;  

  void setBrushColor(Color color) {
    _brushColor = color;
  }

  Color get brushColor => _brushColor;
  double get brushSize => _brushSize;

  void setBrushSize(double size) {
    _brushSize = size;
  }

  void addPoint(Offset point) {
    if (_currentStroke.isEmpty) {
      _currentStroke = [point];
    } else {
      _currentStroke.add(point);
    }
  }

  void endStroke() {
    if (_currentStroke.isNotEmpty) {
      _strokes.add(Stroke(List.from(_currentStroke), _brushColor));
      _currentStroke.clear();  
    }
  }

  void clearCanvas() {
    _strokes.clear();
    _currentStroke.clear();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
    }
  }

  Path getPath(List<Offset> stroke) {
    Path path = Path();
	if (stroke.length == 0) return path;
    if (stroke.length < 3) {
      path.moveTo(stroke[0].dx, stroke[0].dy);
      path.addOval(Rect.fromCircle(center: stroke[0], radius: _brushSize / 2)); 
    } else {
      path.moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 0; i < stroke.length - 2; i++) {
        final p0 = stroke[i];
        final p1 = stroke[i + 1];
        final p2 = stroke[i + 2];
        final controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);  

        path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
      }
    }
    return path;
  }
}

class DrawingPainter extends CustomPainter {
  final DrawingService drawingService;

  DrawingPainter(this.drawingService);

  @override
  void paint(Canvas canvas, Size size) {
	for (var stroke in drawingService._strokes) {
		final paint = Paint()
		..color = stroke.color
		..strokeWidth = drawingService._brushSize
		..strokeCap = StrokeCap.round
		..style = PaintingStyle.stroke;

		Path path = drawingService.getPath(stroke.points);
		canvas.drawPath(path, paint);
		
	}

	final currentPaint = Paint()
		..color = drawingService._brushColor
		..strokeWidth = drawingService._brushSize
		..strokeCap = StrokeCap.round
		..style = PaintingStyle.stroke;

		Path currentPath = drawingService.getPath(drawingService._currentStroke);
		canvas.drawPath(currentPath, currentPaint);
	}


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
