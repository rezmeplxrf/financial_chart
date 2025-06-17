import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for OHLC graph
class GGraphOhlcTheme extends GGraphTheme {

  const GGraphOhlcTheme({
    required this.barStylePlus,
    required this.barStyleMinus,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  }) : assert(barWidthRatio > 0 && barWidthRatio <= 1);
  final double barWidthRatio;

  final PaintStyle barStylePlus;
  final PaintStyle barStyleMinus;

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
