import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/panel/panel_theme.dart';
import 'package:financial_chart/src/components/render.dart';

/// The render for [GPanel].
class GPanelRender extends GRender<GPanel, GPanelTheme> {
  const GPanelRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GPanel component,
    required Rect area,
    required GPanelTheme theme,
    GPanel? panel,
  }) {
    if (component.visible == false || area.height <= 0 || area.width <= 0) {
      return;
    }
    final path = Path()..addRect(area);
    drawPath(canvas: canvas, path: path, style: theme.style);
    doRenderAxes(canvas: canvas, chart: chart, panel: component);
    doRenderGraphs(canvas: canvas, chart: chart, panel: component);
    doRenderAxes(canvas: canvas, chart: chart, panel: component, inside: true);
    doRenderTooltips(canvas: canvas, chart: chart, panel: component);
  }

  void doRenderAxes({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    bool inside = false,
  }) {
    for (var n = 0; n < panel.valueAxes.length; n++) {
      final axis = panel.valueAxes[n];
      if (!axis.visible) {
        continue;
      }
      if ((inside && !axis.position.isInside) ||
          (!inside && axis.position.isInside)) {
        continue;
      }
      final axisArea = panel.valueAxisArea(n);
      axis.getRender().render(
        canvas: canvas,
        chart: chart,
        panel: panel,
        area: axisArea,
        component: axis,
        theme: axis.theme ?? chart.theme.valueAxisTheme,
      );
    }

    for (var n = 0; n < panel.pointAxes.length; n++) {
      final axis = panel.pointAxes[n];
      if (!axis.visible) {
        continue;
      }
      if ((inside && !axis.position.isInside) ||
          (!inside && axis.position.isInside)) {
        continue;
      }
      final axisArea = panel.pointAxisArea(n);
      axis.getRender().render(
        chart: chart,
        panel: panel,
        canvas: canvas,
        area: axisArea,
        component: axis,
        theme: axis.theme ?? chart.theme.pointAxisTheme,
      );
    }
  }

  void doRenderGraphs({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
  }) {
    panel.graphs.sort((a, b) => a.layer.compareTo(b.layer));
    for (var g = 0; g < panel.graphs.length; g++) {
      final graph = panel.graphs[g];
      if (graph.visible) {
        graph.getRender().render(
          canvas: canvas,
          chart: chart,
          panel: panel,
          area: panel.graphArea(),
          component: graph,
          theme: graph.theme ?? chart.theme.graphTheme(graph.type)!,
        );
      }
    }
  }

  void doRenderTooltips({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
  }) {
    if (chart.dataSource.isEmpty) {
      return;
    }
    if (panel.tooltip != null) {
      panel.tooltip!.getRender().render(
        canvas: canvas,
        chart: chart,
        panel: panel,
        area: panel.graphArea(),
        component: panel.tooltip!,
        theme: panel.tooltip!.theme ?? chart.theme.tooltipTheme,
      );
    }
  }
}
