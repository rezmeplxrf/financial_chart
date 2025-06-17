import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render_util.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/markers/spline/spline_marker.dart';
import 'package:financial_chart/src/vector/vectors.dart';

class GSplineMarkerRender
    extends GOverlayMarkerRender<GSplineMarker, GOverlayMarkerTheme> {
  const GSplineMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GSplineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    } else if (marker.keyCoordinates.length == 2) {
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
      final path = addLinePath(
        x1: start.dx,
        y1: start.dy,
        x2: end.dx,
        y2: end.dy,
      );
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    } else {
      final points = marker.keyCoordinates
          .map(
            (c) =>
                c
                    .toPosition(
                      area: area,
                      valueViewPort: valueViewPort,
                      pointViewPort: pointViewPort,
                    )
                    .toVector2(),
          )
          .toList(growable: false);
      final splinePoints = SplineUtil.catmullRomSpline(points, marker.close)
          .map((l) => l.map((v) => v.toOffset()).toList(growable: false))
          .toList(growable: false);
      final path = GRenderUtil.addSplinePath(
        start: points[0].toOffset(),
        cubicList: splinePoints,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    }
  }

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}
