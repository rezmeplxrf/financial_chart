import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../financial_chart.dart';

class GGraphLineRender extends GGraphRender<GGraphLine, GGraphLineTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphLine graph,
    required Rect area,
    required GGraphLineTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;

    final List<Vector2> linePoints = <Vector2>[];
    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    _hitTestLinePoints.clear();
    for (
      var point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      double? value = dataSource.getSeriesValue(
        point: point,
        key: graph.valueKey,
      );
      if (value == null) {
        continue;
      }
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      double y = valueViewPort.valueToPosition(area, value);
      linePoints.add(Vector2(x, y));
      if (graph.highlight && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, y));
      }
    }

    _drawGraph(
      canvas: canvas,
      area: area,
      theme: theme,
      linePoints: linePoints,
    );

    if (graph.hitTestMode != GHitTestMode.none) {
      _hitTestLinePoints.addAll(linePoints);
    }

    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  // draw graph use raw styles in the theme (optimized batch draw)
  void _drawGraph({
    required Canvas canvas,
    required Rect area,
    required GGraphLineTheme theme,
    required List<Vector2> linePoints,
  }) {
    Paint? linePaint = theme.lineStyle.getStrokePaint(
      gradientBounds: theme.lineStyle.gradientBounds ?? area,
    );
    Paint? pointStrokePaint = theme.pointStyle.getStrokePaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    pointStrokePaint?.shader = ui.Gradient.linear(
      area.topCenter,
      //the line interval is 20
      area.bottomCenter,
      [
        //give transparent to start color, give actual line color to the end color
        Colors.transparent,
        Colors.red,
      ],
      //The interval [0.0,0.9] is transparent, and the interval [0.9,1.0] is red. So it looks like drawing red lines
      [0.90, 1.0],
      //just repeat the gradient
      TileMode.repeated,
      null,
    );
    Paint? pointFillPaint = theme.pointStyle.getFillPaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    if (pointFillPaint != null) {
      pointFillPaint.strokeWidth = theme.pointRadius * 2;
      pointFillPaint.style = PaintingStyle.fill;
      pointFillPaint.strokeCap = pointStrokePaint?.strokeCap ?? StrokeCap.round;
    }
    List<double> linesToDraw = [];
    List<double> pointsToDraw = [];
    for (int i = 0; i < linePoints.length; i++) {
      if (linePaint != null) {
        linesToDraw.add(linePoints[i].x);
        linesToDraw.add(linePoints[i].y);
      }
      if (theme.pointRadius > 0 &&
          theme.pointStyle.isNotEmpty &&
          i < linePoints.length - 1) {
        pointsToDraw.addAll([
          linePoints[i].x,
          linePoints[i].y,
          linePoints[i + 1].x,
          linePoints[i + 1].y,
        ]);
      }
    }
    // draw line segments
    if (linePaint != null) {
      canvas.drawRawPoints(
        PointMode.polygon,
        Float32List.fromList(linesToDraw),
        linePaint,
      );
    }
    // draw points fill
    if (pointFillPaint != null) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(pointsToDraw),
        pointFillPaint,
      );
    }

    // draw points stroke
    if (pointStrokePaint != null) {
      for (int i = 0; i < linePoints.length; i++) {
        canvas.drawCircle(
          Offset(linePoints[i].x, linePoints[i].y),
          theme.pointRadius,
          pointStrokePaint,
        );
      }
    }
  }

  final List<Vector2> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    return super.hitTestLines(
      lines: [_hitTestLinePoints],
      position: position,
      epsilon: epsilon,
    );
  }
}
