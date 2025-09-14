import '../drawable_entity.dart';
import 'package:flutter/material.dart';

abstract class GraphicEntity extends DrawableEntity {
  List<Offset> translations;
  List<bool> visible;

  int _currentTranslation;
  int _currentVisible;

  void onChanged();

  GraphicEntity()
    : translations = [Offset.zero],
      _currentTranslation = 0,
      visible = [true],
      _currentVisible = 0;

  Offset getTotalTranslation() {
    if (_currentTranslation < 0 || _currentTranslation >= translations.length) {
      return Offset.zero;
    }

    return translations[_currentTranslation];
  }

  bool isVisible() {
    if (_currentVisible < 0 || _currentVisible >= visible.length) return true;
    return visible[_currentVisible];
  }

  void createTranslation() {
    if (_currentTranslation + 1 < translations.length) {
      translations.removeRange(_currentTranslation + 1, translations.length);
    }

    translations.add(getTotalTranslation());
    _currentTranslation++;

    onChanged();
  }

  void addTranslation(Offset point, Offset startTranslation) {
    if (_currentTranslation < 0 || _currentTranslation >= translations.length) {
      return;
    }

    final previous =
        (_currentTranslation == 0)
            ? Offset.zero
            : translations[_currentTranslation - 1];

    translations[_currentTranslation] = previous + (point - startTranslation);

    onChanged();
  }

  void createInvisible() {
    if (_currentVisible + 1 < visible.length) {
      visible.removeRange(_currentVisible + 1, visible.length);
    }

    visible.add(false);
    _currentVisible++;
    onChanged();
  }

  void undoVisible() {
    _currentVisible--;
    onChanged();
  }

  void redoVisible() {
    _currentVisible++;
    onChanged();
  }

  void undoTranslation() {
    _currentTranslation--;
    onChanged();
  }

  void redoTranslation() {
    _currentTranslation++;
    onChanged();
  }

  bool containsPoint(Offset point);
}
