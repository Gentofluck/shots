import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/drawable_entities/graphic/vector/stroke.dart';

void main() {
  group('Stroke Visibility Tests', () {
    test('Stroke should be visible by default', () {
      final stroke = Stroke(
        [Offset(0, 0), Offset(10, 10)],
        Colors.black,
        2.0,
        false,
      );
      expect(stroke.isVisible(), true);
    });

    test('Stroke should have correct translation', () {
      final stroke = Stroke(
        [Offset(0, 0), Offset(10, 10)],
        Colors.black,
        2.0,
        false,
      );
      expect(stroke.getTotalTranslation(), Offset.zero);
    });

    test('Stroke should generate valid path', () {
      final stroke = Stroke(
        [Offset(0, 0), Offset(10, 10)],
        Colors.black,
        2.0,
        false,
      );
      final path = stroke.path;
      expect(path, isNotNull);
    });
  });
}
