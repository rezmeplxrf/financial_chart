import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/marker/marker_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Base class for axis marker theme
class GAxisMarkerTheme extends GMarkerTheme {

  const GAxisMarkerTheme({this.labelTheme, this.rangeStyle});
  final GAxisLabelTheme? labelTheme;
  final PaintStyle? rangeStyle;

  GAxisMarkerTheme copyWith({
    GAxisLabelTheme? labelTheme,
    PaintStyle? rangeStyle,
  }) {
    return GAxisMarkerTheme(
      labelTheme: labelTheme ?? this.labelTheme,
      rangeStyle: rangeStyle ?? this.rangeStyle,
    );
  }
}
