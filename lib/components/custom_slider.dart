import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RectangularSliderThumbShape extends SliderComponentShape {
	final double width;
	final double height;
	final double pressedElevation;
	
	const RectangularSliderThumbShape({
		this.width = 12.0,
		this.height = 24.0,
		this.pressedElevation = 4.0,
	});

	@override
	Size getPreferredSize(bool isEnabled, bool isDiscrete) {
		return Size(width, height);
	}

	@override
	void paint(
		PaintingContext context,
		Offset center, {
		required Animation<double> activationAnimation,
		required Animation<double> enableAnimation,
		required bool isDiscrete,
		required TextPainter labelPainter,
		required RenderBox parentBox,
		required SliderThemeData sliderTheme,
		required TextDirection textDirection,
		required double value,
		required double textScaleFactor,
		required Size sizeWithOverflow,
	}) {
		final Canvas canvas = context.canvas;
		final rect = Rect.fromCenter(
			center: center,
			width: width,
			height: height,
		);
		
		final fillPaint = Paint()
		..color = Color(0xFF484848)
		..style = PaintingStyle.fill;

		
		canvas.drawRRect(
			RRect.fromRectAndRadius(rect, Radius.circular(4.0)),
			fillPaint,
		);

	}
}

class CustomSlider extends StatelessWidget {
	final int value;
	final Function(double) onChanged;

	const CustomSlider({
		Key? key,
		required this.value,
		required this.onChanged,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			height: 24,
			child: Stack(
				children: [
					Positioned.fill(
						child: SizedBox(
							height: 4, 
							child: SvgPicture.asset(
								'assets/toolbar/slider_track.svg',
							),
						),
					),

					Positioned.fill(
						child: SliderTheme(
							data: SliderTheme.of(context).copyWith(
								trackHeight: 0.0,
								activeTrackColor: Colors.transparent,
    							inactiveTrackColor: Colors.transparent,
								thumbShape: const RectangularSliderThumbShape(
									width: 10.0,
									height: 24.0,
								),

								overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
							),
							child: Slider(
								value: value.toDouble(),
								min: 1,
								max: 100,
								divisions: 100,
								onChanged: onChanged,
							),
						),
					),
				],
			),
		);
	}
}