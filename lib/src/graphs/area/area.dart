import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/area/area_render.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// Area graph.
///
/// if [baseValueKey] or [baseValue] is not null, the area will be the space between the value and the base value.
/// else the area will be the space between the value and bottom of the viewport.
class GGraphArea<T extends GGraphTheme> extends GGraph<T> {
  GGraphArea({
    required this.valueKey,
    super.id,
    double? baseValue = 0,
    String? baseValueKey,
    super.layer,
    super.visible,
    super.valueViewPortId,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = super.render ?? GGraphAreaRender();
    _baseValueKey.value = baseValueKey;
    _baseValue.value = baseValue;
  }
  static const String typeName = 'area';

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  final GValue<String?> _baseValueKey = GValue(null);
  String? get baseValueKey => _baseValueKey.value;
  set baseValueKey(String? value) => _baseValueKey.value = value;

  /// The base value of the area graph.
  final GValue<double?> _baseValue = GValue(0);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  @override
  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('valueKey', valueKey))
      ..add(StringProperty('baseValueKey', baseValueKey))
      ..add(DoubleProperty('baseValue', baseValue));
  }
}
