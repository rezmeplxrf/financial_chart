// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:ui';

import 'package:financial_chart/src/vector/vectors/extensions.dart';
import 'package:financial_chart/src/vector/vectors/polygon.dart';
import 'package:vector_math/vector_math.dart';

class SplineUtil {
  static const int kDefaultSampleSize = 20;

  /// Gets control points of a point list.
  static List<Vector2> _catmullRomControlPoints(
    List<Vector2> vectors,
    double ratio,
    bool isLoop,
    bool hasConstraint, [
    Rect? constraint,
  ]) {
    final cps = <Vector2>[];
    Vector2 prevVector;
    Vector2 nextVector;
    Vector2? min;
    Vector2? max;

    // The real constraint is calculated as:
    // - If constraint is null, is the boundary of points.
    // - If constraint is not null, is the larger one of constraint and boundary of
    // points.
    if (hasConstraint) {
      min = Vector2(double.infinity, double.infinity);
      max = Vector2(double.negativeInfinity, double.negativeInfinity);

      for (final vector in vectors) {
        Vector2.min(min, vector, min);
        Vector2.max(max, vector, max);
      }
      if (constraint != null) {
        Vector2.min(min, Vector2Extension.fromOffset(constraint.topLeft), min);
        Vector2.max(
          max,
          Vector2Extension.fromOffset(constraint.bottomRight),
          max,
        );
      }
    }

    final len = vectors.length;
    for (var i = 0; i < len; i++) {
      final vector = vectors[i];
      if (isLoop) {
        prevVector = vectors[i >= 1 ? i - 1 : len - 1];
        nextVector = vectors[(i + 1) % len];
      } else {
        if (i == 0 || i == len - 1) {
          cps.add(vectors[i]);
          continue;
        } else {
          prevVector = vectors[i - 1];
          nextVector = vectors[i + 1];
        }
      }

      final v = (nextVector - prevVector) * ratio;
      var d0 = vector.distanceTo(prevVector);
      var d1 = vector.distanceTo(nextVector);

      final sum = d0 + d1;
      if (sum != 0) {
        d0 /= sum;
        d1 /= sum;
      }

      final v1 = v * (-d0);
      final v2 = v * d1;

      final cp0 = vector + v1;
      final cp1 = vector + v2;

      if (hasConstraint) {
        Vector2.max(cp0, min!, cp0);
        Vector2.min(cp0, max!, cp0);
        Vector2.max(cp1, min, cp1);
        Vector2.min(cp1, max, cp1);
      }

      cps
        ..add(cp0)
        ..add(cp1);
    }

    if (isLoop) {
      cps.add(cps.removeAt(0));
    }
    return cps;
  }

  /// Produces a cubic Catmull–Rom spline.
  static List<List<Vector2>> catmullRomSpline(
    List<Vector2> points,
    bool isLoop, {
    bool hasConstraint = false,
    Rect? constraint,
    double ratio = 0.5,
  }) {
    // Alpha is 0.5, as proposed by Yuksel et al.
    // Thus is called a centripetal spline: https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline
    final controlPointList = _catmullRomControlPoints(
      points,
      ratio,
      isLoop,
      hasConstraint,
      constraint,
    );
    final len = points.length;
    final rst = <List<Vector2>>[];

    Vector2 cp1;
    Vector2 cp2;
    Vector2 p;

    for (var i = 0; i < len - 1; i++) {
      cp1 = controlPointList[i * 2];
      cp2 = controlPointList[i * 2 + 1];
      p = points[i + 1];
      rst.add([cp1, cp2, p]);
    }

    if (isLoop) {
      cp1 = controlPointList[(len - 1) * 2];
      cp2 = controlPointList[(len - 1) * 2 + 1];
      p = points[0];
      rst.add([cp1, cp2, p]);
    }

    return rst;
  }

  // Function to calculate a point along a Bézier curve for a given parameter
  static Vector2 _bezierPoint(
    Vector2 out,
    List<Vector2> curve,
    double t,
    List<Vector2> tmps,
  ) {
    if (curve.length < 2) {
      throw ArgumentError('At least 2 control points are required');
    }

    List<Vector2> localTmps;
    if (tmps.isEmpty) {
      localTmps = curve.map((pt) => pt.clone()).toList();
    } else {
      localTmps = tmps;
      for (var i = 0; i < curve.length; i++) {
        localTmps[i].setFrom(curve[i]);
      }
    }

    for (var degree = curve.length - 1; degree-- > 0;) {
      for (var i = 0; i <= degree; ++i) {
        localTmps[i].lerp(localTmps[i + 1], t);
      }
    }

    out.setFrom(localTmps[0]);
    return out;
  }

  static List<Vector2> sampleSplines(
    List<List<Vector2>> controlPoints,
    int sampleSize,
    bool isLoop,
  ) {
    final samples = <Vector2>[];
    final tmps = <Vector2>[];
    Vector2? last;
    for (var i = 0; i < controlPoints.length; i++) {
      final cps = controlPoints[i];
      if (cps.length < 3) {
        continue;
      }
      if (i == 0) {
        last = isLoop ? controlPoints.last[2] : cps[0];
      } else {
        last = controlPoints[i - 1][2];
      }
      final curve = <Vector2>[last, cps[0], cps[1], cps[2]];
      sampleSpline(
        curve[0],
        curve[1],
        curve[2],
        curve[3],
        sampleSize,
        samples,
        tmps,
      );
    }
    return samples;
  }

  static void sampleSpline(
    Vector2 p0,
    Vector2 p1,
    Vector2 p2,
    Vector2 p3,
    int sampleSize,
    List<Vector2> out,
    List<Vector2> tmps,
  ) {
    for (var i = 0; i <= sampleSize; i++) {
      out.add(
        _bezierPoint(
          Vector2.zero(),
          [p0, p1, p2, p3],
          i / sampleSize,
          tmps,
        ),
      );
    }
  }

  static Vector2 nearestPointOnSplines(
    List<List<Vector2>> curves,
    Vector2 pt,
    bool isLoop, {
    int sampleSize = kDefaultSampleSize,
    double epsilon = 1e-4,
  }) {
    final segments = sampleSplines(curves, sampleSize, isLoop);
    return PolygonUtil.nearestPointOn(vertices: segments, px: pt.x, py: pt.y);
  }

  static double distanceToSplines(
    List<List<Vector2>> curves,
    Vector2 pt,
    bool isLoop, {
    int sampleSize = kDefaultSampleSize,
    double epsilon = 1e-4,
  }) {
    final segments = sampleSplines(curves, sampleSize, isLoop);
    return PolygonUtil.distanceTo(vertices: segments, px: pt.x, py: pt.y);
  }

  static bool isInsideSplines(
    List<List<Vector2>> curves,
    Vector2 pt,
    bool isLoop, {
    int sampleSize = kDefaultSampleSize,
  }) {
    final segments = sampleSplines(curves, sampleSize, isLoop);
    return PolygonUtil.isInside(vertices: segments, px: pt.x, py: pt.y);
  }

  static bool hitTest(
    List<List<Vector2>> curves,
    Vector2 pt,
    bool isLoop, {
    bool testArea = false,
    int sampleSize = kDefaultSampleSize,
    double epsilon = 5,
  }) {
    final segments = sampleSplines(curves, sampleSize, isLoop);
    return PolygonUtil.hitTest(
      vertices: segments,
      px: pt.x,
      py: pt.y,
      testArea: testArea,
      epsilon: epsilon,
    );
  }
}
