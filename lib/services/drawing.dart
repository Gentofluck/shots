import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'drawable_entities.dart';

class DrawingService {
	List<DrawableEntity> _drawingHistory = [];
	List<DrawableEntity> _drawingHistoryRedo = [];
	DrawableEntity? _currentStroke;  

	Color _brushColor = Colors.black;  
	int _brushSize = 0;  
	bool _shadowEnabled = false;
	bool _layerModifierEnabled = false;
	Offset startTranslation = Offset(0, 0);

	void setBrushColor(Color color) {
		_brushColor = color;
	}
	void setBrushSize(int size) {
		_brushSize = size;
	}
	void setShadowEnabled(bool shadowEnabled){
		_shadowEnabled = shadowEnabled;
	}
	void setLayerModifierEnabled (bool isLayerModifierEnabled){
		_layerModifierEnabled = isLayerModifierEnabled;
	}
	
	Color get brushColor => _brushColor;
	int get brushSize => _brushSize;
	DrawableEntity? get currentStroke => _currentStroke;


	TextStroke? extractTextStroke(DrawableEntity? entity, bool modifier) {
		return switch (entity) {
			TextStroke s => s,
			StrokeChange t when modifier && t.stroke is TextStroke => t.stroke as TextStroke,
			_ => null,
		};
	}

	DrawableStroke? extractDrawableStroke(DrawableEntity? entity) {
		return switch (entity) {
			DrawableStroke s => s,
			StrokeChange t when _layerModifierEnabled => t.stroke,
			_ => null,
		};
	}

	Offset getTextSize (text) {
		final textPainter = TextPainter(
			text: TextSpan(
				text: text,
				style: TextStyle(
					fontSize: _brushSize.toDouble() * 5,
					color: Colors.black, 
				),
			),
			textDirection: TextDirection.ltr,
		);

		textPainter.layout(); 

		return Offset(textPainter.width, textPainter.height);
	}

	//Получения текстового элемента по точке
	//Если модификатор выключен то достаем первый написаный
	//В противном случае - первый отредактированный 
	TextStroke? getTextByPoint(Offset point) {
		TextStroke? stroke = extractTextStroke(_currentStroke, _layerModifierEnabled);

		if (stroke != null && stroke.isVisible() && stroke.isPointInText(point)) {
			return stroke;
		}

		for (final entity in _drawingHistory.reversed) {
			stroke = extractTextStroke(entity, _layerModifierEnabled);

			if (stroke != null && stroke.isVisible() && stroke.isPointInText(point)) {
				
				return stroke;
			}
		}

		return null;
	}
	

	bool isPointClose (DrawableStroke stroke, Offset point) {
		if (!stroke.isVisible()) return false;
		if (stroke is TextStroke ) {
			if (stroke.isPointInText(point)) return true;
		}
		else if (stroke is FigureStroke && stroke.type == 'filled_square') {
			if (stroke.end == null) return false;

			final totalTranslation = stroke.getTotalTranslation();
  			final adjustedPoint = point - totalTranslation;
    
			final start = stroke.start;
			final end = stroke.end!;
			final left = min(start.dx, end.dx);
			final top = min(start.dy, end.dy);
			final right = max(start.dx, end.dx);
			final bottom = max(start.dy, end.dy);
			
			return adjustedPoint.dx >= left && adjustedPoint.dx <= right &&
				adjustedPoint.dy >= top && adjustedPoint.dy <= bottom;
		}
		else if (stroke is DrawableStroke) {
			Path path = getPath(stroke);

			if (path != null) {
				for (ui.PathMetric pathMetric in path.computeMetrics()) {
					for (double i = 0; i < pathMetric.length; i++) {
						final pathPoint = pathMetric.getTangentForOffset(i)?.position;

						if (pathPoint != null) {
							double distance = (pathPoint - point).distance;

							if (distance <= stroke.size / 2) return true;  
						}
					}
				}
			}
		}
		return false;
	}


	DrawableStroke? getPathByPoint(Offset point) {
		DrawableStroke? stroke = extractDrawableStroke(_currentStroke);

		if (stroke != null && stroke.isVisible() && isPointClose(stroke, point)) {
			return stroke;
		}

		for (var entity in _drawingHistory.reversed) {
			stroke = extractDrawableStroke(entity);
			if (stroke != null && stroke.isVisible() && isPointClose(stroke, point)) return stroke;
		}

		return null;
	}

