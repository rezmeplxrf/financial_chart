import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import '../../chart.dart';
import '../../components/components.dart';
import '../../values/coord.dart';
import '../../vector/vectors.dart';
import '../markers.dart';

class GArcMarkerRender
    extends GOverlayMarkerRender<GArcMarker, GOverlayMarkerTheme> {
  GArcMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GArcMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length == 2) {
      // center and border points
      final center = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final border = marker.keyCoordinates[1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = (border - center).distance;
      if (marker.hitTestMode != HitTestMode.none) {
        this.center = center;
        this.radius = radius;
        startTheta = marker.startTheta;
        endTheta = marker.endTheta;
        marker.controlCoordinates = [
          GPositionCoord(x: center.dx, y: center.dy),
          // point at the border with angle startTheta
          GPositionCoord(
            x: center.dx + radius * cos(marker.startTheta),
            y: center.dy + radius * sin(marker.startTheta),
          ),
          // point at the border with angle endTheta
          GPositionCoord(
            x: center.dx + radius * cos(marker.endTheta),
            y: center.dy + radius * sin(marker.endTheta),
          ),
        ];
      }
      Path path = GRenderUtil.addArcPath(
        center: center,
        radius: radius,
        startAngle: marker.startTheta,
        endAngle: marker.endTheta,
        close: marker.close,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    } else if (marker.keyCoordinates.length == 1 && marker.radiusSize != null) {
      // radius with anchor point and alignment
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = marker.radiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final alignment =
          marker
              .alignment; // where anchor point located on the bound rect of the circle
      Rect rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: radius * 2,
        height: radius * 2,
        alignment: alignment,
      );
      if (marker.hitTestMode != HitTestMode.none) {
        center = rect.center;
        this.radius = radius;
        startTheta = marker.startTheta;
        endTheta = marker.endTheta;
        marker.controlCoordinates = [
          GPositionCoord(x: rect.center.dx, y: rect.center.dy),
          // point at the border with angle startTheta
          GPositionCoord(
            x: rect.center.dx + radius * cos(marker.startTheta),
            y: rect.center.dy + radius * sin(marker.startTheta),
          ),
          // point at the border with angle endTheta
          GPositionCoord(
            x: rect.center.dx + radius * cos(marker.endTheta),
            y: rect.center.dy + radius * sin(marker.endTheta),
          ),
        ];
      }
      Path path = GRenderUtil.addArcPath(
        center: rect.center,
        radius: radius,
        startAngle: marker.startTheta,
        endAngle: marker.endTheta,
        close: marker.close,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    }

    if (marker.highlight && marker.controlCoordinates.isNotEmpty) {
      // draw control points
      for (var control in marker.controlCoordinates) {
        final controlPoint = control.toPosition(
          area: area,
          valueViewPort: valueViewPort,
          pointViewPort: pointViewPort,
        );
        final p = addOvalPath(
          rect: Rect.fromCircle(
            center: Offset(controlPoint.dx, controlPoint.dy),
            radius: 5,
          ),
        );
        drawPath(canvas: canvas, path: p, style: theme.controlPointsStyle!);
      }
    }
  }

  Offset? center;
  double? radius;
  double? startTheta;
  double? endTheta;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (center == null) {
      return false;
    }
    return ArcUtil.hitTest(
      cx: center!.dx,
      cy: center!.dy,
      r: radius!,
      startTheta: startTheta!,
      endTheta: endTheta!,
      px: position.dx,
      py: position.dy,
    );
  }
}
