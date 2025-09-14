import '../graphic/graphic_entity.dart';

import '../drawable_entity.dart';
import '../graphic/vector/text_stroke.dart';

class StrokeChange extends DrawableEntity {
  final String property;
  final GraphicEntity stroke;

  StrokeChange(this.property, this.stroke) {
    if (property == 'position') {
      stroke.createTranslation();
    } else if (property == 'text') {
      (stroke as TextStroke).createTextChange();
    } else if (property == 'eraser') {
      stroke.createInvisible();
    }
  }

  void undo() {
    if (property == 'position') {
      stroke.undoTranslation();
    } else if (property == 'text') {
      (stroke as TextStroke).undoTextChange();
    } else if (property == 'eraser') {
      stroke.undoVisible();
    }
  }

  void redo() {
    if (property == 'position') {
      stroke.redoTranslation();
    } else if (property == 'text') {
      (stroke as TextStroke).redoTextChange();
    } else if (property == 'eraser') {
      stroke.redoVisible();
    }
  }
}
