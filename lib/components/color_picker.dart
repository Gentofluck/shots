import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatelessWidget {
	final Color initialColor;
	final ValueChanged<Color> onColorChanged;

	const ColorPickerDialog({
		super.key,
		required this.initialColor,
		required this.onColorChanged,
	});

	static const TextStyle _baseTextStyle = TextStyle(
		fontFamily: 'IBMPlexMono',
		fontWeight: FontWeight.w400,
		fontSize: 12,
		color: Color(0xFF3C3C3C),
	);

	@override
	Widget build(BuildContext context) {
		Color tempColor = initialColor;

		return AlertDialog(
			backgroundColor: Colors.white,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(8),
			),
			contentPadding: const EdgeInsets.all(20),
			content: SingleChildScrollView(
				child: ColorPicker(
					pickerColor: tempColor,
					onColorChanged: (color) {
						tempColor = color;
					},
					//showLabel: true,
					pickerAreaHeightPercent: 0.8,
					labelTextStyle: _baseTextStyle.copyWith(
						fontWeight: FontWeight.w500,
						fontSize: 14,
					),
				),
			),
			actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			actions: [
				TextButton(
					style: TextButton.styleFrom(
						foregroundColor: const Color(0xFF3C3C3C),
						textStyle: _baseTextStyle.copyWith(
							fontWeight: FontWeight.w500,
							fontSize: 14,
						),
							shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(4),
						),
						padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
					),
					onPressed: () => Navigator.of(context).pop(),
					child: const Text('Отмена'),
				),
				ElevatedButton(
					style: ElevatedButton.styleFrom(
						backgroundColor: const Color(0xFF425AD0),
						foregroundColor: Colors.white,
						shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(4),
						),
						padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
					),
					onPressed: () {
						onColorChanged(tempColor);
						Navigator.of(context).pop();
					},
					child: Text(
						'Применить',
						style: _baseTextStyle.copyWith(
							color: Colors.white,
							fontWeight: FontWeight.w500,
							fontSize: 14,
						),
					),
				),
			],
		);
	}
}
