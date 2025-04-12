import 'dart:ui';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'polygon_marker.dart';

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
    Path path = addPolygonPath(points: points, close: marker.close);
    drawPath(canvas: canvas, path: path, style: theme.markerStyle);
  }
}
