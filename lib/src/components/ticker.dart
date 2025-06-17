// ignore_for_file: one_member_abstracts

import 'dart:math';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';

/// Strategy to calculate value ticks for axis and grids.
abstract class GValueTickerStrategy {
  List<double> valueTicks({
    required double viewSize,
    required GValueViewPort viewPort,
  });
}

/// Strategy to calculate point ticks for axis and grids.
abstract class GPointTickerStrategy {
  List<int> pointTicks({
    required double viewSize,
    required GPointViewPort viewPort,
  });
}

/// Default strategy to calculate point ticks.
class GPointTickerStrategyDefault implements GPointTickerStrategy {
  const GPointTickerStrategyDefault({this.tickerMinSize = 100});

  /// The minimum interval between two ticks in pixel.
  final double tickerMinSize;

  @override
  List<int> pointTicks({
    required double viewSize,
    required GPointViewPort viewPort,
  }) {
    if (viewSize <= 0) {
      return [];
    }
    final points = <int>[];
    final int pointTickInterval = max(
      (tickerMinSize / viewPort.pointSize(viewSize)).ceil(),
      1,
    ); // how many points per tick
    final left = viewPort.startPoint.toInt();
    final right = viewPort.endPoint.toInt();
    for (var point = left; point < right; point++) {
      if ((point % pointTickInterval) != 0) {
        continue;
      }
      points.add(point);
    }
    return points;
  }
}

/// Default strategy to calculate value ticks.
class GValueTickerStrategyDefault implements GValueTickerStrategy {
  const GValueTickerStrategyDefault({this.tickerMinSize = 60});

  /// The minimum size of a tick in pixel.
  ///
  /// the final tick size will in range valueTickMinSize ~ valueTickMinSize*2
  final double tickerMinSize;

  double _defaultTickerValueInterval(double valueRange) {
    if (valueRange <= 0) {
      return 0;
    }
    if (valueRange >= 1) {
      return pow(10, valueRange.toStringAsFixed(0).length - 1).toDouble();
    }
    return pow(
      10,
      (valueRange * 10000000).toStringAsFixed(0).length - 9,
    ).toDouble();
  }

  double _defaultBaseValue(double centerValue, double tickInterval) {
    return (centerValue / tickInterval).round() * tickInterval;
  }

  @override
  List<double> valueTicks({
    required double viewSize,
    required GValueViewPort viewPort,
  }) {
    if (viewSize <= 0) {
      return [];
    }

    var tickInterval = _defaultTickerValueInterval(viewPort.rangeSize);
    if (tickInterval <= 0) {
      return [];
    }
    var tickSize = viewPort.valueToSize(viewSize, tickInterval);
    while (tickSize < tickerMinSize) {
      tickInterval *= 2;
      tickSize *= 2;
    }
    while (tickSize > tickerMinSize * 2) {
      tickInterval /= 2;
      tickSize /= 2;
    }
    final valueTicks = <double>[];
    final valueHigh = viewPort.endValue;
    final valueLow = viewPort.startValue;
    final baseValue = _defaultBaseValue(viewPort.centerValue, tickInterval);

    var tickValue = baseValue;
    while (tickValue <= valueHigh) {
      if (tickValue >= valueLow) {
        valueTicks.add(tickValue);
      }
      tickValue += tickInterval;
    }
    tickValue = baseValue - tickInterval;
    while (tickValue >= valueLow) {
      if (tickValue <= valueHigh) {
        valueTicks.add(tickValue);
      }
      tickValue -= tickInterval;
    }
    return valueTicks;
  }
}
