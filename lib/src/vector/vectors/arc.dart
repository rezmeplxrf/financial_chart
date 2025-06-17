import 'dart:math';
import 'package:vector_math/vector_math.dart';

class ArcUtil {
  static double _normalizeStartTheta(double startTheta, double endTheta) {
    var theta = startTheta;
    if (theta < 0) {
      theta += 2 * pi;
    }
    if (theta > endTheta) {
      theta -= 2 * pi;
    }
    return theta;
  }

  static (double startTheta, double endTheta) calculateAngleRange(
    double cx,
    double cy,
    double startX,
    double startY,
    double endX,
    double endY,
  ) {
    var startTheta = atan2(startY - cy, startX - cx);
    var endTheta = atan2(endY - cy, endX - cx);
    if (endTheta < 0) {
      endTheta += 2 * pi;
    }
    startTheta = _normalizeStartTheta(startTheta, endTheta);
    return (startTheta, endTheta);
  }

  static Vector2 nearestPointOn(
    double cx,
    double cy,
    double r,
    double startTheta,
    double endTheta,
    double px,
    double py,
  ) {
    var theta = atan2(py - cy, px - cx);
    theta = _normalizeStartTheta(theta, endTheta);
    if (theta >= startTheta && theta <= endTheta) {
      return Vector2(cx + r * cos(theta), cy + r * sin(theta));
    } else {
      // return start or end point
      final point = Vector2(px, py);
      final start = Vector2(
        cx + r * cos(startTheta),
        cy + r * sin(startTheta),
      );
      final end = Vector2(cx + r * cos(endTheta), cy + r * sin(endTheta));
      return point.distanceTo(start) < point.distanceTo(end) ? start : end;
    }
  }

  static double distanceTo(
    double cx,
    double cy,
    double r,
    double thetaStart,
    double thetaEnd,
    double px,
    double py,
  ) {
    final nearestPoint = nearestPointOn(
      cx,
      cy,
      r,
      thetaStart,
      thetaEnd,
      px,
      py,
    );
    return Vector2(px, py).distanceTo(nearestPoint);
  }

  static bool isInside(
    double cx,
    double cy,
    double r,
    double startTheta,
    double endTheta,
    double px,
    double py,
  ) {
    final point = Vector2(px, py);
    if (point.distanceTo(Vector2(cx, cy)) > r) {
      return false;
    }
    var theta = atan2(point.y - cy, point.x - cx);
    theta = _normalizeStartTheta(theta, endTheta);
    return theta >= startTheta && theta <= endTheta;
  }

  static bool hitTest({
    required double cx,
    required double cy,
    required double r,
    required double startTheta,
    required double endTheta,
    required double px,
    required double py,
    bool testArea = false,
    double epsilon = 5,
  }) {
    if (testArea) {
      return isInside(cx, cy, r, startTheta, endTheta, px, py);
    }
    return distanceTo(cx, cy, r, startTheta, endTheta, px, py) < epsilon;
  }
}
