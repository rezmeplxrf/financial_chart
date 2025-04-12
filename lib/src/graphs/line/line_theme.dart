import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';
import '../../components/graph/graph_theme.dart';

/// Theme for line graph
class GGraphLineTheme extends GGraphTheme {
  final PaintStyle lineStyle;
  final PaintStyle pointStyle;
  const GGraphLineTheme({
    required this.lineStyle,
    required this.pointStyle,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphLineTheme copyWith({
    PaintStyle? lineStyle,
    PaintStyle? pointStyle,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphLineTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      pointStyle: pointStyle ?? this.pointStyle,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
