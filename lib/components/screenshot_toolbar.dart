import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_slider.dart';

class ScreenshotToolbar extends StatelessWidget {
	final TextEditingController brushSizeController;
	final Function(String) onBrushSizeChanged;
	final VoidCallback toggleShadow;
	final bool shadowEnabled;
	final int brushSize;
	final Color color;
	final VoidCallback toggleLayerModifier;
	final bool layerModifierEnabled;
	final Function(String tool) onToolSelected;
	final VoidCallback undo;
	final VoidCallback redo;
	final VoidCallback clear;
	final VoidCallback showColorPicker;
	final Future<void> Function() uploadScreenshot;
	final String tool;

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
		required this.uploadScreenshot,
		required this.color,
		required this.tool,
		required this.brushSize
	});

	static const Color _blueColor = Color(0xFF425AD0);

	Widget _getSvgIcon(String iconName) {
		return SvgPicture.asset(
			'assets/toolbar/$iconName.svg',
			width: 30,
			height: 30,
			fit: BoxFit.contain,
		);
	}

	Widget _buildSvgIconButton({
		required VoidCallback onPressed,
		required String iconName,
		required bool isEnabled,
	}) {
		return InkWell(
			onTap: onPressed,
			child: Container(
			padding: EdgeInsets.zero,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.zero,
				color: isEnabled ? _blueColor : Colors.transparent ,
			),
			child: _getSvgIcon(isEnabled ? iconName + "_white" : iconName),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			height: 38,
			padding: const EdgeInsets.symmetric(horizontal: 4),
			child: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: ConstrainedBox(
					constraints: BoxConstraints(
						minWidth: MediaQuery.of(context).size.width - 16,
					),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							Row(
								children: [
									InkWell(
										onTap: showColorPicker,
										child: Container(
											width: 30,
											height: 30,
											decoration: BoxDecoration(
												color: color,
												borderRadius: BorderRadius.circular(2),
											),
										),
									),
									const SizedBox(width: 4),
									
									SizedBox(
										width: 54,
										height: 30,
										child: TextField(
											controller: brushSizeController,
											keyboardType: TextInputType.number,
											decoration: const InputDecoration(
												border: InputBorder.none,
												contentPadding: EdgeInsets.zero,
          										isDense: true,
											),
											style: const TextStyle(
												fontFamily: 'IBMPlexMono',
												fontSize: 14,
												fontWeight: FontWeight.w500,
											),
											textAlignVertical: TextAlignVertical.center,
											textAlign: TextAlign.right,
											onChanged: onBrushSizeChanged,
										),
									),
									const SizedBox(width: 2),

									SizedBox(
										width: 192,
										height: 30,  
										child: CustomSlider(
											value: brushSize,
											onChanged: (double value) {
												onBrushSizeChanged(value.toInt().toString());
												brushSizeController.text = (value.toInt() == 1) ? "первый" : value.toInt().toString();
											},
										),
									),

								],
							),


							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 4),
								child: Row(
									children: [
										const SizedBox(width: 2),
										..._buildToolButtons(),

																		
										const SizedBox(width: 4),

										Container(
											width: 1, 
											height: 26, 
											color: Color(0xFFB8B8B8), 
										),

										const SizedBox(width: 5),

										_buildSvgIconButton(
											iconName: 'layer_modifier',
											onPressed: toggleLayerModifier,
											isEnabled: layerModifierEnabled,
										),
		

										const SizedBox(width: 2),
										_buildSvgIconButton(
											iconName: 'shadow',
											onPressed: toggleShadow,
											isEnabled: shadowEnabled,
										),
									],
								),
							),

							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 4),
								child: Row(
									children: [
										_buildSvgIconButton(
											iconName: 'undo',
											onPressed: undo,
											isEnabled: false,
										),
										const SizedBox(width: 2),
										_buildSvgIconButton(
											iconName: 'redo',
											onPressed: redo,
											isEnabled: false,
										),
										const SizedBox(width: 2),
										_buildSvgIconButton(
											iconName: 'cleaning',
											onPressed: clear,
											isEnabled: false,
										),
									]
								)
							),

							Row(
								children: [
									
									const SizedBox(width: 12),
									SizedBox(
										width: 130,
										height: 30,
										child: ElevatedButton(
											style: ElevatedButton.styleFrom(
												backgroundColor: _blueColor,
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(2),
												),
												padding: EdgeInsets.zero,
											),
											onPressed: uploadScreenshot,
											child: const Text(
												'Загрузить',
												style: TextStyle(
													fontFamily: 'IBMPlexMono',
													fontWeight: FontWeight.w500,
													fontSize: 14,
													color: Colors.white,
												),
											),
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}

	List<Widget> _buildToolButtons() {
		return [
			{'icon': 'pen', 'tool': 'pen'},
			{'icon': 'arrow', 'tool': 'arrow'},
			{'icon': 'circle', 'tool': 'oval'},
			{'icon': 'square', 'tool': 'square'},
			{'icon': 'filled_square', 'tool': 'filled_square'},
			{'icon': 'text', 'tool': 'text'},
			{'icon': 'text_num', 'tool': 'text_num'},
			{'icon': 'move', 'tool': 'move'},
			{'icon': 'cut', 'tool': 'cut'},
			{'icon': 'eraser', 'tool': 'eraser'},
		].map((item) {
			return Padding(
				padding: const EdgeInsets.symmetric(horizontal: 2),
				child: _buildSvgIconButton(
					iconName: item['icon']!,
					onPressed: () => onToolSelected(item['tool']!),
					isEnabled: tool == item['tool'],
				),
			);
		}).toList();
	}
}
