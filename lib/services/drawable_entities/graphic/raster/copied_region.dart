import 'raster_entity.dart';
import 'package:flutter/material.dart';
import '../filled_hit.dart';

class CopiedRegion extends RasterEntity with FilledHit {
  final Offset _start;
  Offset? _end;

  CopiedRegion(this._start) : super(null);

  @override
  Offset get start => _start;
  @override
  Offset? get end => _end;

  void setEnd(Offset end) {
    _end = end;
  }

  @override
  bool containsPoint(Offset point) {
    return containsInRect(point);
  }

  @override
  void onChanged() {}
}
