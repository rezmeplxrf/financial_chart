import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/tooltip/tooltip.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for [GTooltip] component.
class GTooltipTheme extends GComponentTheme {

  const GTooltipTheme({
    required this.frameStyle,
    required this.pointStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.pointHighlightStyle,
    this.valueHighlightStyle,
    this.frameCornerRadius = 2,
    this.framePadding = 6,
    this.frameMargin = 6,
    this.labelValueSpacing = 16,
    this.rowSpacing = 2,
    this.pointRowSpacing = 6,
  });
  /// Style of the tooltip frame.
  final PaintStyle frameStyle;

  /// Radius of the tooltip frame corner.
  final double frameCornerRadius;

  /// Padding of the tooltip frame.
  final double framePadding;

  /// Margin of the tooltip frame.
  final double frameMargin;

  /// Spacing between label and value.
  final double labelValueSpacing;

  /// Spacing between label & value rows.
  final double rowSpacing;

  /// Style of the point value.
  final LabelStyle pointStyle;

  /// Spacing between point row and the first value row.
  final double pointRowSpacing;

  /// Style of the value label.
  final LabelStyle labelStyle;

  /// Style of the value.
  final LabelStyle valueStyle;

  /// Style of the highlighted point line/area.
  final PaintStyle? pointHighlightStyle;

  /// Style of the highlighted value line.
  final PaintStyle? valueHighlightStyle;

  GTooltipTheme copyWith({
    PaintStyle? frameStyle,
    LabelStyle? pointStyle,
    LabelStyle? labelStyle,
    LabelStyle? valueStyle,
    PaintStyle? pointHighlightStyle,
    PaintStyle? valueHighlightStyle,
    double? frameCornerRadius,
    double? framePadding,
    double? frameMargin,
    double? labelValueSpacing,
    double? rowSpacing,
    double? pointRowSpacing,
  }) {
    return GTooltipTheme(
      frameStyle: frameStyle ?? this.frameStyle,
      pointStyle: pointStyle ?? this.pointStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      pointHighlightStyle: pointHighlightStyle ?? this.pointHighlightStyle,
      valueHighlightStyle: valueHighlightStyle ?? this.valueHighlightStyle,
      frameCornerRadius: frameCornerRadius ?? this.frameCornerRadius,
      framePadding: framePadding ?? this.framePadding,
      frameMargin: frameMargin ?? this.frameMargin,
      labelValueSpacing: labelValueSpacing ?? this.labelValueSpacing,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      pointRowSpacing: pointRowSpacing ?? this.pointRowSpacing,
    );
  }
}
