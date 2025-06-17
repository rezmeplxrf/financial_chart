import 'dart:ui';

import 'package:financial_chart/financial_chart.dart';

class GGraphGridsRender extends GGraphRender<GGraphGrids, GGraphGridsTheme> {
  const GGraphGridsRender();
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphGrids graph,
    required Rect area,
    required GGraphGridsTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final tickLinesPath = Path();
    graph.pointTickerStrategy
        .pointTicks(viewSize: area.width, viewPort: pointViewPort)
        .forEach((point) {
          final dx = pointViewPort.pointToPosition(area, point.toDouble());
          addLinePath(
            toPath: tickLinesPath,
            x1: dx,
            y1: area.top,
            x2: dx,
            y2: area.bottom,
          );
        });
    graph.valueTickerStrategy
        .valueTicks(viewSize: area.height, viewPort: valueViewPort)
        .forEach((value) {
          final dy = valueViewPort.valueToPosition(area, value);
          addLinePath(
            toPath: tickLinesPath,
            x1: area.left,
            y1: dy,
            x2: area.right,
            y2: dy,
          );
        });
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.lineStyle);

    // draw selected range for value axis selection
    if (valueViewPort.selectedRange.isNotEmpty &&
        theme.selectionStyle != null) {
      final selectedRangePath = addRectPath(
        rect: Rect.fromLTRB(
          area.left,
          valueViewPort.valueToPosition(
            area,
            valueViewPort.selectedRange.first!,
          ),
          area.right,
          valueViewPort.valueToPosition(
            area,
            valueViewPort.selectedRange.last!,
          ),
        ),
      );
      drawPath(
        canvas: canvas,
        path: selectedRangePath,
        style: theme.selectionStyle!,
      );
    }

    // draw selected range for point axis selection
    if (pointViewPort.selectedRange.isNotEmpty &&
        theme.selectionStyle != null) {
      final selectedRangePath = addRectPath(
        rect: Rect.fromLTRB(
          pointViewPort.pointToPosition(
            area,
            pointViewPort.selectedRange.first!,
          ),
          area.top,
          pointViewPort.pointToPosition(
            area,
            pointViewPort.selectedRange.last!,
          ),
          area.bottom,
        ),
      );
      drawPath(
        canvas: canvas,
        path: selectedRangePath,
        style: theme.selectionStyle!,
      );
    }
  }
}
