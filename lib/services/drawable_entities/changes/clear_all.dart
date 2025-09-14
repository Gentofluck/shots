import '../drawable_entity.dart';
import '../graphic/graphic_entity.dart';

class ClearAll extends DrawableEntity {
  final List<GraphicEntity> _clearedStrokes;

  ClearAll(List<DrawableEntity> strokes) : _clearedStrokes = [] {
    for (final stroke in strokes) {
      if (stroke is GraphicEntity) {
        stroke.createInvisible();
        _clearedStrokes.add(stroke);
      }
    }
  }

  void undo() {
    for (final stroke in _clearedStrokes) {
      stroke.undoVisible();
    }
  }

  void redo() {
    for (final stroke in _clearedStrokes) {
      stroke.redoVisible();
    }
  }
}
