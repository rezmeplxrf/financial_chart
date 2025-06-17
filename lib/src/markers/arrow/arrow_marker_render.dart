import 'dart:math';
import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/markers/arrow/arrow_marker.dart';

class GArrowMarkerRender
    extends GOverlayMarkerRender<GArrowMarker, GOverlayMarkerTheme> {
  const GArrowMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GArrowMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length == 2) {
      final start = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final end = marker.keyCoordinates[1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );

      // draw the arrow triangle along the line direction
      final arrowPath = Path();
      final headLength = marker.headLength;
      final headWidth = marker.headWidth;
      final angle = atan2(end.dy - start.dy, end.dx - start.dx);
      final arrowStart = Offset(
        end.dx - headLength * cos(angle),
        end.dy - headLength * sin(angle),
      );
      final arrowEnd = Offset(
        arrowStart.dx + headWidth * cos(angle + pi / 2),
        arrowStart.dy + headWidth * sin(angle + pi / 2),
      );
      final arrowStart2 = Offset(
        end.dx - headLength * cos(angle),
        end.dy - headLength * sin(angle),
      );
      final arrowEnd2 = Offset(
        arrowStart2.dx + headWidth * cos(angle - pi / 2),
        arrowStart2.dy + headWidth * sin(angle - pi / 2),
      );
      arrowPath
        ..moveTo(end.dx, end.dy)
        ..lineTo(arrowEnd.dx, arrowEnd.dy)
        ..lineTo(arrowEnd2.dx, arrowEnd2.dy)
        ..close();
      drawPath(canvas: canvas, path: arrowPath, style: theme.markerStyle);

      // draw the line from start to middle of the arrow head
      final linePath =
          Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(arrowStart.dx, arrowStart.dy);
      drawPath(canvas: canvas, path: linePath, style: theme.markerStyle);
    }
  }
}
