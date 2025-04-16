import '../../values/value.dart';
import '../../values/range.dart';
import '../components.dart';

abstract class GAxisMarker extends GMarker {
  @override
  GAxisMarkerTheme? get theme => super.theme as GAxisMarkerTheme?;

  @override
  set theme(GComponentTheme? value) {
    if (value != null && value is! GAxisMarkerTheme) {
      throw ArgumentError('theme must be a GAxisMarkerTheme');
    }
    super.theme = value;
  }

  GAxisMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    GAxisMarkerTheme? theme,
    required GAxisMarkerRender render,
  }) : super(theme: theme, render: render);
}

/// Markers on the value axis. it can be a label or a range.
class GValueAxisMarker extends GAxisMarker {
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

  /// create a label marker with value.
  GValueAxisMarker.label({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    super.render = const GValueAxisMarkerRender(),
    required double labelValue,
  }) {
    _labelValue.value = labelValue;
  }

  /// create a range marker with start and end value.
  GValueAxisMarker.range({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    super.render = const GValueAxisMarkerRender(),
    required double startValue,
    required double endValue,
  }) {
    _range.update(startValue, endValue);
  }
}

/// Markers on the point axis. it can be a label or a range.
class GPointAxisMarker extends GAxisMarker {
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

  /// create a label marker with point.
  GPointAxisMarker.label({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    super.render = const GPointAxisMarkerRender(),
    required int point,
  }) {
    _labelPoint.value = point;
  }

  /// create a range marker with start and end point.
  GPointAxisMarker.range({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    super.render = const GPointAxisMarkerRender(),
    required double startPoint,
    required double endPoint,
  }) {
    _range.update(startPoint, endPoint);
  }
}
