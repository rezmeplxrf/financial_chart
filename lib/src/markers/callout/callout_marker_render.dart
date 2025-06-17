import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/markers/callout/callout_marker.dart';
import 'package:financial_chart/src/vector/vectors/circle.dart';
import 'package:flutter/painting.dart';

class GCalloutMarkerRender
    extends GOverlayMarkerRender<GCalloutMarker, GOverlayMarkerTheme> {
  const GCalloutMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GCalloutMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isEmpty) {
      return;
    }
    final anchor = marker.keyCoordinates[0].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    final (painter, textPaintPoint, blockArea) = GRenderUtil.createTextPainter(
      text: marker.text,
      anchor: anchor,
      defaultAlign: marker.alignment,
      style: theme.labelStyle!,
    );
    if (theme.labelStyle?.backgroundStyle != null) {
      final alignment = marker.alignment;
      final pointerMargin = marker.pointerMargin;
      final rect = blockArea.translate(
        alignment.x * pointerMargin,
        alignment.y * pointerMargin,
      );
      final bgPath = _createBackgroundPath(marker, theme, anchor, rect);
      drawPath(
        canvas: canvas,
        path: bgPath,
        style: theme.labelStyle!.backgroundStyle!,
      );
      painter.paint(
        canvas,
        textPaintPoint.translate(
          alignment.x * pointerMargin,
          alignment.y * pointerMargin,
        ),
      );
    } else {
      painter.paint(canvas, textPaintPoint);
    }
  }

  Path _createBackgroundPath(
    GCalloutMarker marker,
    GOverlayMarkerTheme theme,
    Offset anchor,
    Rect textRect,
  ) {
    final pointerSize = marker.pointerSize;
    final borderRadius = theme.labelStyle?.backgroundCornerRadius ?? 0;
    final alignment = marker.alignment;
    final rect = textRect;

    final path1 =
        Path()..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        );

    final path2 = Path();
    double triangleX1 = 0;
    double triangleY1 = 0;
    double triangleX2 = 0;
    double triangleY2 = 0;
    double cornerCx1 = 0;
    double cornerCy1 = 0;
    double cornerCx2 = 0;
    double cornerCy2 = 0;
    final targetX = anchor.dx;
    final targetY = anchor.dy;
    switch (alignment) {
      case Alignment.topLeft:
        triangleX1 = rect.right - pointerSize;
        triangleY1 = rect.bottom;
        triangleX2 = rect.right;
        triangleY2 = rect.bottom - pointerSize;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.topCenter:
        triangleX1 = rect.left + rect.width / 2 - pointerSize;
        triangleY1 = rect.bottom;
        triangleX2 = rect.left + rect.width / 2 + pointerSize;
        triangleY2 = rect.bottom;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if ((rect.width / 2 - pointerSize) >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.topRight:
        triangleX1 = rect.left;
        triangleY1 = rect.bottom - pointerSize;
        triangleX2 = rect.left + pointerSize;
        triangleY2 = rect.bottom;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.centerLeft:
        triangleX1 = rect.right;
        triangleY1 = rect.top + rect.height / 2 - pointerSize;
        triangleX2 = rect.right;
        triangleY2 = rect.top + rect.height / 2 + pointerSize;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.centerRight:
        triangleX1 = rect.left;
        triangleY1 = rect.top + rect.height / 2 - pointerSize;
        triangleX2 = rect.left;
        triangleY2 = rect.top + rect.height / 2 + pointerSize;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.bottomLeft:
        triangleX1 = rect.right;
        triangleY1 = rect.top + pointerSize;
        triangleX2 = rect.right - pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.bottomCenter:
        triangleX1 = rect.left + rect.width / 2 + pointerSize;
        triangleY1 = rect.top;
        triangleX2 = rect.left + rect.width / 2 - pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if ((rect.width / 2 - pointerSize) >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.bottomRight:
        triangleX1 = rect.left;
        triangleY1 = rect.top + pointerSize;
        triangleX2 = rect.left + pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if (pointerSize >= borderRadius) {
          path2
            ..moveTo(triangleX1, triangleY1)
            ..lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2
            ..moveTo(points1[0].x, points1[0].y)
            ..lineTo(points2[0].x, points2[0].y);
        }
      case Alignment.center:
        path2.moveTo(targetX, targetY);
    }
    path2
      ..lineTo(targetX, targetY)
      ..close();

    final path = Path.combine(PathOperation.union, path1, path2);

    return path;
  }
}
