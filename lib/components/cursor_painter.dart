import 'package:flutter/material.dart';

class CursorPainter extends CustomPainter {
	final Color color;

	CursorPainter(this.color);

	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()
			..color = color
			..style = PaintingStyle.fill;

		canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) {
		return false;
	}
}
