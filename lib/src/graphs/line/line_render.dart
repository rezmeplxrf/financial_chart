import 'dart:typed_data';
import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/graphs/graphs.dart';
import 'package:financial_chart/src/vector/vectors.dart';

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

    final linePoints = <Vector2>[];
    final highlightMarks = <Vector2>[];
    final highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    final highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    _hitTestLinePoints.clear();
    for (
      var point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      final value = dataSource.getSeriesValue(
        point: point,
        key: graph.valueKey,
      );
      if (value == null || value.isNaN || value.isInfinite) {
        continue;
      }
      final x = pointViewPort.pointToPosition(area, point.toDouble());
      final y = valueViewPort.valueToPosition(area, value);
      linePoints.add(Vector2(x, y));
      if (graph.highlight && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, y));
      }
    }

    final hitTestLinePoints = _drawGraph(
      canvas: canvas,
      area: area,
      theme: theme,
      linePoints: linePoints,
      smoothing: graph.smoothing,
    );

    if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
      _hitTestLinePoints.addAll(hitTestLinePoints);
    }

    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  // draw graph use raw styles in the theme (optimized batch draw)
  List<Vector2> _drawGraph({
    required Canvas canvas,
    required Rect area,
    required GGraphLineTheme theme,
    required List<Vector2> linePoints,
    required bool smoothing,
  }) {
    final resultLinePoints = <Vector2>[];
    final linePaint = theme.lineStyle.getStrokePaint(
      gradientBounds: theme.lineStyle.gradientBounds ?? area,
    );
    final pointStrokePaint = theme.pointStyle.getStrokePaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    final pointFillPaint = theme.pointStyle.getFillPaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    if (pointFillPaint != null) {
      pointFillPaint
        ..strokeWidth = theme.pointRadius * 2
        ..style = PaintingStyle.fill
        ..strokeCap = pointStrokePaint?.strokeCap ?? StrokeCap.round;
    }

    // batch draw line segments
    final linesToDraw = <double>[];
    if (smoothing) {
      final spline = SplineUtil.catmullRomSpline(linePoints, false);
      final splinePoints = SplineUtil.sampleSplines(spline, 10, false);
      for (var i = 0; i < splinePoints.length; i++) {
        linesToDraw
          ..add(splinePoints[i].x)
          ..add(splinePoints[i].y);
      }
      resultLinePoints.addAll(splinePoints);
    } else {
      for (var i = 0; i < linePoints.length; i++) {
        if (linePaint != null) {
          linesToDraw
            ..add(linePoints[i].x)
            ..add(linePoints[i].y);
        }
      }
      resultLinePoints.addAll(linePoints);
    }
    if (linePaint != null) {
      canvas.drawRawPoints(
        PointMode.polygon,
        Float32List.fromList(linesToDraw),
        linePaint,
      );
    }

    final pointsToDraw = <double>[];
    // batch draw points fill
    for (var i = 0; i < linePoints.length; i++) {
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
    if (pointFillPaint != null) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(pointsToDraw),
        pointFillPaint,
      );
    }

    // draw points stroke
    if (pointStrokePaint != null) {
      for (var i = 0; i < linePoints.length; i++) {
        canvas.drawCircle(
          Offset(linePoints[i].x, linePoints[i].y),
          theme.pointRadius,
          pointStrokePaint,
        );
      }
    }

    return resultLinePoints;
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
