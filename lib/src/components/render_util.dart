import 'dart:math';

import 'package:financial_chart/src/components/axis/axis.dart';
import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/style/dash_path.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';
import 'package:flutter/painting.dart';

/// Utility class for rendering.
class GRenderUtil {
  static void renderClipped({
    required Canvas canvas,
    required Rect clipRect,
    required void Function() render,
  }) {
    canvas
      ..save()
      ..clipRect(clipRect);
    render();
    canvas.restore();
  }

  static void renderRotated({
    required Canvas canvas,
    required Offset center,
    required double theta,
    required void Function() render,
  }) {
    if (theta == 0) {
      render();
      return;
    }
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(theta)
      ..translate(-center.dx, -center.dy);
    render();
    canvas.restore();
  }

  static void drawPath({
    required Canvas canvas,
    required Path path,
    required PaintStyle style,
    Rect? gradientBounds,
    bool ignoreDash = false,
    bool fillOnly = false,
    bool strokeOnly = false,
  }) {
    if (!strokeOnly) {
      final fillBounds =
          (style.fillGradient == null)
              ? null
              : (gradientBounds ?? style.gradientBounds ?? path.getBounds());
      final fillPaint = style.getFillPaint(gradientBounds: fillBounds);
      if (fillPaint != null) {
        canvas.drawPath(path, fillPaint);
      }
    }

    if (!fillOnly) {
      final strokeBounds =
          (style.strokeGradient == null)
              ? null
              : (gradientBounds ?? style.gradientBounds ?? path.getBounds());
      final strokePaint = style.getStrokePaint(gradientBounds: strokeBounds);
      if (strokePaint != null) {
        Path? theDashPath;
        if (!ignoreDash && style.dash != null) {
          theDashPath = dashPath(
            path,
            dashArray: CircularIntervalList(style.dash!),
            dashOffset: style.dashOffset,
          );
        }
        canvas.drawPath(theDashPath ?? path, strokePaint);
      }
    }
  }

  static (TextPainter painter, Offset textPaintPoint, Rect blockArea)
  createTextPainter({
    required String text,
    required LabelStyle style,
    Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
  }) {
    final painter = TextPainter(
      text:
          style.textStyle != null
              ? TextSpan(text: text, style: style.textStyle)
              : style.span!(text),
      textAlign: style.textAlign ?? TextAlign.start,
      textDirection: style.textDirection ?? TextDirection.ltr,
      textScaler: style.textScaler ?? TextScaler.noScaling,
      maxLines: style.maxLines,
      ellipsis: style.ellipsis,
      locale: style.locale,
      strutStyle: style.strutStyle,
      textWidthBasis: style.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: style.textHeightBehavior,
    )..layout(
      minWidth: style.minWidth ?? 0.0,
      maxWidth: style.maxWidth ?? double.infinity,
    );
    final rotationAxis = style.offset == null ? anchor : anchor + style.offset!;
    final padding = style.backgroundPadding?.resolve(style.textDirection);
    final width = painter.width + (padding?.left ?? 0) + (padding?.right ?? 0);
    final height =
        painter.height + (padding?.top ?? 0) + (padding?.bottom ?? 0);
    final point = getBlockPaintPoint(
      rotationAxis,
      width,
      height,
      style.align ?? defaultAlign,
    );
    final textPaintPoint =
        point + Offset(padding?.left ?? 0, padding?.top ?? 0);
    return (
      painter,
      textPaintPoint,
      Rect.fromLTWH(point.dx, point.dy, width, height),
    );
  }

  static Rect drawText({
    required Canvas canvas,
    required String text,
    required LabelStyle style,
    Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
  }) {
    final (painter, textPaintPoint, blockArea) = createTextPainter(
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: style,
    );
    renderRotated(
      canvas: canvas,
      center: anchor,
      theta: style.rotation ?? 0,
      render: () {
        if (style.backgroundStyle != null) {
          final blockPath = addRectPath(
            rect: blockArea,
            cornerRadius: style.backgroundCornerRadius ?? 0,
          );
          drawPath(
            canvas: canvas,
            path: blockPath,
            style: style.backgroundStyle!,
          );
        }
        painter.paint(canvas, textPaintPoint);
      },
    );
    return blockArea;
  }

