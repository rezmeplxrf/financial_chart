import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/ohlc/ohlc_render.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// OHLC (and Candle) graph
class GGraphOhlc<T extends GGraphTheme> extends GGraph<T> {
  GGraphOhlc({
    required this.ohlcValueKeys,
    super.id,
    super.valueViewPortId,
    bool drawAsCandle = true,
    super.layer,
    super.visible,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) : _drawAsCandle = GValue(drawAsCandle) {
    assert(ohlcValueKeys.length == 4, 'The length of ohlcValueKeys must be 4.');
    super.theme = theme;
    super.render = render ?? GGraphOhlcRender();
  }
  static const String typeName = 'ohlc';

  /// The four keys of the OHLC values in the data source.
  final List<String> ohlcValueKeys;

  /// If true, will draw candlesticks instead of OHLC.
  final GValue<bool> _drawAsCandle;
  bool get drawAsCandle => _drawAsCandle.value;
  set drawAsCandle(bool value) => _drawAsCandle.value = value;

  @override
  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<String>('ohlcValueKeys', ohlcValueKeys))
      ..add(DiagnosticsProperty<bool>('drawAsCandle', drawAsCandle));
  }
}
