import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';
import '../../components/graph/graph_theme.dart';

/// Theme for OHLC graph
class GGraphOhlcTheme extends GGraphTheme {
  final double barWidthRatio;

  final PaintStyle barStylePlus;
  final PaintStyle barStyleMinus;

  const GGraphOhlcTheme({
    required this.barStylePlus,
    required this.barStyleMinus,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  }) : assert(barWidthRatio > 0 && barWidthRatio <= 1);

  GGraphOhlcTheme copyWith({
    PaintStyle? barStylePlus,
    PaintStyle? barStyleMinus,
    double? barWidthRatio,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphOhlcTheme(
      barStylePlus: barStylePlus ?? this.barStylePlus,
      barStyleMinus: barStyleMinus ?? this.barStyleMinus,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
