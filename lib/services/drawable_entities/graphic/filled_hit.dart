import 'graphic_entity.dart';
import 'dart:math' show min, max;
import 'package:flutter/material.dart';

mixin FilledHit on GraphicEntity {
  Offset get start;
  Offset? get end;

  bool containsInRect(Offset point) {
    if (end == null) return false;

    final totalTranslation = getTotalTranslation();
    final adjusted = point - totalTranslation;

    final left = min(start.dx, end!.dx);
    final top = min(start.dy, end!.dy);
    final right = max(start.dx, end!.dx);
    final bottom = max(start.dy, end!.dy);

    return adjusted.dx >= left &&
        adjusted.dx <= right &&
        adjusted.dy >= top &&
        adjusted.dy <= bottom;
  }
}
