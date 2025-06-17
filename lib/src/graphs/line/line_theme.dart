import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for line graph
class GGraphLineTheme extends GGraphTheme {

  const GGraphLineTheme({
    required this.lineStyle,
    required this.pointStyle, this.pointRadius = 0,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  }) : assert(pointRadius >= 0);
  final double pointRadius;

  final PaintStyle lineStyle;
  final PaintStyle pointStyle;

  GGraphLineTheme copyWith({
    PaintStyle? lineStyle,
    double? pointRadius,
    PaintStyle? pointStyle,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphLineTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      pointRadius: pointRadius ?? this.pointRadius,
      pointStyle: pointStyle ?? this.pointStyle,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
