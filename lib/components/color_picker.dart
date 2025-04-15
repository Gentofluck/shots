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

	@override
	Widget build(BuildContext context) {
		Color tempColor = initialColor;

		return AlertDialog(
			title: const Text('Выберите цвет'),
			content: SingleChildScrollView(
				child: ColorPicker(
				pickerColor: tempColor,
				onColorChanged: (color) {
					tempColor = color;
				},
				showLabel: true,
				pickerAreaHeightPercent: 0.8,
				),
			),
			actions: [
				TextButton(
					onPressed: () => Navigator.of(context).pop(),
					child: const Text('Отмена'),
				),
				TextButton(
					onPressed: () {
						onColorChanged(tempColor);
						Navigator.of(context).pop();
					},
					child: const Text('Применить'),
				),
			],
		);
	}
}
