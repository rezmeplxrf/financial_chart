import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/graph/graph_render.dart';
import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/graphs/group/group.dart';

class GGraphGroupRender extends GGraphRender<GGraphGroup, GGraphTheme> {
  GGraphGroupRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GGraphGroup component,
    required Rect area,
    required GGraphTheme theme,
    GPanel? panel,
  }) {
    if (childrenRenders.isEmpty) {
      for (final child in component.graphs) {
        final render = child.getRender() as GGraphRender;
        childrenRenders.add(render);
      }
    }
    for (final child in component.graphs) {
      if (child.visible == false) {
        continue;
      }

      (child.getRender() as GGraphRender).doRender(
        canvas: canvas,
        chart: chart,
        panel: panel,
        component: child,
        area: area,
        theme:
            child.theme == null
                ? chart.theme.graphTheme(child.type)!
                : (child.theme! as GGraphTheme),
      );
    }
  }

  List<GGraphRender> childrenRenders = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    for (final child in childrenRenders) {
      if (child.hitTest(position: position, epsilon: epsilon)) {
        return true;
      }
    }
    return false;
  }
}
