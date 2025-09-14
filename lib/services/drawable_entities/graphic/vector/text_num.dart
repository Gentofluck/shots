import 'package:flutter/material.dart';
import 'dart:math';
import 'text_stroke.dart';

class TextNum extends TextStroke {
  Offset? _end;

  TextNum(
    super.text,
    super.start,
    super.length,
    super.color,
    super.size,
    super.shadowEnabled,
  );

  Offset? get end => _end;

  void setEnd(Offset end) {
    _end = end;
    onChanged();
  }

  @override
  void generatePath() {
    final path = Path();
    final translation = getTotalTranslation();
    final currentStart = translation + start + currentEndOffset / 2;
    final currentEnd = _end != null ? _end! + translation : currentStart;

    final radius = size * 0.8;

    path.addOval(Rect.fromCircle(center: currentStart, radius: radius));

    _drawArrowPath(path, currentStart, currentEnd, radius);

    setPath(path);
  }

  void _drawArrowPath(Path path, Offset start, Offset end, double radius) {
    final vec = end - start;
    final length = vec.distance;
    if (length < radius) return;

    final direction = vec.direction;

    final arrowStart = start + Offset(cos(direction), sin(direction)) * radius;

    path.moveTo(arrowStart.dx, arrowStart.dy);
    path.lineTo(end.dx, end.dy);

    final headLength = min(length * 0.1, size);
    final headAngle = pi / 6;

    final left =
        end +
        Offset(
          -cos(direction - headAngle) * headLength,
          -sin(direction - headAngle) * headLength,
        );

    final right =
        end +
        Offset(
          -cos(direction + headAngle) * headLength,
          -sin(direction + headAngle) * headLength,
        );

    path.moveTo(end.dx, end.dy);
    path.lineTo(left.dx, left.dy);
    path.moveTo(end.dx, end.dy);
    path.lineTo(right.dx, right.dy);
  }
}
