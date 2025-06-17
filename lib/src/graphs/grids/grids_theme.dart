import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for grid lines
class GGraphGridsTheme extends GGraphTheme {
  const GGraphGridsTheme({
    required this.lineStyle,
    this.selectionStyle,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });
  final PaintStyle lineStyle;
  final PaintStyle? selectionStyle;

  GGraphGridsTheme copyWith({
    PaintStyle? lineStyle,
    PaintStyle? selectionStyle,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphGridsTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      selectionStyle: selectionStyle ?? this.selectionStyle,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
