import 'dart:math';
import 'dart:ui';

import 'vector_entity.dart';
import '../filled_hit.dart';

class FigureStroke extends VectorEntity with FilledHit {
  final Offset _start;
  Offset? _end;

  final String _type;

  FigureStroke(
    this._start,
    this._end,
    Color color,
    double size,
    this._type,
    bool shadowEnabled,
  ) : super(color, size, shadowEnabled);

  String get type => _type;
  Offset get start => _start;
  Offset? get end => _end;

  @override
  void onChanged() {
    generatePath();
  }

  void setEnd(Offset point) {
    _end = point;
    onChanged();
  }

  @override
  void generatePath() {
    final path = Path();

    if (_end == null) setPath(path);

    final t = getTotalTranslation();
    final s = _start + t;
    final e = _end! + t;

    if (type == 'arrow') {
      final double totalLength = (e - s).distance;
      final double angle = atan2(e.dy - s.dy, e.dx - s.dx);

      double multiple = 1;
      if (totalLength / size < 6) multiple = totalLength / size / 6;

      final double arrowHeadLength = size * multiple * 3;
      final double bodyWidth = size * multiple * 1;

      final base = Offset(
        e.dx - arrowHeadLength * cos(angle),
        e.dy - arrowHeadLength * sin(angle),
      );

      final headLeft = Offset(
        base.dx - bodyWidth * 0.4 * sin(angle),
        base.dy + bodyWidth * 0.4 * cos(angle),
      );
      final headRight = Offset(
        base.dx + bodyWidth * 0.4 * sin(angle),
        base.dy - bodyWidth * 0.4 * cos(angle),
      );

      final tipLeft = Offset(
        e.dx - 1.8 * arrowHeadLength * cos(angle - pi / 8),
        e.dy - 1.8 * arrowHeadLength * sin(angle - pi / 8),
      );
      final tipRight = Offset(
        e.dx - 1.8 * arrowHeadLength * cos(angle + pi / 8),
        e.dy - 1.8 * arrowHeadLength * sin(angle + pi / 8),
      );

      path.moveTo(s.dx, s.dy);
      path.lineTo(headLeft.dx, headLeft.dy);
      path.lineTo(tipLeft.dx, tipLeft.dy);
      path.lineTo(e.dx, e.dy);
      path.lineTo(tipRight.dx, tipRight.dy);
      path.lineTo(headRight.dx, headRight.dy);
      path.lineTo(s.dx, s.dy);
      path.close();
    } else if (type == 'square' || type == 'filled_square') {
      final left = min(s.dx, e.dx);
      final top = min(s.dy, e.dy);
      final right = max(s.dx, e.dx);
      final bottom = max(s.dy, e.dy);
      path.addRect(Rect.fromLTRB(left, top, right, bottom));
    } else if (type == 'oval') {
      final left = min(s.dx, e.dx);
      final top = min(s.dy, e.dy);
      final right = max(s.dx, e.dx);
      final bottom = max(s.dy, e.dy);
      path.addOval(Rect.fromLTRB(left, top, right, bottom));
    }
    setPath(path);
  }

  @override
  bool containsPoint(Offset point) {
    if (!isVisible() || _end == null) return false;

    if (type == 'filled_square') return containsInRect(point);

    final path = this.path;
    final bounds = path.getBounds().inflate(size);
    if (!bounds.contains(point)) return false;

    final step = max(1.0, size / 2);
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += step) {
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos != null && (pos - point).distance <= size / 2) return true;
      }
    }

    return false;
  }
}
