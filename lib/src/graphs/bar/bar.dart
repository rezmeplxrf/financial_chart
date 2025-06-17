import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/bar/bar_render.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// Bar graph.
class GGraphBar<T extends GGraphTheme> extends GGraph<T> {
  GGraphBar({
    required this.valueKey,
    super.id,
    double? baseValue,
    super.layer,
    super.visible,
    super.valueViewPortId,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    _baseValue.value = baseValue;
    super.theme = theme;
    super.render = super.render ?? GGraphBarRender();
  }
  static const String typeName = 'bar';

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  ///
  /// If this value is not null, the bar will be the space between the value and the base value.
  /// else the bar will be the space between the value and the bottom of the viewport.
  final GValue<double?> _baseValue = GValue(null);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  @override
  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('valueKey', valueKey))
      ..add(DoubleProperty('baseValue', baseValue));
  }
}
