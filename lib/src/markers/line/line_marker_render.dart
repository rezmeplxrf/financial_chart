import 'dart:ui';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'line_marker.dart';

class GLineMarkerRender
    extends GOverlayMarkerRender<GLineMarker, GOverlayMarkerTheme> {
  const GLineMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GLineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    for (int i = 0; i < marker.keyCoordinates.length - 1; i++) {
      final startPosition = marker.keyCoordinates[i].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final endPosition = marker.keyCoordinates[i + 1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      Path path = addLinePath(
        x1: startPosition.dx,
        y1: startPosition.dy,
        x2: endPosition.dx,
        y2: endPosition.dy,
      );
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    }
  }

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}