	void createTextEditor (TextStroke textStroke)
	{
		if (_currentStroke != null)				
		{
			_drawingHistory.add(_currentStroke!);
			_currentStroke = null;
		} 
		_currentStroke = StrokeChange('text', textStroke);
	}

	void addText(String? text) {
		TextStroke? stroke = extractTextStroke(_currentStroke, true);
		
		if (stroke != null) stroke.updateCurrentText(text!, getTextSize(text));
	}

	void addPoint(Offset point, String tool, bool isShiftPressed) {
		TextStroke? stroke = extractTextStroke(_currentStroke, true);

		// Пояснить почему так
		if (_currentStroke != null && 
		((_currentStroke is TextStroke) && !(_currentStroke is TextNum)) ||
		(tool!='text_num' && (_currentStroke is TextNum))
		)				
		{
			_drawingHistory.add(_currentStroke!);
			_currentStroke = null;
		} 
		
		switch (tool)
		{
			case 'pen':
				_currentStroke ??= Stroke([], _brushColor, _brushSize.toDouble(), _shadowEnabled);
				if (((_currentStroke as Stroke).points.length > 3) && isShiftPressed) 
				{
					(_currentStroke as Stroke).points.removeLast();
					(_currentStroke as Stroke).points.removeLast();
					(_currentStroke as Stroke).points.removeLast();
					(_currentStroke as Stroke).points.add(point);
					(_currentStroke as Stroke).points.add(point);
				}
				(_currentStroke as Stroke).points.add(point);
				break;
			case 'text_num':
				int currentNum = 0;
				if(_currentStroke != null && _currentStroke is TextNum)
				{
					currentNum = int.parse((_currentStroke as TextNum).currentText);
					_drawingHistory.add(_currentStroke!);
				}
				String afterNum = (currentNum + 1).toString();
				Offset textSize = getTextSize(afterNum);
				_currentStroke = TextNum([afterNum], point - textSize / 2, [getTextSize(afterNum)], _brushColor, _brushSize.toDouble() * 5, _shadowEnabled);
				_drawingHistoryRedo = [];
				break;
			case 'eraser':
				DrawableStroke? stroke = getPathByPoint(point);
				if (stroke != null) _drawingHistory.add(StrokeChange('eraser', stroke!));
			case 'text':
				_currentStroke = TextStroke([''], point, [point], _brushColor, _brushSize.toDouble() * 5, _shadowEnabled);
				_drawingHistoryRedo = [];
				break;
			case 'move':
				if (_currentStroke != null && (_currentStroke is StrokeChange) && (_currentStroke as StrokeChange).property == 'position') {
					if ((_currentStroke as StrokeChange).stroke.translations.isEmpty) return;
					(_currentStroke as StrokeChange).stroke.addTranslation(point, startTranslation);
				} else {
					DrawableStroke? stroke = getPathByPoint(point);

					if (stroke == null) return;

					startTranslation = point;
					_currentStroke = StrokeChange('position', stroke);
				}
				break;
			default:
				if (_currentStroke != null && (_currentStroke is FigureStroke)) 
				{
					if (isShiftPressed) {
						double dx = point.dx - (_currentStroke as FigureStroke).start.dx;
						double dy = point.dy - (_currentStroke as FigureStroke).start.dy;

						double minDiff = dx.abs() < dy.abs() ? dx.abs() : dy.abs();
						point = Offset((_currentStroke as FigureStroke).start.dx + minDiff * (dx < 0 ? -1 : 1), (_currentStroke as FigureStroke).start.dy + minDiff * (dy < 0 ? -1 : 1));
					}
					(_currentStroke as FigureStroke).end = point;
				}
				else _currentStroke = FigureStroke(point, null, _brushColor, _brushSize.toDouble(), tool, _shadowEnabled);
		}
	}

