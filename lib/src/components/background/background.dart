import 'package:financial_chart/src/components/background/background_render.dart';
import 'package:financial_chart/src/components/component.dart';

/// Background of the chart.
class GBackground extends GComponent {
  GBackground({
    super.id,
    super.visible,
    super.theme,
    super.render = const GBackgroundRender(),
  });
}
