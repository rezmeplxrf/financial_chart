import 'dart:math';

import 'package:flutter/painting.dart';

class GShapes {
  static Path circle(double radius) {
    final path =
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
    return path;
  }

  static Path star(double radius, {required int vertexCount}) {
    final path = Path();
    final innerRadius = radius * 0.5;
    for (var i = 0; i < vertexCount * 2; i++) {
      final radian = pi / vertexCount * i.toDouble();
      final x = (i.isEven ? innerRadius : radius) * cos(radian);
      final y = (i.isEven ? innerRadius : radius) * sin(radian);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static Path heart(double radius) {
    final path =
        Path()
          ..moveTo(0, radius)
          ..cubicTo(
            -radius * 2,
            -radius * 0.5,
            -radius * 0.5,
            -radius * 1.5,
            0,
            -radius * 0.5,
          )
          ..cubicTo(
            radius * 0.5,
            -radius * 1.5,
            radius * 2,
            -radius * 0.5,
            0,
            radius,
          )
          ..close();
    return path;
  }

  static Path polygon(double radius, {required int vertexCount}) {
    final path = Path();
    for (var i = 0; i < vertexCount; i++) {
      final radian = pi * 2 / vertexCount * i.toDouble();
      final x = radius * cos(radian);
      final y = radius * sin(radian);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
