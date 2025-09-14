import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shots/services/drawable_entities/graphic/vector/text_stroke.dart';

class ShadowRenderer {
  static void drawShadow(Canvas canvas, Path path, Paint paint, bool isFill) {
    final shadowPaint =
        Paint()
          ..style = paint.style
          ..strokeWidth = paint.strokeWidth
          ..strokeJoin = paint.strokeJoin
          ..strokeCap = paint.strokeCap;

    for (int i = 0; i < 5; i++) {
      shadowPaint.color = Colors.black.withValues(
        alpha: (0.5 - i * 0.02).clamp(0.0, 1.0),
      );
      shadowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, (i + 1) * 6.0);
      canvas.drawPath(path, shadowPaint);
    }
  }

  static void drawTextShadow(Canvas canvas, TextStroke textStroke) {
    final shadowStyle = ui.TextStyle(
      color: Colors.black.withValues(alpha: 0.5),
      fontSize: textStroke.size,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: textStroke.size,
    );

    final builder =
        ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(shadowStyle)
          ..addText(textStroke.currentText);

    final paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));

    final translation = textStroke.getTotalTranslation();
    final baseOffset = textStroke.start + translation;

    for (int i = 1; i <= 3; i++) {
      final offset = Offset(
        baseOffset.dx + i.toDouble(),
        baseOffset.dy + i.toDouble(),
      );
      canvas.drawParagraph(paragraph, offset);
    }
  }
}
