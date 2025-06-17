import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render_util.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/markers/rect/rect_marker.dart';

class GRectMarkerRender
    extends GOverlayMarkerRender<GRectMarker, GOverlayMarkerTheme> {
  const GRectMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GRectMarker marker,
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
      final cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      final path = addRectPath(
        rect: Rect.fromPoints(start, end),
        cornerRadius: cornerRadius,
      );
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    } else if (marker.keyCoordinates.length == 1 &&
        marker.pointRadiusSize != null &&
        marker.valueRadiusSize != null) {
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final pointRadius = marker.pointRadiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final valueRadius = marker.valueRadiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: pointRadius * 2,
        height: valueRadius * 2,
        alignment: marker.alignment,
      );
      final path = addRectPath(rect: rect, cornerRadius: cornerRadius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    }
  }
}
