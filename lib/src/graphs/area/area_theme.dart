import '../../components/graph/graph_theme.dart';
import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';

/// Theme for area graph
class GGraphAreaTheme extends GGraphTheme {
  /// The style for the area above the base line.
  ///
  /// If stroke styles specified the border of the area will be drawn with stroke style.
  final PaintStyle styleAboveBase;

  /// The style for the area below the base line.
  ///
  /// If stroke styles specified the border of the area will be drawn with stroke style.
  final PaintStyle styleBelowBase;

  /// The style for the base line.
  ///
  /// if null, base lines will be drawn with stroke styles in [styleAboveBase] / [styleBelowBase]
  final PaintStyle? styleBaseLine;

  const GGraphAreaTheme({
    required this.styleAboveBase,
    required this.styleBelowBase,
    this.styleBaseLine,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphAreaTheme copyWith({
    PaintStyle? styleBaseLine,
    PaintStyle? styleAboveBase,
    PaintStyle? styleBelowBase,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphAreaTheme(
      styleBaseLine: styleBaseLine ?? this.styleBaseLine,
      styleAboveBase: styleAboveBase ?? this.styleAboveBase,
      styleBelowBase: styleBelowBase ?? this.styleBelowBase,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
