import 'dart:ui';
import 'drawing_tool.dart';
import 'pen_tool.dart';
import 'text_tool.dart';
import 'figure_tool.dart';
import 'eraser_tool.dart';
import 'move_tool.dart';
import 'text_num_tool.dart';
import 'copy_tool.dart';
import '../drawable_entities/main.dart';

class ToolFactory {
  static DrawingTool createTool({
    required String toolName,
    required Color color,
    required double size,
    required bool shadowEnabled,
    Offset Function(String)? getTextSize,
    GraphicEntity? Function(Offset)? getPathByPoint,
    TextStroke? Function(Offset)? getTextByPoint,
    int Function()? getLastTextNum,
  }) {
    switch (toolName) {
      case 'pen':
        return PenTool(color: color, size: size, shadowEnabled: shadowEnabled);

      case 'text':
        return TextTool(
          color: color,
          size: size,
          shadowEnabled: shadowEnabled,
          getTextSize: getTextSize ?? (String _) => Offset.zero,
          getTextByPoint: getTextByPoint ?? (Offset _) => null,
        );

      case 'text_num':
        return TextNumTool(
          color: color,
          size: size,
          shadowEnabled: shadowEnabled,
          getTextSize: getTextSize ?? (String _) => Offset.zero,
          getLastTextNum: getLastTextNum!,
        );

      case 'eraser':
        return EraserTool(getPathByPoint: getPathByPoint ?? (Offset _) => null);

      case 'move':
        return MoveTool(getPathByPoint: getPathByPoint ?? (Offset _) => null);

      case 'cut':
        return CopyTool();

      case 'square':
      case 'oval':
      case 'arrow':
      case 'filled_square':
        return FigureTool(
          figureType: toolName,
          color: color,
          size: size,
          shadowEnabled: shadowEnabled,
        );

      default:
        throw ArgumentError('Unknown tool: $toolName');
    }
  }

  static List<String> get availableTools => [
    'pen',
    'text',
    'text_num',
    'eraser',
    'move',
    'cut',
    'square',
    'oval',
    'arrow',
    'filled_square',
  ];
}
