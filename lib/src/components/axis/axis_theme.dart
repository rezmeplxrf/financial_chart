import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for the axis component.
class GAxisTheme extends GComponentTheme {

  GAxisTheme({
    required this.lineStyle,
    required this.tickerStyle, required this.selectionStyle, required this.labelTheme, this.tickerLength = 5.0,
    this.axisMarkerTheme,
    this.overlayMarkerTheme,
  });
  /// Style of the line (vertical or horizontal) of the axis
  final PaintStyle lineStyle;

  /// Length of the tickers
  final double tickerLength;

  /// Style of the tickers
  final PaintStyle tickerStyle;

  /// Theme for the labels
  final GAxisLabelTheme labelTheme;

  /// Style of the selection area when selecting a range on the axis.
  ///
  /// only used when [GAxis.scaleMode] is [GAxisScaleMode.select]
  final PaintStyle selectionStyle;

  /// Theme for the axis markers
  GAxisMarkerTheme? axisMarkerTheme;

  /// Theme for the overlay markers
  GOverlayMarkerTheme? overlayMarkerTheme;

  GAxisTheme copyWith({
    PaintStyle? lineStyle,
    double? tickerLength,
    PaintStyle? tickerStyle,
    PaintStyle? selectionStyle,
    GAxisLabelTheme? labelTheme,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
  }) {
    return GAxisTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      tickerLength: tickerLength ?? this.tickerLength,
      tickerStyle: tickerStyle ?? this.tickerStyle,
      selectionStyle: selectionStyle ?? this.selectionStyle,
      labelTheme: labelTheme ?? this.labelTheme,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
    );
  }
}

/// Theme for the labels of the axis.
class GAxisLabelTheme {

  const GAxisLabelTheme({required this.labelStyle, this.spacing = 5});
  /// Style of the labels
  final LabelStyle labelStyle;

  /// Spacing between the label and the axis line
  final double spacing;

  GAxisLabelTheme copyWith({LabelStyle? labelStyle, double? spacing}) {
    return GAxisLabelTheme(
      labelStyle: labelStyle ?? this.labelStyle,
      spacing: spacing ?? this.spacing,
    );
  }
}
