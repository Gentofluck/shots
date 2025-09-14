import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'vector_entity.dart';

class TextStroke extends VectorEntity {
  final Offset _start;
  final List<String> _text;
  final List<Offset> _endOffsets;

  int _currentTextChange;
  ui.Paragraph? _paragraph;

  ui.Paragraph get paragraph => _paragraph!;
  List<String> get text => _text;
  List<Offset> get endOffsets => _endOffsets;
  Offset get start => _start;

  @override
  void onChanged() {
    generateParagraph();
    generatePath();
  }

  TextStroke(
    this._text,
    this._start,
    this._endOffsets,
    Color color,
    double size,
    bool shadowEnabled,
  ) : _currentTextChange = 0,
      _paragraph = null,
      super(color, size, shadowEnabled) {
    generateParagraph();
  }

  void createTextChange() {
    _currentTextChange++;

    if (_currentTextChange < _text.length) {
      _text.removeRange(_currentTextChange, _text.length);
      _endOffsets.removeRange(_currentTextChange, _endOffsets.length);
    }

    _text.add(_text[_currentTextChange - 1]);
    _endOffsets.add(_endOffsets[_currentTextChange - 1]);

    onChanged();
  }

  void updateCurrentText(String newText, Offset newEnd) {
    _text[_currentTextChange] = newText;
    _endOffsets[_currentTextChange] = newEnd;

    onChanged();
  }

  void undoTextChange() {
    if (_currentTextChange > 0) {
      _currentTextChange--;
      onChanged();
    }
  }

  void redoTextChange() {
    if (_currentTextChange < _text.length - 1) {
      _currentTextChange++;
      onChanged();
    }
  }

  String get currentText {
    if (_currentTextChange < _text.length) return _text[_currentTextChange];
    return '';
  }

  Offset get currentEndOffset {
    if (_currentTextChange < _endOffsets.length) {
      return _endOffsets[_currentTextChange];
    }
    return Offset.zero;
  }

  @override
  void generatePath() {
    if (_paragraph == null) return;

    final translation = getTotalTranslation();
    final currentStart = _start + translation;

    final currentEnd = _start + currentEndOffset + translation;

    final left = min(currentStart.dx, currentEnd.dx);
    final top = min(currentStart.dy, currentEnd.dy);
    final right = max(currentStart.dx, currentEnd.dx);
    final bottom = max(currentStart.dy, currentEnd.dy);

    final bounds = Rect.fromLTRB(left, top, right, bottom);
    setPath(Path()..addRect(bounds));
  }

  void generateParagraph() {
    final textStyle = ui.TextStyle(color: color, fontSize: size);

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: size,
    );

    final builder =
        ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(textStyle)
          ..addText(currentText);

    final paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));

    _paragraph = paragraph;
  }

  @override
  bool containsPoint(Offset point) {
    if (_text.isEmpty || _endOffsets.isEmpty) return false;

    final translation = getTotalTranslation();
    final currentStart = _start + translation;
    final currentEnd = _start + currentEndOffset + translation;

    final left = min(currentStart.dx, currentEnd.dx);
    final top = min(currentStart.dy, currentEnd.dy);
    final right = max(currentStart.dx, currentEnd.dx);
    final bottom = max(currentStart.dy, currentEnd.dy);

    return point.dx >= left &&
        point.dx <= right &&
        point.dy >= top &&
        point.dy <= bottom;
  }
}
