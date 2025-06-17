import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Base class for graph themes
class GGraphTheme extends GComponentTheme {

  const GGraphTheme({
    this.axisMarkerTheme,
    this.overlayMarkerTheme,
    this.highlightMarkerTheme,
  });
  final GAxisMarkerTheme? axisMarkerTheme;
  final GOverlayMarkerTheme? overlayMarkerTheme;
  final GGraphHighlightMarkerTheme? highlightMarkerTheme;
}

/// Theme for the markers of the graph when highlighted.
class GGraphHighlightMarkerTheme extends GComponentTheme {

  const GGraphHighlightMarkerTheme({
    required this.style,
    this.size = 4.0,
    this.interval = 100.0,
    this.crosshairHighlightStyle,
    this.crosshairHighlightSize = 4.0,
  });
  final PaintStyle style;
  final double size;
  final double interval;
  final PaintStyle? crosshairHighlightStyle;
  final double crosshairHighlightSize;

  GGraphHighlightMarkerTheme copyWith({
    PaintStyle? style,
    PaintStyle? crosshairHighlightStyle,
    double? crosshairHighlightSize,
    double? size,
    double? interval,
  }) {
    return GGraphHighlightMarkerTheme(
      style: style ?? this.style,
      size: size ?? this.size,
      interval: interval ?? this.interval,
      crosshairHighlightStyle:
          crosshairHighlightStyle ?? this.crosshairHighlightStyle,
      crosshairHighlightSize:
          crosshairHighlightSize ?? this.crosshairHighlightSize,
    );
  }
}
