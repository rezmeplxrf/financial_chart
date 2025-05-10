import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';
import '../../components/graph/graph_theme.dart';

/// Theme for grid lines
class GGraphGridsTheme extends GGraphTheme {
  final PaintStyle lineStyle;
  final PaintStyle? selectionStyle;
  const GGraphGridsTheme({
    required this.lineStyle,
    this.selectionStyle,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });

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
