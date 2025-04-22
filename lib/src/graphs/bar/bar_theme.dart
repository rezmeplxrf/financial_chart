import '../../components/graph/graph_theme.dart';
import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';

/// Theme for grid lines
class GGraphBarTheme extends GGraphTheme {
  final double barWidthRatio;

  final PaintStyle barStyleAboveBase;
  final PaintStyle barStyleBelowBase;

  const GGraphBarTheme({
    required this.barStyleAboveBase,
    required this.barStyleBelowBase,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  }) : assert(barWidthRatio > 0 && barWidthRatio <= 1);

  GGraphBarTheme copyWith({
    PaintStyle? barStyleAboveBase,
    PaintStyle? barStyleBelowBase,
    double? barWidthRatio,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphBarTheme(
      barStyleAboveBase: barStyleAboveBase ?? this.barStyleAboveBase,
      barStyleBelowBase: barStyleBelowBase ?? this.barStyleBelowBase,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
