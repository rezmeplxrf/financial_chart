import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render_util.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/markers/shapes/shape_marker.dart';
import 'package:flutter/painting.dart';

class GShapeMarkerRender
    extends GOverlayMarkerRender<GShapeMarker, GOverlayMarkerTheme> {
  const GShapeMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GShapeMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isNotEmpty) {
      // radius with anchor point and alignment
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = marker.radiusSize.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );

      final alignment =
          marker
              .alignment; // where anchor point located on the bound rect of the circle
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: radius * 2,
        height: radius * 2,
        alignment: alignment,
      );
      final center = rect.center;
      //Path path = addOvalPath(rect: rect);
      canvas
        ..save()
        ..translate(center.dx, center.dy);
      if (marker.rotation != 0) {
        canvas.rotate(marker.rotation);
      }
      final path = marker.pathGenerator(radius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
      canvas.restore();
    }
  }
}
