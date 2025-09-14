import 'dart:ui';
import '../graphic_entity.dart';

abstract class VectorEntity extends GraphicEntity {
  final Color _color;
  final double _size;
  final bool _shadowEnabled;
  Path _path;

  VectorEntity(this._color, this._size, this._shadowEnabled)
    : _path = Path(),
      super();

  void setPath(Path path) {
    _path = path;
  }

  Color get color => _color;
  double get size => _size;
  bool get shadowEnabled => _shadowEnabled;

  Path get path => _path;

  void generatePath();
}
