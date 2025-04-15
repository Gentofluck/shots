import 'package:flutter/material.dart';

class ScreenshotToolbar extends StatelessWidget {
	final TextEditingController brushSizeController;
	final Function(String) onBrushSizeChanged;
	final VoidCallback toggleShadow;
	final bool shadowEnabled;
	final VoidCallback toggleLayerModifier;
	final bool layerModifierEnabled;
	final Function(String tool) onToolSelected;
	final VoidCallback undo;
	final VoidCallback redo;
	final VoidCallback clear;
	final VoidCallback showColorPicker;

	const ScreenshotToolbar({
		super.key,
		required this.brushSizeController,
		required this.onBrushSizeChanged,
		required this.toggleShadow,
		required this.shadowEnabled,
		required this.toggleLayerModifier,
		required this.layerModifierEnabled,
		required this.onToolSelected,
		required this.undo,
		required this.redo,
		required this.clear,
		required this.showColorPicker,
	});

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				SizedBox(
					width: 40,
					child: TextField(
						controller: brushSizeController,
						keyboardType: const TextInputType.numberWithOptions(decimal: true),
						decoration: const InputDecoration(
							hintText: 'Размер',
							border: InputBorder.none,
							contentPadding: EdgeInsets.symmetric(vertical: 10.0),
						),
						onChanged: onBrushSizeChanged,
					),
				),
				IconButton(
					icon: Icon(shadowEnabled ? Icons.visibility : Icons.visibility_off),
					onPressed: toggleShadow,
				),
				IconButton(
					icon: Icon(layerModifierEnabled ? Icons.layers : Icons.layers_outlined),
					onPressed: toggleLayerModifier,
				),
				...[
					{'icon': Icons.format_list_numbered, 'tool': 'text_num'},
					{'icon': Icons.text_fields, 'tool': 'text'},
					{'icon': Icons.move_up, 'tool': 'move'},
					{'icon': Icons.brush, 'tool': 'pen'},
					{'icon': Icons.arrow_forward, 'tool': 'arrow'},
					{'icon': Icons.circle_outlined, 'tool': 'oval'},
					{'icon': Icons.square, 'tool': 'square'},
					{'icon': Icons.cleaning_services, 'tool': 'eraser'},
				].map((item) => IconButton(
									icon: Icon(item['icon'] as IconData),
									onPressed: () => onToolSelected(item['tool'] as String),
								)),
				IconButton(
					icon: const Icon(Icons.undo),
					onPressed: undo,
				),
				IconButton(
					icon: const Icon(Icons.redo),
					onPressed: redo,
				),
				IconButton(
					icon: const Icon(Icons.color_lens),
					onPressed: showColorPicker,
				),
				IconButton(
					icon: const Icon(Icons.delete_forever),
					onPressed: clear,
				),
			],
		);
	}
}