	void endDrawing(Offset end, String tool) {
		if (tool == 'text')return;
		
		switch (tool)
		{
			case 'pen':
				if ((_currentStroke as Stroke).points.isNotEmpty) 
				{
					_drawingHistory.add(Stroke(List.from((_currentStroke as Stroke).points), _brushColor, _brushSize.toDouble(), _shadowEnabled));
					_currentStroke = null;
					_drawingHistoryRedo = [];
				}
				break;
			case 'move':
				if (_currentStroke != null) {
					_drawingHistory.add(_currentStroke!);
					_drawingHistoryRedo = [];
				}
				_currentStroke = null;
				break;
			default: 
				_drawingHistory.add(FigureStroke((_currentStroke as FigureStroke).start, (_currentStroke as FigureStroke).end, _brushColor, _brushSize.toDouble(), tool, _shadowEnabled));
				_currentStroke = null;
				_drawingHistoryRedo = [];
		}
	}

	double getArrowMultiple(double totalLength, double size ) {
		double multiple = 1;

		if (totalLength / size < 6)
		{
			multiple = totalLength / size / 6;
		}

		return multiple;
	}

	void drawShadow(Canvas canvas, Path path, Paint paint, bool isFill) {
		if (paint.color == Colors.transparent) return;

		double strokeWidth = paint.strokeWidth;
		
		final shadowPaint = Paint()
			..color = Colors.black.withOpacity(0.2)  
			..strokeWidth = strokeWidth
			..strokeCap = StrokeCap.round
			..style = isFill ? PaintingStyle.fill : PaintingStyle.stroke;

		double shadowOffset = pow(strokeWidth, 0.3) as double;


		final shadowPath = path.shift(Offset(shadowOffset, shadowOffset));  
		canvas.drawPath(shadowPath, shadowPaint);

		
		for (int i = 1; i <= 8; i++) {
   			final blurredShadowPath = shadowPath.shift(Offset(i * shadowOffset / 5, i * shadowOffset / 5));			
			shadowPaint.color = Colors.black.withOpacity(0.2 - i * 0.02);
			canvas.drawPath(blurredShadowPath, shadowPaint);
		}

	}

	void drawTextShadow(Canvas canvas, TextStroke stroke) {
		if (stroke.color == Colors.transparent) return;

		final basePos = stroke.start + stroke.getTotalTranslation();
		final double shadowOffset = stroke.size / 8; 

		ui.Paragraph buildParagraph(Color color) {
			final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
				textAlign: TextAlign.left,
				fontSize: stroke.size,
			))
			..pushStyle(ui.TextStyle(color: color))
			..addText(stroke.currentText);

