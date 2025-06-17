import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/values/range.dart';
import 'package:financial_chart/src/values/value.dart';

abstract class GAxisMarker extends GMarker {
  GAxisMarker({
    required GAxisMarkerRender render,
    super.id,
    super.visible,
    super.layer,
    GAxisMarkerTheme? theme,
  }) : super(theme: theme, render: render);
  @override
  GAxisMarkerTheme? get theme => super.theme as GAxisMarkerTheme?;

  @override
  set theme(GComponentTheme? value) {
    if (value != null && value is! GAxisMarkerTheme) {
      throw ArgumentError('theme must be a GAxisMarkerTheme');
    }
    super.theme = value;
  }
}

/// Markers on the value axis. it can be a label or a range.
class GValueAxisMarker extends GAxisMarker {
  /// create a label marker with value.
  GValueAxisMarker.label({
    required double labelValue,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    super.render = const GValueAxisMarkerRender(),
  }) {
    _labelValue.value = labelValue;
  }

  /// create a range marker with start and end value.
  GValueAxisMarker.range({
    required double startValue,
    required double endValue,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    super.render = const GValueAxisMarkerRender(),
  }) {
    _range.update(startValue, endValue);
  }

  /// the value of the label marker.
  final GValue<double> _labelValue = GValue<double>(double.nan);
  double get labelValue => _labelValue.value;
  set labelValue(double value) {
    _labelValue.value = value;
    _range.clear();
  }

  /// the value range of the rect marker.
  final GRange _range = GRange.empty();
  GRange get range => _range;
  set range(GRange value) {
    assert(value.isNotEmpty);
    _range.copy(value);
    _labelValue.value = double.nan;
  }
}

/// Markers on the point axis. it can be a label or a range.
class GPointAxisMarker extends GAxisMarker {
  /// create a label marker with point.
  GPointAxisMarker.label({
    required int point,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    super.render = const GPointAxisMarkerRender(),
  }) {
    _labelPoint.value = point;
  }

  /// create a range marker with start and end point.
  GPointAxisMarker.range({
    required double startPoint,
    required double endPoint,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    super.render = const GPointAxisMarkerRender(),
  }) {
    _range.update(startPoint, endPoint);
  }

  /// the point of the label marker.
  final GValue<int> _labelPoint = GValue<int>(0);
  int get labelPoint => _labelPoint.value;
  set labelPoint(int point) {
    _labelPoint.value = point;
    _range.clear();
  }

  /// the point range of the rect marker.
  final GRange _range = GRange.empty();
  GRange get range => _range;
  set range(GRange value) {
    assert(value.isNotEmpty);
    _range.copy(value);
    _labelPoint.value = 0;
  }
}
