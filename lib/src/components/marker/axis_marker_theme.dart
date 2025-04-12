import '../../style/paint_style.dart';
import '../axis/axis_theme.dart';
import './marker_theme.dart';

/// Base class for axis marker theme
class GAxisMarkerTheme extends GMarkerTheme {
  final GAxisLabelTheme? labelTheme;
  final PaintStyle? rangeStyle;

  const GAxisMarkerTheme({this.labelTheme, this.rangeStyle});

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