			final paragraph = builder.build();
			paragraph.layout(ui.ParagraphConstraints(width: double.infinity));
			return paragraph;
		}

		for (int i = 0; i <= 8; i++) {
			final opacity = 0.2 - i * 0.02;
			final offset = Offset(i * shadowOffset / 20, i * shadowOffset / 20);
			final paragraph = buildParagraph(Colors.black.withOpacity(opacity.clamp(0.0, 1.0)));
			canvas.drawParagraph(paragraph, basePos + offset);
		}
	}

	void drawArrow (Path path, FigureStroke stroke, Offset start, Offset end) {
		double totalLength = (end - start).distance;
		double angle = atan2(end.dy - start.dy, end.dx - start.dx);

		double multiple = getArrowMultiple(totalLength, stroke.size);

		double arrowHeadLength = stroke.size * multiple * 3;
		double bodyWidth = stroke.size * multiple * 1; 

		Offset tail = start;

		Offset base = Offset(
			end.dx - arrowHeadLength * cos(angle),
			end.dy - arrowHeadLength * sin(angle),
		);

		Offset headLeft = Offset(
			base.dx - bodyWidth * 0.4 * sin(angle),
			base.dy + bodyWidth * 0.4 * cos(angle),
		);
		Offset headRight = Offset(
			base.dx + bodyWidth * 0.4 * sin(angle),
			base.dy - bodyWidth * 0.4 * cos(angle),
		);

		Offset bodyStart = Offset(
			tail.dx,
			tail.dy,
		);

		Offset tipLeft = Offset(
			end.dx - 1.8 * arrowHeadLength * cos(angle - pi / 8),
			end.dy - 1.8 * arrowHeadLength * sin(angle - pi / 8),
		);
		Offset tipRight = Offset(
			end.dx - 1.8 * arrowHeadLength * cos(angle + pi / 8),
			end.dy - 1.8 * arrowHeadLength * sin(angle + pi / 8),
		);

		path.moveTo(bodyStart.dx, bodyStart.dy); 
		path.lineTo(headLeft.dx, headLeft.dy);
		path.lineTo(tipLeft.dx, tipLeft.dy);
		path.lineTo(end.dx, end.dy); 
		path.lineTo(tipRight.dx, tipRight.dy); 
		path.lineTo(headRight.dx, headRight.dy); 
		path.lineTo(bodyStart.dx, bodyStart.dy); 
		path.close(); 
	}


	Path getPath(DrawableStroke stroke) {
		Path path = Path();

		List<Offset> applyTranslations(List<Offset> points, Offset translation) {
			return points.map((p) => p + translation).toList();
		}

		if (stroke is Stroke && stroke.isVisible()) {
			if (stroke.points.isEmpty) return path;

			List<Offset> points = applyTranslations(stroke.points, stroke.getTotalTranslation());

			if (points.length < 3) {
				path.moveTo(points[0].dx, points[0].dy);
				path.quadraticBezierTo(points[0].dx, points[0].dy, points[0].dx, points[0].dy);
			} else {
				path.moveTo(points[0].dx, points[0].dy);
				for (int i = 0; i < points.length - 2; i++) {
					final p0 = points[i];
					final p1 = points[i + 1];
					//final p2 = points[i + 2];
					final controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

					path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
				}
			}
		} 

		else if (stroke is FigureStroke && stroke.isVisible()) {
			if (stroke.start != null && stroke.end != null) {
				Offset start = stroke.start! + stroke.getTotalTranslation();
				Offset end = stroke.end! + stroke.getTotalTranslation();

				if (stroke.type == 'arrow') {
					drawArrow(path, stroke, start, end);
				}
				else if (stroke.type == 'square' || stroke.type == 'filled_square') {
					double left = min(start.dx, end.dx);
					double top = min(start.dy, end.dy);
					double right = max(start.dx, end.dx);
					double bottom = max(start.dy, end.dy);

					path.addRect(Rect.fromLTRB(left, top, right, bottom));
				} 
				else if (stroke.type == 'oval') {
					double left = min(start.dx, end.dx);
					double top = min(start.dy, end.dy);
					double right = max(start.dx, end.dx);
					double bottom = max(start.dy, end.dy);

					path.addOval(Rect.fromLTRB(left, top, right, bottom));
				}
			}
		}

		return path;
	}

	List<DrawableStroke> getFilteredStrokes() {
		List<DrawableEntity> unitedStrokes = [
			..._drawingHistory,
			if (_currentStroke != null) _currentStroke as DrawableEntity
		];

		int lastClearIndex = unitedStrokes.lastIndexWhere((e) => e is ClearAll);

		if (lastClearIndex != -1) {
			unitedStrokes = unitedStrokes.sublist(lastClearIndex + 1);
		}

		List<DrawableStroke> filteredStrokes = [];
		Set<DrawableStroke> usedStrokes = {};

		for (var stroke in unitedStrokes) {
			if (_layerModifierEnabled && stroke is StrokeChange) {
				if (usedStrokes.contains(stroke.stroke)) {
					filteredStrokes.removeWhere((item) => item == stroke.stroke);
				}
				filteredStrokes.add(stroke.stroke);
				usedStrokes.add(stroke.stroke);
			} else if (stroke is DrawableStroke) {
				filteredStrokes.add(stroke);
				usedStrokes.add(stroke);
			}
		}

		return filteredStrokes;
	}

	void removeLastEditing(lastStroke) {
		if (lastStroke is StrokeChange || lastStroke is ClearAll) {
			lastStroke.undo();
		}
	}

	void redoLastEditing(lastStroke) {
		if (lastStroke is StrokeChange || lastStroke is ClearAll) {
			lastStroke.redo();
		}
	}

	void undo() {
		if (_currentStroke != null)
		{
			removeLastEditing(_currentStroke);
			_drawingHistoryRedo.add(_currentStroke!);
			_currentStroke = null;
		}
		else if(_drawingHistory.isNotEmpty)
		{
			removeLastEditing(_drawingHistory.last);
			_drawingHistoryRedo.add(_drawingHistory.last!);
			_drawingHistory.removeLast();
		}
	}

	void redo() {
		if (_drawingHistoryRedo != null && _drawingHistoryRedo.length > 0)
		{
			redoLastEditing(_drawingHistoryRedo.last);
			_drawingHistory.add(_drawingHistoryRedo.last);
			_drawingHistoryRedo.removeLast();
		}
	}

	void clear() {
		if (_currentStroke != null) _drawingHistory.add(_currentStroke!);
		_drawingHistory.add(ClearAll(_drawingHistory));
		_drawingHistoryRedo = [];
		_currentStroke = null;
	}

	void clearCanvas() {
		_drawingHistory.clear();
		_drawingHistoryRedo.clear();
		_currentStroke = null;
	}
	
	Future<Uint8List> generateDrawingImage(Size size, {double scaleX = 1.0, double scaleY = 1.0}) async {
		final recorder = ui.PictureRecorder();
		final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

		final paint = Paint()
			..strokeCap = StrokeCap.round
			..style = PaintingStyle.stroke;

		canvas.scale(scaleX, scaleY);

		List<DrawableStroke> strokes = getFilteredStrokes();

		for (var stroke in strokes) {
			if (stroke is TextStroke && stroke.isVisible()) {
				final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
					textAlign: TextAlign.left,
					fontSize: stroke.size,
				))
				..pushStyle(ui.TextStyle(color: stroke.color))
				..addText((stroke as TextStroke).currentText);

				if (stroke.shadowEnabled)
				{
					drawTextShadow(canvas, stroke);
				}

				final paragraph = paragraphBuilder.build();
				paragraph.layout(ui.ParagraphConstraints(width: double.infinity));

				canvas.drawParagraph(paragraph, stroke.start + stroke.getTotalTranslation()); 
			} 
			else if (stroke is DrawableStroke && stroke.isVisible()) {		
				paint.color = stroke.color;
				paint.strokeWidth = stroke.size;
				Path path = getPath(stroke);

				if ((stroke is FigureStroke) && (stroke.type == 'arrow' || stroke.type == 'filled_square')) {
					paint.style = PaintingStyle.fill;
				}
				else 
				{
					paint.style = PaintingStyle.stroke;
				}
				
				if (stroke.shadowEnabled) {
					if (stroke is FigureStroke)
						drawShadow(canvas, path, paint, (stroke as FigureStroke).type == 'arrow' || (stroke as FigureStroke).type == 'filled_square');
					else 
						drawShadow(canvas, path, paint, false);
				}

				canvas.drawPath(path, paint);
			}
		}

		final picture = recorder.endRecording();
		final img = await picture.toImage(size.width.toInt(), size.height.toInt());

		final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

		return byteData!.buffer.asUint8List();
 	}
}


