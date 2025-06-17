import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/line/line_render.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// Line graph
class GGraphLine<T extends GGraphTheme> extends GGraph<T> {
  GGraphLine({
    required this.valueKey,
    super.id,
    super.layer,
    super.visible,
    super.valueViewPortId,
    bool smoothing = false,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = render ?? GGraphLineRender();
    _smoothing.value = smoothing;
  }
  static const String typeName = 'line';

  /// The key of the series value in the data source.
  final String valueKey;

  /// Whether to smooth the line.
  final GValue<bool> _smoothing = GValue<bool>(false);
  bool get smoothing => _smoothing.value;
  set smoothing(bool value) {
    _smoothing.value = value;
  }

  @override
  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('valueKey', valueKey))
      ..add(DiagnosticsProperty<bool>('smoothing', smoothing));
  }
}
