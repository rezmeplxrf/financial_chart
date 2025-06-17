import 'dart:math';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render.dart';
import 'package:financial_chart/src/components/render_util.dart';
import 'package:financial_chart/src/components/tooltip/tooltip.dart';
import 'package:financial_chart/src/components/tooltip/tooltip_theme.dart';
import 'package:financial_chart/src/values/pair.dart';
import 'package:flutter/widgets.dart';

/// [GTooltip] renderer
class GTooltipRender extends GRender<GTooltip, GTooltipTheme> {
  const GTooltipRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GTooltip component, required Rect area, required GTooltipTheme theme, GPanel? panel,
  }) {
    final tooltip = component;
    if (tooltip.position == GTooltipPosition.none) {
      _removeWidget(chart);
      return;
    }
    final crossPosition = chart.crosshair.getCrossPosition();
    if (crossPosition == null) {
      _removeWidget(chart);
      return;
    }
    if (area.left > crossPosition.dx || area.right < crossPosition.dx) {
      _removeWidget(chart);
      return;
    }
    if (!chart.pointViewPort.isValid ||
        chart.pointViewPort.isAnimating ||
        chart.isScaling ||
        chart.splitter.resizingPanelIndex != null) {
      // skip rendering if point view port is animating or scaling or resizing a panel
      _removeWidget(chart);
      return;
    }
    if (component.pointLineHighlightVisible ||
        component.valueLineHighlightVisible) {
      doRenderHighlight(
        canvas: canvas,
        chart: chart,
        panel: panel!,
        tooltip: tooltip,
        crossPosition: crossPosition,
        theme: theme,
      );
    }
    doRenderTooltip(
      canvas: canvas,
      chart: chart,
      panel: panel!,
      tooltip: tooltip,
      crossPosition: crossPosition,
      theme: theme,
    );
  }

  void doRenderHighlight({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GTooltip tooltip,
    required Offset crossPosition,
    required GTooltipTheme theme,
  }) {
    if (!tooltip.pointLineHighlightVisible &&
        !tooltip.valueLineHighlightVisible) {
      return;
    }
    if (theme.pointHighlightStyle == null &&
        theme.valueHighlightStyle == null) {
      return;
    }
    final area = panel.graphArea();
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final point = pointViewPort.nearestPoint(area, crossPosition);

    if (tooltip.pointLineHighlightVisible &&
        theme.pointHighlightStyle != null) {
      final pointPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );
      if (pointPosition.isNaN) {
        return;
      }
      final pointWidth = pointViewPort.pointSize(area.width);
      if (theme.pointHighlightStyle!.getFillPaint() == null) {
        // when fill paint not set, we draw highlight as line
        final highlightPath = addLinePath(
          x1: pointPosition,
          y1: area.top,
          x2: pointPosition,
          y2: area.bottom,
        );
        drawPath(
          canvas: canvas,
          path: highlightPath,
          style: theme.pointHighlightStyle!,
        );
      } else {
        // when fill paint was set, we draw highlight as area
        final highlightPath = addRectPath(
          rect: Rect.fromCenter(
            center: Offset(pointPosition, area.center.dy),
            width: pointWidth,
            height: area.height,
          ),
        );
        drawPath(
          canvas: canvas,
          path: highlightPath,
          style: theme.pointHighlightStyle!,
        );
      }
    }

    if (tooltip.valueLineHighlightVisible &&
        theme.valueHighlightStyle != null &&
        tooltip.followValueKey != null &&
        tooltip.followValueViewPortId != null) {
      final value = chart.dataSource.getSeriesValue(
        point: point,
        key: tooltip.followValueKey!,
      );
      if (value != null) {
        final valueViewPort = panel.findValueViewPortById(
          tooltip.followValueViewPortId!,
        );
        if (valueViewPort.isValid) {
          final valuePosition = valueViewPort.valueToPosition(
            area,
            value,
          );
          final valueHighlightPath = addLinePath(
            x1: area.left,
            y1: valuePosition,
            x2: area.right,
            y2: valuePosition,
          );
          drawPath(
            canvas: canvas,
            path: valueHighlightPath,
            style: theme.valueHighlightStyle!,
          );
        }
      }
    }
  }

  void doRenderTooltip({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GTooltip tooltip,
    required Offset crossPosition,
    required GTooltipTheme theme,
  }) {
    if (tooltip.dataKeys.isEmpty) {
      _removeWidget(chart, tooltip);
      return;
    }
    final tooltipPosition = tooltip.position;
    if (tooltipPosition == GTooltipPosition.none) {
      _removeWidget(chart, tooltip);
      return;
    }
    final area = panel.graphArea();
    final dataSource = chart.dataSource;
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      _removeWidget(chart, tooltip);
      return;
    }
    final point = pointViewPort.nearestPoint(area, crossPosition);
    final pointValue = dataSource.getPointValue(point);
    if (pointValue == null) {
      _removeWidget(chart, tooltip);
      return;
    }
    var anchorPosition = Offset.zero;
    if (tooltipPosition == GTooltipPosition.topLeft) {
      anchorPosition = area.topLeft;
    } else if (tooltipPosition == GTooltipPosition.topRight) {
      anchorPosition = area.topRight;
    } else if (tooltipPosition == GTooltipPosition.bottomLeft) {
      anchorPosition = area.bottomLeft;
    } else if (tooltipPosition == GTooltipPosition.bottomRight) {
      anchorPosition = area.bottomRight;
    } else {
      // follow
      if (tooltip.followValueKey != null &&
          tooltip.followValueViewPortId != null) {
        final pointPosition = pointViewPort.pointToPosition(
          area,
          point.toDouble(),
        );
        anchorPosition = Offset(pointPosition, crossPosition.dy);
        final value = dataSource.getSeriesValue(
          point: point,
          key: tooltip.followValueKey!,
        );
        if (value != null) {
          final valueViewPort = panel.findValueViewPortById(
            tooltip.followValueViewPortId!,
          );
          final valuePosition = valueViewPort.valueToPosition(
            area,
            value,
          );
          anchorPosition = Offset(pointPosition, valuePosition);
        }
      } else {
        anchorPosition = crossPosition;
      }
    }
    if (tooltip.tooltipNotifier != null) {
      WidgetsBinding.instance.addPostFrameCallback((f) {
        tooltip.tooltipNotifier?.value = GToolTipWidgetContext(
          panel: panel,
          area: area,
          tooltip: tooltip,
          point: point,
          anchorPosition: anchorPosition,
        );
      });
      return;
    }
    final dataKeyValues = dataSource.getSeriesValueAsMap(
      point: point,
      keys: tooltip.dataKeys,
    );
    if (dataKeyValues.isEmpty) {
      return;
    }
    double labelsWidth = 0;
    double valuesWidth = 0;
    double labelsHeight = 0;
    double valuesHeight = 0;
    TextPainter? pointValuePainter;
    if (tooltip.showPointValue) {
      final (pointValueTextPainter, _, _) = GRenderUtil.createTextPainter(
        text: dataSource.pointValueFormater(point, pointValue),
        style: theme.pointStyle,
      );
      pointValuePainter = pointValueTextPainter;
    }
    final textPainters = <GPair<TextPainter>>[];
    for (final key in tooltip.dataKeys) {
      final prop = dataSource.getSeriesProperty(key);
      final label = prop.label;
      final value = dataKeyValues[key];
      final valueText =
          (value != null)
              ? (prop.valueFormater != null)
                  ? prop.valueFormater!(value)
                  : dataSource.seriesValueFormater(value, prop.precision)
              : '';
      final (labelPainter, _, _) = GRenderUtil.createTextPainter(
        text: label,
        style: theme.labelStyle,
      );
      final (valuePainter, _, _) = GRenderUtil.createTextPainter(
        text: valueText,
        style: theme.valueStyle,
      );
      labelsWidth = max(labelsWidth, labelPainter.size.width);
      valuesWidth = max(valuesWidth, valuePainter.size.width);
      labelsHeight = labelsHeight + labelPainter.size.height + theme.rowSpacing;
      valuesHeight = valuesHeight + valuePainter.size.height + theme.rowSpacing;
      textPainters.add(GPair<TextPainter>.pair(labelPainter, valuePainter));
    }
    labelsHeight = labelsHeight - theme.rowSpacing;
    valuesHeight = valuesHeight - theme.rowSpacing;

    final frameWidth =
        max(labelsWidth + valuesWidth, pointValuePainter?.size.width ?? 0) +
        theme.labelValueSpacing +
        theme.framePadding * 2 +
        theme.frameMargin * 2;
    final frameHeight =
        max(labelsHeight, valuesHeight) +
        (pointValuePainter != null
            ? (pointValuePainter.size.height + theme.pointRowSpacing)
            : 0) +
        theme.framePadding * 2 +
        theme.frameMargin * 2;

    var tooltipArea = Rect.fromPoints(
      anchorPosition,
      anchorPosition.translate(frameWidth, frameHeight),
    );
    if (tooltipArea.right > area.right) {
      anchorPosition = Offset(area.right - frameWidth, anchorPosition.dy);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    if (tooltipArea.bottom > area.bottom) {
      anchorPosition = Offset(anchorPosition.dx, area.bottom - frameHeight);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    if (tooltipArea.top < area.top) {
      anchorPosition = Offset(anchorPosition.dx, area.top);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    if (tooltipArea.left < area.left) {
      anchorPosition = Offset(area.left, anchorPosition.dy);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    final framePath = addRectPath(
      rect: tooltipArea.deflate(theme.frameMargin),
      cornerRadius: theme.frameCornerRadius,
    );
    drawPath(canvas: canvas, path: framePath, style: theme.frameStyle);

    var anchor = anchorPosition.translate(
      theme.framePadding + theme.frameMargin,
      theme.framePadding + theme.frameMargin,
    );
    if (pointValuePainter != null) {
      pointValuePainter.paint(canvas, anchor);
      anchor = anchor.translate(
        0,
        pointValuePainter.size.height + theme.pointRowSpacing,
      );
    }
    for (final labelValuePair in textPainters) {
      labelValuePair.first!.paint(canvas, anchor);
      labelValuePair.last!.paint(
        canvas,
        anchor.translate(
          labelsWidth +
              theme.labelValueSpacing +
              valuesWidth -
              labelValuePair.last!.size.width,
          0,
        ),
      );
      anchor = anchor.translate(
        0,
        labelValuePair.first!.size.height + theme.rowSpacing,
      );
    }
  }

  void _removeWidget(GChart chart, [GTooltip? tooltip]) {
    if (tooltip != null && tooltip.tooltipNotifier == null) {
      return;
    }
    final panels = chart.panels.where(
      (p) => p.tooltip?.tooltipNotifier != null,
    );
    if (panels.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((f) {
      for (final panel in panels) {
        if (panel.tooltip?.tooltipNotifier != null) {
          panel.tooltip!.tooltipNotifier!.value = null;
        }
      }
    });
  }
}
