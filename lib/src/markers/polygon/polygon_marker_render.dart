import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/markers/polygon/polygon_marker.dart';

class GPolygonMarkerRender
    extends GOverlayMarkerRender<GPolygonMarker, GOverlayMarkerTheme> {
  const GPolygonMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GPolygonMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final points = marker.keyCoordinates
        .map(
          (e) => e.toPosition(
            area: area,
            valueViewPort: valueViewPort,
            pointViewPort: pointViewPort,
          ),
        )
        .toList(growable: false);
    final path = addPolygonPath(points: points, close: marker.close);
    drawPath(canvas: canvas, path: path, style: theme.markerStyle);
  }
}
