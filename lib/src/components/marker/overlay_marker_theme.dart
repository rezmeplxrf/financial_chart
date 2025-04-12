import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import './marker_theme.dart';

/// Base class for graph marker theme
class GOverlayMarkerTheme extends GMarkerTheme {
  final PaintStyle markerStyle;
  final LabelStyle? labelStyle;
  final PaintStyle? controlPointsStyle;

  const GOverlayMarkerTheme({
    required this.markerStyle,
    this.labelStyle,
    this.controlPointsStyle,
  });

  GOverlayMarkerTheme copyWith({
    PaintStyle? controlPointsStyle,
    PaintStyle? markerStyle,
    LabelStyle? labelStyle,
  }) {
    return GOverlayMarkerTheme(
      controlPointsStyle: controlPointsStyle ?? this.controlPointsStyle,
      markerStyle: markerStyle ?? this.markerStyle,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
