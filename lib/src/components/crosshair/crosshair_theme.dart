import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/crosshair/crosshair.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for the [GCrosshair] component.
class GCrosshairTheme extends GComponentTheme {

  const GCrosshairTheme({
    required this.lineStyle,
    required this.valueLabelTheme,
    required this.pointLabelTheme,
  });
  /// Style of the lines.
  final PaintStyle lineStyle;

  /// Theme for the value labels.
  final GAxisLabelTheme valueLabelTheme;

  /// Theme for the point labels.
  final GAxisLabelTheme pointLabelTheme;

  GCrosshairTheme copyWith({
    PaintStyle? lineStyle,
    GAxisLabelTheme? valueLabelTheme,
    GAxisLabelTheme? pointLabelTheme,
  }) {
    return GCrosshairTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      valueLabelTheme: valueLabelTheme ?? this.valueLabelTheme,
      pointLabelTheme: pointLabelTheme ?? this.pointLabelTheme,
    );
  }
}
