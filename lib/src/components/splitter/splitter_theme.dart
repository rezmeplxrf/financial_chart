import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/splitter/splitter.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for [GSplitter]
class GSplitterTheme extends GComponentTheme {

  const GSplitterTheme({
    required this.lineStyle,
    required this.handleStyle,
    required this.handleLineStyle,
    this.handleWidth = 60,
    this.handleBorderRadius = 4,
  });
  final PaintStyle lineStyle;
  final PaintStyle handleStyle;
  final PaintStyle handleLineStyle;
  final double handleWidth;
  final double handleBorderRadius;

  GSplitterTheme copyWith({
    PaintStyle? lineStyle,
    PaintStyle? handleStyle,
    PaintStyle? handleLineStyle,
    double? handleWidth,
    double? handleBorderRadius,
  }) {
    return GSplitterTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      handleStyle: handleStyle ?? this.handleStyle,
      handleLineStyle: handleLineStyle ?? this.handleLineStyle,
      handleWidth: handleWidth ?? this.handleWidth,
      handleBorderRadius: handleBorderRadius ?? this.handleBorderRadius,
    );
  }
}