  static Rect drawValueAxisLabel({
    required Canvas canvas,
    required String text,
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    final anchor = valueAxisLabelAnchor(
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
    final defaultAlign = valueAxisLabelAlignment(axis: axis);
    return drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: labelTheme.labelStyle,
    );
  }

  static Rect drawPointAxisLabel({
    required Canvas canvas,
    required String text,
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    final anchor = pointAxisLabelAnchor(
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
    final defaultAlign = pointAxisLabelAlignment(axis: axis);
    return drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: labelTheme.labelStyle,
    );
  }

  static Offset getTextBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align, {
    EdgeInsets? padding,
  }) => getBlockPaintPoint(axis, width, height, align, padding: padding);

  static Path addLinePath({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    Path? toPath,
  }) {
    final path =
        Path()
          ..moveTo(x1, y1)
          ..lineTo(x2, y2);
    toPath?.addPath(path, Offset.zero);
    return toPath ?? path;
  }

  static Path addLinesPath({required List<Offset> points, Path? toPath}) {
    var path = toPath ?? Path();
    for (var i = 0; i < points.length - 1; i++) {
      path = addLinePath(
        toPath: path,
        x1: points[i].dx,
        y1: points[i].dy,
        x2: points[i + 1].dx,
        y2: points[i + 1].dy,
      );
    }
    return path;
  }

  static Path addRectPath({
    required Rect rect,
    Path? toPath,
    double cornerRadius = 0,
  }) {
    final path = toPath ?? Path();
    if (cornerRadius > 0) {
      path.addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      );
    } else {
      path.addRect(rect);
    }
    return path;
  }

  static Path addOvalPath({
    required Rect rect,
    Path? toPath,
    double cornerRadius = 0,
  }) {
    final path =
        toPath ?? Path()
          ..addOval(rect);
    return path;
  }

  static Path addPolygonPath({
    required List<Offset> points,
    required bool close,
    Path? toPath,
    double cornerRadius = 0,
  }) {
    final path =
        toPath ?? Path()
          ..addPolygon(points, close);
    return path;
  }

  static Path addSplinePath({
    required Offset start,
    required List<List<Offset>> cubicList,
    Path? toPath,
  }) {
    final path =
        toPath ?? Path()
          ..moveTo(start.dx, start.dy);
    for (final cubic in cubicList) {
      path.cubicTo(
        cubic[0].dx,
        cubic[0].dy,
        cubic[1].dx,
        cubic[1].dy,
        cubic[2].dx,
        cubic[2].dy,
      );
    }
    return path;
  }

  static Path addArcPath({
    required Offset center,
    required double radius,
    required double startAngle,
    required double endAngle,
    Path? toPath,
    bool close = false,
  }) {
    final path =
        toPath ?? Path()
          ..moveTo(
            center.dx + radius * cos(startAngle),
            center.dy + radius * sin(startAngle),
          )
          ..arcToPoint(
            Offset(
              center.dx + radius * cos(endAngle),
              center.dy + radius * sin(endAngle),
            ),
            radius: Radius.circular(radius),
            largeArc: endAngle - startAngle > pi,
          );
    if (close) {
      path
        ..lineTo(center.dx, center.dy)
        ..close();
    }
    return path;
  }

  static Offset valueAxisLabelAnchor({
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return Offset(
      axis.isAlignLeft
          ? (axisArea.left + labelTheme.spacing)
          : (axisArea.right - labelTheme.spacing),
      position,
    );
  }

  static Alignment valueAxisLabelAlignment({required GValueAxis axis}) {
    return axis.isAlignLeft ? Alignment.centerRight : Alignment.centerLeft;
  }

  static Offset pointAxisLabelAnchor({
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return Offset(
      position,
      axis.isAlignTop
          ? (axisArea.top + labelTheme.spacing)
          : (axisArea.bottom - labelTheme.spacing),
    );
  }

  static Alignment pointAxisLabelAlignment({required GPointAxis axis}) {
    return axis.isAlignTop ? Alignment.bottomCenter : Alignment.topCenter;
  }

  /// return rect will be located at [alignment] to [anchor] point
  static Rect rectFromAnchorAndAlignment({
    required Offset anchor,
    required double width,
    required double height,
    required Alignment alignment,
    EdgeInsets? padding,
  }) {
    final pt = getBlockPaintPoint(
      anchor,
      width,
      height,
      alignment,
      padding: padding,
    );
    return Rect.fromPoints(pt, pt + Offset(width, height));
  }

  /// Calculates the real painting offset point for labels.
  static Offset getBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align, {
    EdgeInsets? padding,
  }) => Offset(
    axis.dx -
        (width / 2) +
        ((width / 2) * align.x) +
        (padding?.left ?? 0) * align.x +
        (padding?.right ?? 0) * align.x,
    axis.dy -
        (height / 2) +
        ((height / 2) * align.y) +
        (padding?.top ?? 0) * align.y +
        (padding?.bottom ?? 0) * align.y,
  );
}
