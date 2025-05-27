import 'dart:math';

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'models.dart';

const String keyOpen = "open";
const String keyHigh = "high";
const String keyLow = "low";
const String keyClose = "close";
const String keyVolume = "volume";
const String keySMA = "sma";
const String keyEMA = "ema";
const String keyMACD = "macd";
const String keyIchimokuBase = "ichimokuBase";
const String keyIchimokuConversion = "ichimokuConversion";
const String keyIchimokuSpanA = "ichimokuSpanA";
const String keyIchimokuSpanB = "ichimokuSpanB";
const String keyIchimokuLagging = "ichimokuLagging";
const String keyFastStoch = "fastStoch";
const String keySmoothedFastStoch = "smoothedFastStoch";
const String keySlowStoch = "slowStoch";
const String keySmoothedSlowStoch = "smoothedSlowStoch";
const String keyBBL = "bbl";
const String keyBBU = "bbu";
const String keyRSI = "rsi";
const String keyADX = "adx";
const String keyCCI = "cci";

class IndicatorDataProvider<T extends IndicatorResult> {
  late Indicator<T> _sourceIndicator;
  Indicator<T> get sourceIndicator => _sourceIndicator;
  Indicator<T> Function() build;

  IndicatorDataProvider(this.build) {
    _sourceIndicator = build();
  }
  void rebuild() {
    // this could be optimized by invalidating part of values only.
    _sourceIndicator = build();
  }
}

class IndicatorDataProviders {
  const IndicatorDataProviders._();
  static IndicatorDataProvider<IndicatorValue> open(IndicatorDataInput input) {
    return IndicatorDataProvider<IndicatorValue>(
      () => OpenValueIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> close(IndicatorDataInput input) {
    return IndicatorDataProvider<IndicatorValue>(
      () => CloseValueIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> high(IndicatorDataInput input) {
    return IndicatorDataProvider<IndicatorValue>(
      () => HighValueIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> low(IndicatorDataInput input) {
    return IndicatorDataProvider<IndicatorValue>(
      () => LowValueIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> volume(OHLCDataInput input) {
    return IndicatorDataProvider<IndicatorValue>(
      () => VolumeValueIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> sma(
    IndicatorDataInput input,
    int period,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => SMAIndicator<IndicatorValue>(CloseValueIndicator(input), period),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ema(
    IndicatorDataInput input,
    int period,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => EMAIndicator<IndicatorValue>(CloseValueIndicator(input), period),
    );
  }

  static IndicatorDataProvider<IndicatorValue> macd(
    IndicatorDataInput input, {
    int fastPeriod = 12,
    int slowPeriod = 26,
  }) {
    return IndicatorDataProvider<IndicatorValue>(
      () => MACDIndicator<IndicatorValue>(
        input,
        fastMAPeriod: fastPeriod,
        slowMAPeriod: slowPeriod,
      ),
    );
  }

  static IndicatorDataProvider<IndicatorValue> rsi(
    IndicatorDataInput input,
    int period,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => RSIIndicator<IndicatorValue>.fromIndicator(
        CloseValueIndicator(input),
        period,
      ),
    );
  }

  static IndicatorDataProvider<IndicatorValue> adx(
    IndicatorDataInput input, {
    int diPeriod = 14,
    int adxPeriod = 14,
  }) {
    return IndicatorDataProvider<IndicatorValue>(
      () => ADXIndicator<IndicatorValue>(
        input,
        diPeriod: diPeriod,
        adxPeriod: adxPeriod,
      ),
    );
  }

  static IndicatorDataProvider<IndicatorValue> bbl(
    IndicatorDataInput input, {
    int period = 25,
    double k = 2,
  }) {
    return IndicatorDataProvider<IndicatorValue>(() {
      final sma = SMAIndicator<IndicatorValue>(
        CloseValueIndicator(input),
        period,
      );
      final deviation = StandardDeviationIndicator<IndicatorValue>(
        CloseValueIndicator(input),
        period,
      );
      return BollingerBandsLowerIndicator<IndicatorValue>(sma, deviation, k: k);
    });
  }

  static IndicatorDataProvider<IndicatorValue> bbu(
    IndicatorDataInput input, {
    int period = 25,
    double k = 2,
  }) {
    return IndicatorDataProvider<IndicatorValue>(() {
      final sma = SMAIndicator<IndicatorValue>(
        CloseValueIndicator(input),
        period,
      );
      final deviation = StandardDeviationIndicator<IndicatorValue>(
        CloseValueIndicator(input),
        period,
      );
      return BollingerBandsUpperIndicator<IndicatorValue>(sma, deviation, k: k);
    });
  }

  static IndicatorDataProvider<IndicatorValue> cci(
    IndicatorDataInput input, {
    int period = 14,
  }) {
    return IndicatorDataProvider<IndicatorValue>(
      () => CommodityChannelIndexIndicator<IndicatorValue>(input, period),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ichimokuBase(
    IndicatorDataInput input, {
    int period = 26,
  }) {
    return IndicatorDataProvider<IndicatorValue>(
      () => IchimokuBaseLineIndicator<IndicatorValue>(input, period: period),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ichimokuConversion(
    IndicatorDataInput input, {
    int period = 9,
  }) {
    return IndicatorDataProvider<IndicatorValue>(
      () => IchimokuConversionLineIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ichimokuSpanA(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => IchimokuSpanAIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ichimokuSpanB(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => IchimokuSpanBIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> ichimokuLagging(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => LagValueIndicator.fromIndicator(
        IchimokuLaggingSpanIndicator<IndicatorValue>(input),
        period: 26,
      ),
    );
  }

  static IndicatorDataProvider<IndicatorValue> fastStochastic(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => FastStochasticIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> smoothedFastStochastic(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => SmoothedFastStochasticIndicator<IndicatorValue>(
        FastStochasticIndicator<IndicatorValue>(input),
      ),
    );
  }

  static IndicatorDataProvider<IndicatorValue> slowStochastic(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => SlowStochasticIndicator<IndicatorValue>(input),
    );
  }

  static IndicatorDataProvider<IndicatorValue> smoothedSlowStochastic(
    IndicatorDataInput input,
  ) {
    return IndicatorDataProvider<IndicatorValue>(
      () => SmoothedSlowStochasticIndicator<IndicatorValue>(
        SlowStochasticIndicator<IndicatorValue>(input),
      ),
    );
  }
}

class LagValueIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes A [PreviousValueIndicator].
  LagValueIndicator.fromIndicator(this.indicator, {this.period = 26})
    : assert(period > 0),
      super.fromIndicator(indicator);

  final Indicator<T> indicator;
  final int period;

  @override
  T calculate(int index) {
    if (index + period >= indicator.entries.length) {
      return createResult(index: index, quote: double.nan);
    }
    final int targetIndex = min(
      max(0, index + period),
      indicator.entries.length - 1,
    );

    return createResult(
      index: index,
      quote: indicator.getValue(targetIndex).quote,
    );
  }
}
