import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shots/services/drawing.dart';
import 'package:shots/services/drawable_entities/main.dart';

void main() {
  group('DrawingService Tool Management', () {
    late DrawingService drawingService;

    setUp(() {
      drawingService = DrawingService();
    });

    test('should set and get active tool', () {
      // Initially should have default tool
      expect(drawingService.activeToolName, equals('pen'));

      // Change to text tool
      drawingService.setActiveTool('text');
      expect(drawingService.activeToolName, equals('text'));

      // Change brush parameters
      drawingService.setBrushColor(Colors.red);
      drawingService.setBrushSize(10);
      drawingService.setShadowEnabled(true);

      // Tool should still be active
      expect(drawingService.activeToolName, equals('text'));
      expect(drawingService.brushColor, equals(Colors.red));
      expect(drawingService.brushSize, equals(10));
    });

    test('should create new stroke when starting interaction', () {
      drawingService.setActiveTool('pen');

      // Start drawing
      drawingService.startInteraction(const Offset(10, 10), false);

      // Should have current stroke
      expect(drawingService.currentStroke, isNotNull);
    });

    test('should finish current text stroke when starting new text', () {
      drawingService.setActiveTool('text');

      // Start first text
      drawingService.startInteraction(const Offset(10, 10), false);
      final firstStroke = drawingService.currentStroke;
      expect(firstStroke, isNotNull);

      // Start second text - should finish first
      drawingService.startInteraction(const Offset(50, 50), false);
      final secondStroke = drawingService.currentStroke;

      // Should be different strokes
      expect(secondStroke, isNotNull);
      expect(secondStroke, isNot(equals(firstStroke)));
    });

    test('should clear canvas and reset tool state', () {
      drawingService.setActiveTool('text');
      drawingService.setBrushColor(Colors.blue);

      drawingService.clearCanvas();

      // Should reset to default state
      expect(drawingService.activeToolName, equals('pen'));
      expect(drawingService.currentStroke, isNull);
    });

    test('should create multiple text strokes correctly', () {
      drawingService.setActiveTool('text');

      // Create first text
      drawingService.startInteraction(const Offset(10, 10), false);
      expect(drawingService.currentStroke, isNotNull);
      expect(drawingService.currentStroke, isA<TextStroke>());

      // Start typing in first text
      drawingService.addText('Hello');
      final firstText = drawingService.currentStroke as TextStroke;
      expect(firstText.currentText, equals('Hello'));

      // Create second text (should finish first automatically)
      drawingService.startInteraction(const Offset(50, 50), false);
      expect(drawingService.currentStroke, isNotNull);
      expect(drawingService.currentStroke, isNot(equals(firstText)));

      final secondText = drawingService.currentStroke as TextStroke;
      expect(secondText.currentText, equals(''));

      // Type in second text
      drawingService.addText('World');
      expect(secondText.currentText, equals('World'));
      expect(
        firstText.currentText,
        equals('Hello'),
      ); // First text should remain unchanged
    });

    test('should create sequential text numbers correctly', () {
      drawingService.setActiveTool('text_num');

      // Create first number
      drawingService.startInteraction(const Offset(10, 10), false);
      expect(drawingService.currentStroke, isNotNull);
      expect(drawingService.currentStroke, isA<TextNum>());

      final firstNum = drawingService.currentStroke as TextNum;
      expect(firstNum.currentText, equals('1'));

      // Create second number (should increment)
      drawingService.startInteraction(const Offset(50, 50), false);
      expect(drawingService.currentStroke, isNotNull);
      expect(drawingService.currentStroke, isNot(equals(firstNum)));

      final secondNum = drawingService.currentStroke as TextNum;
      expect(secondNum.currentText, equals('2'));

      // Create third number
      drawingService.startInteraction(const Offset(100, 100), false);
      final thirdNum = drawingService.currentStroke as TextNum;
      expect(thirdNum.currentText, equals('3'));

      // Previous numbers should still exist and unchanged
      expect(firstNum.currentText, equals('1'));
      expect(secondNum.currentText, equals('2'));
    });
  });
}
