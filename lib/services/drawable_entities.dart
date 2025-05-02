import 'dart:ui';
import 'package:flutter/material.dart';

abstract class DrawableEntity {
	DrawableEntity();
}

abstract class DrawableStroke extends DrawableEntity {
	Color color;
	double size;
	bool shadowEnabled;
	List<Offset> translations;
	List<bool> visible;

	int _currentTranslation;
	int _currentVisible; 

	DrawableStroke(this.color, this.size, this.shadowEnabled): translations = [], _currentTranslation = -1, visible = [true], _currentVisible = 0;

	Offset getTotalTranslation() {
		if (_currentTranslation < 0 || _currentTranslation >= translations.length) {
			return Offset.zero;
		}

		return translations[_currentTranslation];
	}

	bool isVisible() {
		return visible[_currentVisible];
	}

	void createTranslation() {

		if (_currentTranslation + 1 < translations.length) {
			translations.removeRange(_currentTranslation + 1, translations.length);
		}

		translations.add(getTotalTranslation());
		_currentTranslation++;
	}

	void addTranslation(Offset point, Offset startTranslation) {
		if (_currentTranslation < 0 || _currentTranslation >= translations.length) return;

		final previous = (_currentTranslation == 0)
			? Offset.zero
			: translations[_currentTranslation - 1];

		translations[_currentTranslation] = previous + (point - startTranslation);
	}

	void createInvisible() {
		if (_currentVisible + 1 < visible.length) {
			visible.removeRange(_currentVisible + 1, visible.length);
		}

		visible.add(false);
		_currentVisible++;
	}

	void undoVisible() {
		_currentVisible--;
	}

	void redoVisible() {
		_currentVisible++;
	}

	void undoTranslation() {
		_currentTranslation--;
	}

	void redoTranslation() {
		_currentTranslation++;
	}
}

class Stroke extends DrawableStroke {
	List<Offset> points;
	Stroke(this.points, Color color, double size, bool shadowEnabled) : super(color, size, shadowEnabled);
}

class FigureStroke extends DrawableStroke {
	Offset start;
	Offset? end;
	String type;
	FigureStroke(this.start, this.end, Color color, double size, this.type, bool shadowEnabled) : super(color, size, shadowEnabled);
}


class TextStroke extends DrawableStroke{
	Offset start;
	List <String> text;
	List <Offset> length;

	int _currentTextChange;

	TextStroke(this.text, this.start, this.length, Color color, double size, bool shadowEnabled) : _currentTextChange = 0, super(color, size, shadowEnabled);

	bool isPointInText(Offset point) {
		if (text.isEmpty || length.isEmpty) return false;

		Offset currentTranslation = getTotalTranslation();
		Offset startPos = start + currentTranslation;
		Offset endPos = length[_currentTextChange] + startPos;

		if (point.dx >= startPos.dx &&
			point.dx <= endPos.dx &&
			point.dy >= startPos.dy &&
			point.dy <= endPos.dy) {
			return true;
		}
		
		return false;
	}

	void createTextChange() {
		_currentTextChange++;

		if (_currentTextChange < text.length) {
			text.removeRange(_currentTextChange, text.length);
			length.removeRange(_currentTextChange, length.length);
		}

		text.add(text[_currentTextChange - 1]);
		length.add(length[_currentTextChange - 1]);
	}

	void updateCurrentText(String newText, Offset newEnd) {
		text[_currentTextChange] = newText;
		length[_currentTextChange] = newEnd;
	}

	void undoTextChange() {
		_currentTextChange--;
	}

	void redoTextChange() {
		_currentTextChange++;
	}

	String get currentText {
		if (_currentTextChange < text.length) {
			return text[_currentTextChange];
		}
			return '';
	}
}

class TextNum extends TextStroke{
	TextNum(List<String> text, Offset start, List<Offset> length, Color color, double size, bool shadowEnabled) : super(text, start, length, color, size, shadowEnabled);
}

class StrokeChange extends DrawableEntity {
	final String property;
	final DrawableStroke stroke;

	StrokeChange(this.property, this.stroke) {
		if (property == 'position') stroke.createTranslation();
		else if (property == 'text') (stroke as TextStroke).createTextChange();
		else if (property == 'eraser') stroke.createInvisible();
	}

	void undo() {
		if (property == 'position') stroke.undoTranslation();
		else if (property == 'text') (stroke as TextStroke).undoTextChange();
		else if (property == 'eraser') stroke.undoVisible();
	}

	void redo() {
		if (property == 'position') stroke.redoTranslation();
		else if (property == 'text') (stroke as TextStroke).redoTextChange();
		else if (property == 'eraser') stroke.redoVisible();
	}
}
class ClearAll extends DrawableEntity {
	final List<DrawableStroke> _clearedStrokes;

	ClearAll(List<DrawableEntity> strokes) : _clearedStrokes = [] {
		for (final stroke in strokes) {
			if (stroke is DrawableStroke) 
			{
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
