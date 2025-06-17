import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/grids/grids_render.dart';

/// Grid lines
class GGraphGrids<T extends GGraphTheme> extends GGraph<T> {
  GGraphGrids({
    super.id,
    super.layer,
    super.visible,
    super.valueViewPortId,
    this.valueTickerStrategy = const GValueTickerStrategyDefault(),
    this.pointTickerStrategy = const GPointTickerStrategyDefault(),

    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = super.render ?? const GGraphGridsRender();
  }
  static const String typeName = 'grids';

  /// The value ticker strategy to decide the grid lines along value axis.
  final GValueTickerStrategy valueTickerStrategy;

  /// The horizontal ticker strategy to decide the grid lines along point axis.
  final GPointTickerStrategy pointTickerStrategy;

  @override
  String get type => typeName;
}
