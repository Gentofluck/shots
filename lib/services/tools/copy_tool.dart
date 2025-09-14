import 'dart:ui';
import 'dart:math';
import 'drawing_tool.dart';
import '../drawable_entities/main.dart';

class CopyTool extends DrawingTool {
  CopyTool()
    : super(
        name: 'cut',
        color: const Color(0x00000000),
        size: 0,
        shadowEnabled: false,
      );

  @override
  DrawableEntity? onStart(Offset point, DrawableEntity? currentStroke) {
    return CopiedRegion(point);
  }

  @override
  DrawableEntity? onMove(
    Offset point,
    DrawableEntity? currentStroke,
    bool isShiftPressed,
  ) {
    if (currentStroke is! CopiedRegion) return null;

    Offset adjustedPoint = point;

    if (isShiftPressed) {
      double dx = point.dx - currentStroke.start.dx;
      double dy = point.dy - currentStroke.start.dy;

      double minDiff = dx.abs() < dy.abs() ? dx.abs() : dy.abs();
      adjustedPoint = Offset(
        currentStroke.start.dx + minDiff * (dx < 0 ? -1 : 1),
        currentStroke.start.dy + minDiff * (dy < 0 ? -1 : 1),
      );
    }

    currentStroke.setEnd(adjustedPoint);
    return null;
  }

  @override
  DrawableEntity? onEnd(
    Offset point,
    DrawableEntity? currentStroke,
    double pixelRatio, [
    Image? image,
  ]) {
    if (image == null) return null;

    final copiedRegion = currentStroke as CopiedRegion;

    final double leftPx =
        min(copiedRegion.start.dx, (currentStroke.end?.dx)!) * pixelRatio;
    final double topPx =
        min(copiedRegion.start.dy, (currentStroke.end?.dy)!) * pixelRatio;
    final double rightPx =
        max(copiedRegion.start.dx, (currentStroke.end?.dx)!) * pixelRatio;
    final double bottomPx =
        max(copiedRegion.start.dy, (currentStroke.end?.dy)!) * pixelRatio;

    final sourceRect = Rect.fromLTRB(leftPx, topPx, rightPx, bottomPx);

    final imageRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final finalRect = sourceRect.intersect(imageRect);

    if (finalRect.width <= 0 || finalRect.height <= 0) {
      return null;
    }

    final int w = max(1, finalRect.width.ceil());
    final int h = max(1, finalRect.height.ceil());

    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    );

    canvas.drawImageRect(
      image,
      finalRect,
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    copiedRegion.setImage(picture.toImageSync(w, h));

    return currentStroke;
  }
}
