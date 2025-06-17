import 'dart:math';
import 'dart:ui';

import 'package:financial_chart/src/vector/vectors/extensions.dart';
import 'package:vector_math/vector_math.dart';

class LineUtil {
  static Vector2 nearestPointOn({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
  }) {
    if (x1 == x2) {
      if (py > max(y1, y2)) {
        return Vector2(x1, max(y1, y2));
      } else if (py < min(y1, y2)) {
        return Vector2(x1, min(y1, y2));
      } else {
        return Vector2(x1, py);
      }
    } else if (y1 == y2) {
      if (px > max(x1, x2)) {
        return Vector2(max(x1, x2), y1);
      } else if (px < min(x1, x2)) {
        return Vector2(min(x1, x2), y1);
      } else {
        return Vector2(px, y1);
      }
    }
    final A = Vector2(x1, y1);
    final B = Vector2(x2, y2);
    final P = Vector2(px, py);
    //return projection(A, B, P);
    return (P - A).projection(B - A, clamp: true) + A;
  }

  static double distanceTo({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
  }) {
    final nearestPoint = nearestPointOn(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      px: px,
      py: py,
    );
    return Vector2(px, py).distanceTo(nearestPoint);
  }

  static bool hitTest({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
    double epsilon = 5.0,
  }) {
    final distance = distanceTo(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      px: px,
      py: py,
    );
    return distance <= epsilon;
  }

  static Offset? findIntersectionPointOfTwoLineSegments(
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    final x1 = p1.dx;
    final y1 = p1.dy;
    final x2 = p2.dx;
    final y2 = p2.dy;
    final x3 = p3.dx;
    final y3 = p3.dy;
    final x4 = p4.dx;
    final y4 = p4.dy;

    final denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
      return null;
    }
    final x =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
        denominator;
    final y =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
        denominator;

    final intersection = Offset(x, y);
    if (x < p1.dx || x > p2.dx || x < p3.dx || x > p4.dx) {
      return null;
    }
    return intersection;
  }
}
