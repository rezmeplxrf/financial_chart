import 'package:financial_chart/src/components/marker/marker_theme.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Base class for graph marker theme
class GOverlayMarkerTheme extends GMarkerTheme {

  const GOverlayMarkerTheme({
    required this.markerStyle,
    this.labelStyle,
    this.controlPointsStyle,
  });
  final PaintStyle markerStyle;
  final LabelStyle? labelStyle;
  final PaintStyle? controlPointsStyle;

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
