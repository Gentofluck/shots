import '../graphic_entity.dart';
import 'dart:ui' as ui;

abstract class RasterEntity extends GraphicEntity {
  ui.Image? _image;
  RasterEntity(this._image) : super();

  ui.Image? get image => _image;

  void setImage(ui.Image image) {
    _image = image;
  }
}
