import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/graph/graph_render.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/graphs/ohlc/ohlc.dart';
import 'package:financial_chart/src/graphs/ohlc/ohlc_theme.dart';
import 'package:vector_math/vector_math.dart';

class GGraphOhlcRender extends GGraphRender<GGraphOhlc, GGraphOhlcTheme> {
  GGraphOhlcRender();
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphOhlc graph,
    required Rect area,
    required GGraphOhlcTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    final barRenderWidth =
        pointViewPort.pointSize(area.width) * theme.barWidthRatio;
    _hitTestLines.clear();
    final highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    final highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    final highlightMarks = <Vector2>[];
    final graphValues = <List<double>>[];
    for (
      var point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      final o = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[0],
      );
      final h = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[1],
      );
      final l = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[2],
      );
      final c = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[3],
      );
      if (o == null || h == null || l == null || c == null) {
        continue;
      }
      final barPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );

      final op = valueViewPort.valueToPosition(area, o);
      final hp = valueViewPort.valueToPosition(area, h);
      final lp = valueViewPort.valueToPosition(area, l);
      final cp = valueViewPort.valueToPosition(area, c);
      graphValues.add([barPosition, op, hp, lp, cp]);

      if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
        if (graph.drawAsCandle) {
          _hitTestLines.addAll([
            [Vector2(barPosition, hp), Vector2(barPosition, lp)],
            [
              Vector2(barPosition - barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition + barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition + barRenderWidth / 2, max(op, cp)),
              Vector2(barPosition - barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition - barRenderWidth / 2, max(op, cp)),
            ],
          ]);
        } else {
          _hitTestLines.addAll([
            [
              Vector2(barPosition - barRenderWidth / 2, op),
              Vector2(barPosition + barRenderWidth / 2, op),
            ],
            [Vector2(barPosition, hp), Vector2(barPosition, lp)],
            [
              Vector2(barPosition, cp),
              Vector2(barPosition + barRenderWidth / 2, cp),
            ],
          ]);
        }
      }
      if (graph.highlight && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(barPosition, (hp + lp) / 2));
      }
    }

    if (graph.drawAsCandle) {
      _drawCandlesGraph(canvas, graph, theme, barRenderWidth, graphValues);
    } else {
      _drawOhlcGraph(canvas, graph, theme, barRenderWidth, graphValues);
    }

    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  void _drawCandlesGraph(
    Canvas canvas,
    GGraphOhlc graph,
    GGraphOhlcTheme theme,
    double barRenderWidth,
    List<List<double>> graphValues,
  ) {
    if (theme.barStyleMinus.isSimple && theme.barStylePlus.isSimple) {
      // use batch drawing when possible
      final borderPlus = <double>[];
      final borderMinus = <double>[];
      final fillPlus = <double>[];
      final fillMinus = <double>[];

      final strokePlus =
          theme.barStylePlus.getStrokePaint() != null &&
          theme.barStylePlus.strokeColor != theme.barStylePlus.fillColor;
      final strokeMinus =
          theme.barStyleMinus.getStrokePaint() != null &&
          theme.barStyleMinus.strokeColor != theme.barStyleMinus.fillColor;
      for (var i = 0; i < graphValues.length; i++) {
        final x = graphValues[i][0];
        final x1 = x - barRenderWidth / 2;
        final x2 = x + barRenderWidth / 2;
        final open = graphValues[i][1]; // this is position not price value
        final high = graphValues[i][2];
        final low = graphValues[i][3];
        final close = graphValues[i][4];

        if (open >= close) {
          if (strokePlus) {
            // high and low and bar borders
            borderPlus.addAll([
              ...[x, high, x, close],
              ...[x, low, x, open],
              ...[x1, close, x2, close],
              ...[x1, open, x2, open],
              ...[x1, open, x1, close],
              ...[x2, close, x2, open],
            ]);
          } else {
            // high and low only
            borderPlus.addAll([
              ...[x, high, x, close],
              ...[x, low, x, open],
            ]);
          }
          if (theme.barStylePlus.getFillPaint() != null) {
            if ((open - close).abs() < 1) {
              // make sure a least 1 pixel is drawn
              final adjust = (1.0 - (open - close).abs()) * 0.5;
              fillPlus.addAll([x, open + adjust, x, close - adjust]);
            } else {
              fillPlus.addAll([x, open, x, close]);
            }
          }
        } else {
          if (strokeMinus) {
            // high and low and bar borders
            borderMinus.addAll([
              ...[x, high, x, open],
              ...[x, low, x, close],
              ...[x1, open, x2, open],
              ...[x1, close, x2, close],
              ...[x1, close, x1, open],
              ...[x2, open, x2, close],
            ]);
          } else {
            // high and low only
            borderMinus.addAll([
              ...[x, high, x, open],
              ...[x, low, x, close],
            ]);
          }
          if (theme.barStyleMinus.getFillPaint() != null) {
            if ((open - close).abs() < 1) {
              // make sure a least 1 pixel is drawn
              final adjust = (1.0 - (open - close).abs()) * 0.5;
              fillMinus.addAll([x, open - adjust, x, close + adjust]);
            } else {
              fillMinus.addAll([x, open, x, close]);
            }
          }
        }
      }
      // draw the bars
      if (fillPlus.isNotEmpty) {
        final fillPlusPaint =
            Paint()
              ..color =
                  theme.barStylePlus.fillColor ??
                  const Color.fromARGB(0, 0, 0, 0)
              ..style = PaintingStyle.fill
              ..strokeWidth = barRenderWidth;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(fillPlus),
          fillPlusPaint,
        );
      }
      if (fillMinus.isNotEmpty) {
        final fillMinusPaint =
            Paint()
              ..color =
                  theme.barStyleMinus.fillColor ??
                  const Color.fromARGB(0, 0, 0, 0)
              ..style = PaintingStyle.fill
              ..strokeWidth = barRenderWidth;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(fillMinus),
          fillMinusPaint,
        );
      }
      // draw the lines
      if (borderPlus.isNotEmpty) {
        final borderPlusPaint =
            Paint()
              ..color =
                  (theme.barStylePlus.strokeColor ??
                      theme.barStylePlus.fillColor ??
                      const Color.fromARGB(0, 0, 0, 0))
              ..strokeWidth = min(
                max(1, theme.barStylePlus.strokeWidth ?? 1.0),
                barRenderWidth,
              )
              ..strokeCap = theme.barStylePlus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderPlus),
          borderPlusPaint,
        );
      }
      if (borderMinus.isNotEmpty) {
        final borderMinusPaint =
            Paint()
              ..color =
                  (theme.barStyleMinus.strokeColor ??
                      theme.barStyleMinus.fillColor ??
                      const Color.fromARGB(0, 0, 0, 0))
              ..strokeWidth = min(
                max(1, theme.barStyleMinus.strokeWidth ?? 1.0),
                barRenderWidth,
              )
              ..strokeCap = theme.barStyleMinus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderMinus),
          borderMinusPaint,
        );
      }
      return;
    }
    for (var i = 0; i < graphValues.length; i++) {
      final barPosition = graphValues[i][0];
      final op = graphValues[i][1];
      final hp = graphValues[i][2];
      final lp = graphValues[i][3];
      final cp = graphValues[i][4];

      if (op >= cp) {
        final fillPath =
            Path()
              ..moveTo(barPosition - barRenderWidth / 2, cp)
              ..lineTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition + barRenderWidth / 2, op)
              ..lineTo(barPosition + barRenderWidth / 2, cp)
              ..close();
        drawPath(
          canvas: canvas,
          path: fillPath,
          style: theme.barStylePlus,
          fillOnly: true,
        );
        final strokePath =
            Path()
              ..moveTo(barPosition, hp)
              ..lineTo(barPosition, cp)
              ..lineTo(barPosition - barRenderWidth / 2, cp)
              ..lineTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition + barRenderWidth / 2, op)
              ..lineTo(barPosition + barRenderWidth / 2, cp)
              ..lineTo(barPosition, cp)
              ..moveTo(barPosition, op)
              ..lineTo(barPosition, lp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStylePlus,
          strokeOnly: true,
        );
      } else {
        final fillPath =
            Path()
              ..moveTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition - barRenderWidth / 2, cp)
              ..lineTo(barPosition + barRenderWidth / 2, cp)
              ..lineTo(barPosition + barRenderWidth / 2, op)
              ..close();
        drawPath(
          canvas: canvas,
          path: fillPath,
          style: theme.barStyleMinus,
          fillOnly: true,
        );
        final strokePath =
            Path()
              ..moveTo(barPosition, hp)
              ..lineTo(barPosition, op)
              ..lineTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition - barRenderWidth / 2, cp)
              ..lineTo(barPosition + barRenderWidth / 2, cp)
              ..lineTo(barPosition + barRenderWidth / 2, op)
              ..lineTo(barPosition, op)
              ..moveTo(barPosition, cp)
              ..lineTo(barPosition, lp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStyleMinus,
          strokeOnly: true,
        );
      }
    }
  }

  void _drawOhlcGraph(
    Canvas canvas,
    GGraphOhlc graph,
    GGraphOhlcTheme theme,
    double barRenderWidth,
    List<List<double>> graphValues,
  ) {
    if (theme.barStyleMinus.isSimple && theme.barStylePlus.isSimple) {
      final borderPlus = <double>[];
      final borderMinus = <double>[];
      for (var i = 0; i < graphValues.length; i++) {
        final x = graphValues[i][0];
        final x1 = x - barRenderWidth / 2;
        final x2 = x + barRenderWidth / 2;
        final open = graphValues[i][1]; // this is position not price value
        final high = graphValues[i][2];
        final low = graphValues[i][3];
        final close = graphValues[i][4];
        // ohlc needs only lines
        (open >= close ? borderPlus : borderMinus).addAll([
          ...[x1, open, x, open],
          ...[x, high, x, low],
          ...[x, close, x2, close],
        ]);
      }
      // batch draw the ohlc lines
      if (borderPlus.isNotEmpty) {
        final borderPlusPaint =
            Paint()
              ..color =
                  (theme.barStylePlus.strokeColor ??
                      theme.barStylePlus.fillColor ??
                      const Color.fromARGB(0, 0, 0, 0))
              ..strokeWidth = min(
                max(1, theme.barStylePlus.strokeWidth ?? 1.0),
                barRenderWidth,
              )
              ..strokeCap = theme.barStylePlus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderPlus),
          borderPlusPaint,
        );
      }
      if (borderMinus.isNotEmpty) {
        final borderMinusPaint =
            Paint()
              ..color =
                  (theme.barStyleMinus.strokeColor ??
                      theme.barStyleMinus.fillColor ??
                      const Color.fromARGB(0, 0, 0, 0))
              ..strokeWidth = min(
                max(1, theme.barStyleMinus.strokeWidth ?? 1.0),
                barRenderWidth,
              )
              ..strokeCap = theme.barStyleMinus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderMinus),
          borderMinusPaint,
        );
      }
      return;
    }

    for (var i = 0; i < graphValues.length; i++) {
      final barPosition = graphValues[i][0];
      final op = graphValues[i][1];
      final hp = graphValues[i][2];
      final lp = graphValues[i][3];
      final cp = graphValues[i][4];

      if (op >= cp) {
        final strokePath =
            Path()
              ..moveTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition, op)
              ..moveTo(barPosition, hp)
              ..lineTo(barPosition, lp)
              ..moveTo(barPosition, cp)
              ..lineTo(barPosition + barRenderWidth / 2, cp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStylePlus,
          strokeOnly: true,
        );
      } else {
        final strokePath =
            Path()
              ..moveTo(barPosition - barRenderWidth / 2, op)
              ..lineTo(barPosition, op)
              ..moveTo(barPosition, hp)
              ..lineTo(barPosition, lp)
              ..moveTo(barPosition, cp)
              ..lineTo(barPosition + barRenderWidth / 2, cp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStyleMinus,
          strokeOnly: true,
        );
      }
    }
  }

  final List<List<Vector2>> _hitTestLines = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLines.isEmpty) {
      return false;
    }
    return super.hitTestLines(
      lines: _hitTestLines,
      position: position,
      epsilon: epsilon,
    );
  }
}
