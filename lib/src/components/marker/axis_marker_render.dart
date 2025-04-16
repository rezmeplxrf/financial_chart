import 'dart:math';
import 'dart:ui';

import '../../chart.dart';
import '../../values/range.dart';
import '../axis/axis.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../viewport_h.dart';
import '../viewport_v.dart';
import 'axis_marker.dart';
import 'axis_marker_theme.dart';
import 'marker_theme.dart';
import 'marker_render.dart';

/// Render for [GAxisMarker].
abstract class GAxisMarkerRender<M extends GAxisMarker>
    extends GMarkerRender<M, GAxisMarkerTheme> {
  const GAxisMarkerRender();

  void renderValueAxisRangeMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GValueAxis axis,
    required Rect axisArea,
    required GRange valueRange,
    required GAxisMarkerTheme theme,
    required GValueViewPort valueViewPort,
  }) {
    if (valueRange.isEmpty) {
      return;
    }
    Path valueRangePath = Path();
    final bottom = valueViewPort.valueToPosition(axisArea, valueRange.begin!);
    final top = valueViewPort.valueToPosition(axisArea, valueRange.end!);
    addRectPath(
      toPath: valueRangePath,
      rect: Rect.fromLTRB(
        axisArea.left,
        max(top, axisArea.top),
        axisArea.right,
        min(bottom, axisArea.bottom),
      ),
    );
    drawPath(canvas: canvas, path: valueRangePath, style: theme.rangeStyle!);
  }

  void renderValueAxisLabelMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GValueAxis axis,
    required Rect axisArea,
    required double value,
    required GAxisMarkerTheme theme,
    required GValueViewPort valueViewPort,
  }) {
    final position = valueViewPort.valueToPosition(axisArea, value);
    final text = (axis.valueFormatter ?? chart.dataSource.seriesValueFormater)
        .call(value, valueViewPort.valuePrecision);
    drawValueAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: theme.labelTheme!,
    );
  }

  void renderPointAxisRangeMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GPointAxis axis,
    required Rect axisArea,
    required GRange pointRange,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
  }) {
    if (pointRange.isEmpty) {
      return;
    }
    Path pointRangePath = Path();
    final start = pointViewPort.pointToPosition(
      axisArea,
      pointRange.begin!.toDouble(),
    );
    final end = pointViewPort.pointToPosition(
      axisArea,
      pointRange.end!.toDouble(),
    );
    addRectPath(
      toPath: pointRangePath,
      rect: Rect.fromLTRB(
        max(start, axisArea.left),
        axisArea.top,
        min(end, axisArea.right),
        axisArea.bottom,
      ),
    );
    drawPath(canvas: canvas, path: pointRangePath, style: theme.rangeStyle!);
  }

  void renderPointAxisLabelMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GPointAxis axis,
    required Rect axisArea,
    required int point,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
  }) {
    final position = pointViewPort.pointToPosition(axisArea, point.toDouble());
    final pointValue = chart.dataSource.getPointValue(point);
    if (pointValue == null) {
      return;
    }
    final text = (axis.pointFormatter ?? chart.dataSource.pointValueFormater)
        .call(point, pointValue);
    drawPointAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: theme.labelTheme!,
    );
  }
}

class GPointAxisMarkerRender extends GAxisMarkerRender<GPointAxisMarker> {
  const GPointAxisMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GPointAxisMarker marker,
    required Rect area,
    required GMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final axis = component as GPointAxis;
    if (marker.range.isNotEmpty) {
      renderPointAxisRangeMarker(
        canvas: canvas,
        chart: chart,
        panel: panel,
        axis: axis,
        axisArea: area,
        pointRange: marker.range,
        theme: theme as GAxisMarkerTheme,
        pointViewPort: chart.pointViewPort,
      );
    } else {
      renderPointAxisLabelMarker(
        canvas: canvas,
        chart: chart,
        panel: panel,
        axis: axis,
        axisArea: area,
        point: marker.labelPoint,
        theme: theme as GAxisMarkerTheme,
        pointViewPort: chart.pointViewPort,
      );
    }
  }
}

class GValueAxisMarkerRender extends GAxisMarkerRender<GValueAxisMarker> {
  const GValueAxisMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GValueAxisMarker marker,
    required Rect area,
    required GMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final axis = component as GValueAxis;
    if (marker.range.isNotEmpty) {
      renderValueAxisRangeMarker(
        canvas: canvas,
        chart: chart,
        panel: panel,
        axis: axis,
        axisArea: area,
        valueRange: marker.range,
        theme: theme as GAxisMarkerTheme,
        valueViewPort: valueViewPort,
      );
    } else if (!marker.labelValue.isNaN) {
      renderValueAxisLabelMarker(
        canvas: canvas,
        chart: chart,
        panel: panel,
        axis: axis,
        axisArea: area,
        value: marker.labelValue,
        theme: theme as GAxisMarkerTheme,
        valueViewPort: valueViewPort,
      );
    }
  }
}
