import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

class IndicatorValue implements IndicatorResult {
  IndicatorValue(this.quote);
  @override
  final double quote;
}

class OHLCData implements IndicatorOHLC {
  const OHLCData({
    required this.time,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
  });
  final int time;
  @override
  final double open;
  @override
  final double close;
  @override
  final double high;
  @override
  final double low;
  final double volume;
}

class OHLCDataInput implements IndicatorDataInput {
  OHLCDataInput(this.entries);

  @override
  final List<OHLCData> entries;

  @override
  IndicatorResult createResult(int index, double value) =>
      IndicatorValue(value);
}

abstract class OHLCDataInputAsync implements OHLCDataInput {
  OHLCDataInputAsync();

  Future<List<OHLCData>> loadInitial(int count, [int offsetFromEnd = 0]);

  Future<List<OHLCData>> loadPrior(int count, int toTimeExclusive);

  Future<List<OHLCData>> loadAfter(int count, int fromTimeExclusive);

  @override
  IndicatorResult createResult(int index, double value) =>
      IndicatorValue(value);
}

class VolumeValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  VolumeValueIndicator(OHLCDataInput super.input);

  @override
  T getValue(int index) =>
      createResult(index: index, quote: (entries[index] as OHLCData).volume);
}
