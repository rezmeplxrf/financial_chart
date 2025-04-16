import 'package:financial_chart/financial_chart.dart';

/// Theme for step line graph
class GGraphStepLineTheme extends GGraphTheme {
  final PaintStyle lineUpStyle;
  final PaintStyle lineDownStyle;
  const GGraphStepLineTheme({
    required this.lineUpStyle,
    required this.lineDownStyle,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphStepLineTheme copyWith({
    PaintStyle? lineUpStyle,
    PaintStyle? lineDownStyle,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphStepLineTheme(
      lineUpStyle: lineUpStyle ?? this.lineUpStyle,
      lineDownStyle: lineDownStyle ?? this.lineDownStyle,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
