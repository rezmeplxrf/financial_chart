import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/axis/axis.dart';
import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/crosshair/crosshair_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render.dart';
import 'package:flutter/painting.dart';

abstract class GAxisRender<C extends GAxis> extends GRender<C, GAxisTheme> {
  const GAxisRender();
}

/// render for value axis lay on vertical direction.
class GValueAxisRender extends GAxisRender<GValueAxis> {
  const GValueAxisRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GValueAxis component,
    required Rect area,
    required GAxisTheme theme,
    GPanel? panel,
  }) {
    final axis = component;
    final valueViewPort = panel!.findValueViewPortById(axis.viewPortId);
    if (!valueViewPort.isValid) {
      return;
    }
    final valueTicks = axis.valueTickerStrategy.valueTicks(
      viewSize: area.height,
      viewPort: valueViewPort,
    );

    final linePath = addLinePath(
      x1: axis.isAlignLeft ? area.left : area.right,
      y1: area.top,
      x2: axis.isAlignLeft ? area.left : area.right,
      y2: area.bottom,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    final tickLinesPath = Path();
    for (var i = 0; i < valueTicks.length; i++) {
      final value = valueTicks[i];
      final valuePosition = valueViewPort.valueToPosition(area, value);

      addLinePath(
        toPath: tickLinesPath,
        x1: axis.isAlignLeft ? area.left : (area.right - theme.tickerLength),
        y1: valuePosition,
        x2: axis.isAlignLeft ? (area.left + theme.tickerLength) : area.right,
        y2: valuePosition,
      );
      final labelText = (axis.valueFormatter ??
              chart.dataSource.seriesValueFormater)
          .call(value, valueViewPort.valuePrecision);
      if (labelText.isNotEmpty) {
        drawValueAxisLabel(
          canvas: canvas,
          text: labelText,
          axis: axis,
          position: valuePosition,
          axisArea: area,
          labelTheme: theme.labelTheme,
        );
      }
    }
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.tickerStyle);

    // draw axis markers
    if (axis.axisMarkers.isNotEmpty) {
      final axisMarkers = [...axis.axisMarkers]
        ..sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in axisMarkers) {
        if (marker is GValueAxisMarker) {
          marker.getRender().renderMarker(
            canvas: canvas,
            chart: chart,
            panel: panel,
            component: component,
            marker: marker,
            area: area,
            theme:
                marker.theme ??
                theme.axisMarkerTheme ??
                chart.theme.axisMarkerTheme,
            valueViewPort: valueViewPort,
          );
        }
      }
    }

    // draw overlay markers
    if (axis.overlayMarkers.isNotEmpty) {
      final overlayMarkers = [...axis.overlayMarkers]
        ..sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in overlayMarkers) {
        marker.getRender().renderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel,
          component: component,
          marker: marker,
          area: area,
          theme:
              marker.theme ??
              theme.overlayMarkerTheme ??
              chart.theme.overlayMarkerTheme,
          valueViewPort: valueViewPort,
        );
      }
    }

    // draw selected range
    if (valueViewPort.selectedRange.isNotEmpty) {
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
        style: theme.selectionStyle,
      );

      for (final rangeValue in [
        valueViewPort.selectedRange.first,
        valueViewPort.selectedRange.last,
      ]) {
        final value = rangeValue!;
        final valuePosition = valueViewPort.valueToPosition(area, value);
        final labelText = (axis.valueFormatter ??
                chart.dataSource.seriesValueFormater)
            .call(value, valueViewPort.valuePrecision);
        if (labelText.isNotEmpty) {
          drawValueAxisLabel(
            canvas: canvas,
            text: labelText,
            axis: axis,
            position: valuePosition,
            axisArea: area,
            labelTheme:
                ((chart.crosshair.theme ?? chart.theme.crosshairTheme)
                        as GCrosshairTheme)
                    .valueLabelTheme,
          );
        }
      }
    }
  }
}

/// render for point axis lay on horizontal direction.
class GPointAxisRender extends GAxisRender<GPointAxis> {
  const GPointAxisRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GPointAxis component,
    required Rect area,
    required GAxisTheme theme,
    GPanel? panel,
  }) {
    final axis = component;
    final dataSource = chart.dataSource;
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final pointTicks = axis.pointTickerStrategy.pointTicks(
      viewSize: area.width,
      viewPort: pointViewPort,
    );

    final linePath = addLinePath(
      x1: area.left,
      y1: component.isAlignTop ? area.top : area.bottom,
      x2: area.right,
      y2: component.isAlignTop ? area.top : area.bottom,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    final tickLinesPath = Path();
    for (var i = 0; i < pointTicks.length; i++) {
      final point = pointTicks[i];
      final pointValue = dataSource.getPointValue(point);
      if (pointValue == null) {
        continue;
      }
      final pointPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );

      addLinePath(
        toPath: tickLinesPath,
        x1: pointPosition,
        y1:
            component.isAlignTop
                ? area.top
                : (area.bottom - theme.tickerLength),
        x2: pointPosition,
        y2:
            component.isAlignTop
                ? (area.top + theme.tickerLength)
                : area.bottom,
      );

      final labelText = (component.pointFormatter ??
              chart.dataSource.pointValueFormater)
          .call(point, pointValue);
      if (labelText.isNotEmpty) {
        drawPointAxisLabel(
          canvas: canvas,
          text: labelText,
          axis: axis,
          position: pointPosition,
          axisArea: area,
          labelTheme: theme.labelTheme,
        );
      }
    }
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.tickerStyle);

    // draw axis markers
    if (axis.axisMarkers.isNotEmpty) {
      final axisMarkers = [...axis.axisMarkers]
        ..sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in axisMarkers) {
        if (marker is GPointAxisMarker) {
          marker.getRender().renderMarker(
            canvas: canvas,
            chart: chart,
            panel: panel!,
            component: component,
            marker: marker,
            area: area,
            theme:
                marker.theme ??
                theme.axisMarkerTheme ??
                chart.theme.axisMarkerTheme,
          );
        }
      }
    }

    // draw overlay markers
    if (axis.overlayMarkers.isNotEmpty) {
      final overlayMarkers = [...axis.overlayMarkers]
        ..sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in overlayMarkers) {
        marker.getRender().renderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel!,
          component: component,
          marker: marker,
          area: area,
          theme:
              marker.theme ??
              theme.overlayMarkerTheme ??
              chart.theme.overlayMarkerTheme,
        );
      }
    }

    // draw selected range
    if (pointViewPort.selectedRange.isNotEmpty) {
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
        style: theme.selectionStyle,
      );
      // draw selected range label
      for (final rangePoint in [
        pointViewPort.selectedRange.first,
        pointViewPort.selectedRange.last,
      ]) {
        final point = rangePoint!.round();
        final pointValue = dataSource.getPointValue(point);
        if (pointValue != null) {
          final pointPosition = pointViewPort.pointToPosition(
            area,
            point.toDouble(),
          );
          final labelText = (component.pointFormatter ??
                  chart.dataSource.pointValueFormater)
              .call(point, pointValue);
          if (labelText.isNotEmpty) {
            drawPointAxisLabel(
              canvas: canvas,
              text: labelText,
              axis: axis,
              position: pointPosition,
              axisArea: area,
              labelTheme:
                  ((chart.crosshair.theme ?? chart.theme.crosshairTheme)
                          as GCrosshairTheme)
                      .pointLabelTheme,
            );
          }
        }
      }
    }
  }
}
