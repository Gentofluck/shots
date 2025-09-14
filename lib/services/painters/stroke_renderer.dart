import 'package:flutter/material.dart';
import '../drawable_entities/graphic/graphic_entity.dart';
import '../drawable_entities/graphic/raster/copied_region.dart';
import '../drawable_entities/graphic/vector/text_stroke.dart';
import '../drawable_entities/graphic/vector/vector_entity.dart';
import '../drawable_entities/graphic/vector/figure_stroke.dart';
import '../drawable_entities/graphic/vector/text_num.dart';

import 'shadow_renderer.dart';
import 'marching_ants.dart';

class StrokeRenderer {
  static void drawStroke(
    Canvas canvas,
    GraphicEntity stroke,
    bool isNeedAddAnts,
  ) {
    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    if (!stroke.isVisible()) return;

    // === Растр ===
    if (stroke is CopiedRegion) {
      if (stroke.end == null) return;
      final destRect = Rect.fromPoints(
        stroke.start + stroke.getTotalTranslation(),
        stroke.end! + stroke.getTotalTranslation(),
      );
      if (stroke.image != null) {
        canvas.drawImageRect(
          stroke.image!,
          Rect.fromLTWH(
            0,
            0,
            stroke.image!.width.toDouble(),
            stroke.image!.height.toDouble(),
          ),
          destRect,
          Paint(),
        );
      }
      if (isNeedAddAnts) {
        final antsPath = Path()..addRect(destRect);
        MarchingAnts.draw(canvas, antsPath, padding: 0);
      }
    }
    // === Текст ===
    else if (stroke is TextStroke) {
      if (stroke is TextNum) {
        paint.color = stroke.color;
        paint.strokeWidth = stroke.size / 10;

        Path path = stroke.path;

        paint.style = PaintingStyle.stroke;

        if (stroke.shadowEnabled) {
          ShadowRenderer.drawShadow(canvas, path, paint, false);
        }

        canvas.drawPath(path, paint);
      }

      if (stroke.shadowEnabled) {
        ShadowRenderer.drawTextShadow(canvas, stroke);
      }
      final paragraph = stroke.paragraph;
      canvas.drawParagraph(
        paragraph,
        stroke.start + stroke.getTotalTranslation(),
      );
      if (isNeedAddAnts) {
        MarchingAnts.draw(canvas, stroke.path);
      }
    }
    // === Векторные ===
    else if (stroke is VectorEntity) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.size;

      Path path = stroke.path;

      if (stroke is FigureStroke &&
          (stroke.type == 'arrow' || stroke.type == 'filled_square')) {
        paint.style = PaintingStyle.fill;
      } else {
        paint.style = PaintingStyle.stroke;
      }

      if (stroke.shadowEnabled) {
        final isFill =
            stroke is FigureStroke &&
            (stroke.type == 'arrow' || stroke.type == 'filled_square');
        ShadowRenderer.drawShadow(canvas, path, paint, isFill);
      }

      canvas.drawPath(path, paint);

      if (isNeedAddAnts) {
        MarchingAnts.draw(canvas, path, padding: stroke.size / 2);
      }
    }
  }
}