class DrawingPainter extends CustomPainter {
	final DrawingService drawingService;

	DrawingPainter(this.drawingService);

	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()
			..strokeCap = StrokeCap.round
			..style = PaintingStyle.stroke;

		List<DrawableStroke> strokes = drawingService.getFilteredStrokes();

		for (var stroke in strokes) {
			if (stroke is TextStroke && stroke.isVisible()) {
				final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
					textAlign: TextAlign.left,
					fontSize: stroke.size,
				))
				..pushStyle(ui.TextStyle(color: stroke.color))
				..addText((stroke as TextStroke).currentText);

				if (stroke.shadowEnabled)
				{
					drawingService.drawTextShadow(canvas, stroke);
				}

				final paragraph = paragraphBuilder.build();
				paragraph.layout(ui.ParagraphConstraints(width: double.infinity));

				canvas.drawParagraph(paragraph, stroke.start + stroke.getTotalTranslation()); 
			} 
			else if (stroke is DrawableStroke && stroke.isVisible()) {		
				paint.color = stroke.color;
				paint.strokeWidth = stroke.size;
				Path path = drawingService.getPath(stroke);

				if ((stroke is FigureStroke) && (stroke.type == 'arrow' || stroke.type == 'filled_square')) {
					paint.style = PaintingStyle.fill;
				}
				else 
				{
					paint.style = PaintingStyle.stroke;
				}
				
				if (stroke.shadowEnabled) {
					if (stroke is FigureStroke)
						drawingService.drawShadow(canvas, path, paint, (stroke as FigureStroke).type == 'arrow' || (stroke as FigureStroke).type == 'filled_square');
					else 
						drawingService.drawShadow(canvas, path, paint, false);
				}

				canvas.drawPath(path, paint);
			}
		}
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) {
		return true;
	}
}
