import 'dart:math';
import 'dart:ui';
import 'vector_entity.dart';

class Stroke extends VectorEntity {
  List<Offset> _points;
  Stroke(this._points, Color color, double size, bool shadowEnabled)
    : super(color, size, shadowEnabled);

  List<Offset> get points => _points;

  @override
  void onChanged() {
    generatePath();
  }

  void setPoints(List<Offset> points) {
    _points = points;
    onChanged();
  }

  void addPoint(Offset point, bool isShiftPressed) {
    if (_points.length > 3 && isShiftPressed) {
      _points
        ..removeRange(_points.length - 3, _points.length)
        ..addAll([point, point]);
    } else {
      _points.add(point);
    }
    onChanged();
  }

  @override
  void generatePath() {
    final path = Path();
    if (points.isEmpty) return setPath(path);

    final t = getTotalTranslation();
    final pts = points.map((p) => p + t).toList();

    if (pts.length < 3) {
      path.moveTo(pts[0].dx, pts[0].dy);
      path.quadraticBezierTo(pts[0].dx, pts[0].dy, pts[0].dx, pts[0].dy);
      return setPath(path);
    }

    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 2; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final control = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, control.dx, control.dy);
    }
    print("generate");
    return setPath(path);
  }

  @override
  bool containsPoint(Offset point) {
    if (!isVisible()) return false;
    final path = this.path;

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
