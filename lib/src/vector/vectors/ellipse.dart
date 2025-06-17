import 'dart:math';

import 'package:financial_chart/src/vector/vectors/extensions.dart';
import 'package:vector_math/vector_math.dart';

class EllipseUtil {
  static Vector2 pointOnEllipse(
    double cx,
    double cy,
    double a,
    double b,
    double t,
  ) {
    final x = cx + a * cos(t);
    final y = cy + b * sin(t);
    return Vector2(x, y);
  }

  static Vector2 pointOnEllipseRotated(
    double cx,
    double cy,
    double a,
    double b,
    double t,
    double theta,
  ) {
    // theta is the angle of rotation in pi radians
    final x = cx + a * cos(t) * cos(theta) - b * sin(t) * sin(theta);
    final y = cy + a * cos(t) * sin(theta) + b * sin(t) * cos(theta);
    return Vector2(x, y);
  }

  static Vector2 nearestPointOn(
    Vector2 point,
    double left,
    double top,
    double right,
    double bottom, {
    double rotationTheta = 0,
    double stopScanDistance = 1,
  }) {
    final point2 = point.clone();
    // Semi-major and semi-minor axes
    final rx = (right - left) / 2; // Semi-major axis
    final ry = (bottom - top) / 2; // Semi-minor axis

    final scans = (max(rx, ry) * 0.5).ceil();

    // Center of the ellipse
    final cx = (left + right) / 2;
    final cy = (top + bottom) / 2;
    if (rotationTheta != 0) {
      point2.rotate(-rotationTheta, center: Vector2(cx, cy));
    }

    var minDistance = double.infinity;
    var nearestPoint = Vector2(0, 0);
    final theta = atan2(point2.y - cy, point2.x - cx);

    double scanStartTheta = 0;
    double scanEndTheta = 0;

    // minimize the scan range to 1/4 of the ellipse
    if (theta >= 0 && theta < pi / 2) {
      scanStartTheta = 0;
      scanEndTheta = pi / 2;
    } else if (theta >= pi / 2 && theta < pi) {
      scanStartTheta = pi / 2;
      scanEndTheta = pi;
    } else if (theta >= -pi && theta < -pi / 2) {
      scanStartTheta = pi;
      scanEndTheta = 3 * pi / 2;
    } else {
      scanStartTheta = 3 * pi / 2;
      scanEndTheta = 2 * pi;
    }

    for (var i = 0; i <= scans; i++) {
      final t = scanStartTheta + (scanEndTheta - scanStartTheta) * i / scans;
      final ellipsePoint = pointOnEllipse(cx, cy, rx, ry, t);
      final dist = point2.distanceTo(ellipsePoint);

      if (dist < minDistance) {
        minDistance = dist;
        nearestPoint = ellipsePoint;
      }

      if (dist <= stopScanDistance) {
        break;
      }
    }

    if (rotationTheta != 0) {
      nearestPoint.rotate(rotationTheta, center: Vector2(cx, cy));
    }
    return nearestPoint;
  }

  static double distanceTo(
    double cx,
    double cy,
    double a,
    double b,
    double px,
    double py,
  ) {
    final nearestPoint = nearestPointOn(
      Vector2(px, py),
      cx - a,
      cy - b,
      cx + a,
      cy + b,
    );
    return Vector2(px, py).distanceTo(nearestPoint);
  }

  static bool isInside(
    double cx,
    double cy,
    double a,
    double b,
    double px,
    double py,
  ) {
    final dx = px - cx;
    final dy = py - cy;
    return (dx * dx) / (a * a) + (dy * dy) / (b * b) <= 1;
  }

  static bool hitTest({
    required double cx,
    required double cy,
    required double rx,
    required double ry,
    required double px,
    required double py,
    bool testArea = false,
    double epsilon = 5.0,
  }) {
    if (testArea) {
      return isInside(cx, cy, rx, ry, px, py);
    }
    final distance = distanceTo(cx, cy, rx, ry, px, py);
    return distance <= epsilon;
  }
}
