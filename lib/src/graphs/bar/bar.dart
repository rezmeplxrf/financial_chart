import '../../components/graph/graph.dart';
import '../../values/value.dart';
import 'bar_render.dart';
import 'bar_theme.dart';

/// Bar graph.
class GGraphBar extends GGraph<GGraphBarTheme> {
  static const String typeName = "bar";

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  ///
  /// If this value is not null, the bar will be the space between the value and the base value.
  /// else the bar will be the space between the value and the bottom of the viewport.
  final GValue<double?> _baseValue = GValue(null);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  GGraphBar({
    super.id,
    required this.valueKey,
    double? baseValue,
    super.layer,
    super.visible,
    super.valueViewPortId,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    super.theme,
    super.render,
  }) {
    _baseValue.value = baseValue;
    super.render = render ?? GGraphBarRender();
  }

  @override
  String get type => typeName;
}
