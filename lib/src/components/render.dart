import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/axis/axis.dart';
import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render_util.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';
import 'package:flutter/painting.dart';

/// Base class for component renderers.
abstract class GRender<C extends GComponent, T extends GComponentTheme> {
  const GRender({this.hitTestEpsilon = 5.0});

  final double hitTestEpsilon;

  void render({
    required Canvas canvas,
    required GChart chart,
    required C component, required Rect area, required T theme, GPanel? panel,
  }) {
    if (component.visible == false) {
      return;
    }
    renderClipped(
      canvas: canvas,
      clipRect: area,
      render:
          () => doRender(
            canvas: canvas,
            chart: chart,
            panel: panel,
            component: component,
            area: area,
            theme: theme,
          ),
    );
  }

  void renderClipped({
    required Canvas canvas,
    required Rect clipRect,
    required void Function() render,
  }) {
    GRenderUtil.renderClipped(
      canvas: canvas,
      clipRect: clipRect,
      render: render,
    );
  }

  void renderRotated({
    required Canvas canvas,
    required Offset center,
    required double theta,
    required void Function() render,
  }) {
    GRenderUtil.renderRotated(
      canvas: canvas,
      center: center,
      theta: theta,
      render: render,
    );
  }

  void drawPath({
    required Canvas canvas,
    required Path path,
    required PaintStyle style,
    bool ignoreDash = false,
    bool fillOnly = false,
    bool strokeOnly = false,
  }) {
    GRenderUtil.drawPath(
      canvas: canvas,
      path: path,
      style: style,
      ignoreDash: ignoreDash,
      fillOnly: fillOnly,
      strokeOnly: strokeOnly,
    );
  }

  Rect drawText({
    required Canvas canvas,
    required String text,
    required LabelStyle style, Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
  }) {
    return GRenderUtil.drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: style,
    );
  }

  Rect drawValueAxisLabel({
    required Canvas canvas,
    required String text,
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return GRenderUtil.drawValueAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
  }

  Rect drawPointAxisLabel({
    required Canvas canvas,
    required String text,
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return GRenderUtil.drawPointAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
  }

  Offset getTextBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align,
  ) => GRenderUtil.getTextBlockPaintPoint(axis, width, height, align);

  Path addLinePath({
    required double x1, required double y1, required double x2, required double y2, Path? toPath,
  }) => GRenderUtil.addLinePath(toPath: toPath, x1: x1, y1: y1, x2: x2, y2: y2);

  Path addRectPath({
    required Rect rect, Path? toPath,
    double cornerRadius = 0,
  }) => GRenderUtil.addRectPath(
    toPath: toPath,
    rect: rect,
    cornerRadius: cornerRadius,
  );

  Path addOvalPath({
    required Rect rect, Path? toPath,
    double cornerRadius = 0,
  }) => GRenderUtil.addOvalPath(
    toPath: toPath,
    rect: rect,
    cornerRadius: cornerRadius,
  );

  Path addPolygonPath({
    required List<Offset> points, required bool close, Path? toPath,
    double cornerRadius = 0,
  }) => GRenderUtil.addPolygonPath(
    toPath: toPath,
    points: points,
    close: close,
    cornerRadius: cornerRadius,
  );

  Offset valueAxisLabelAnchor({
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) => GRenderUtil.valueAxisLabelAnchor(
    axis: axis,
    position: position,
    axisArea: axisArea,
    labelTheme: labelTheme,
  );

  Alignment valueAxisLabelAlignment({required GValueAxis axis}) =>
      GRenderUtil.valueAxisLabelAlignment(axis: axis);

  Offset pointAxisLabelAnchor({
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) => GRenderUtil.pointAxisLabelAnchor(
    axis: axis,
    position: position,
    axisArea: axisArea,
    labelTheme: labelTheme,
  );

  Alignment pointAxisLabelAlignment({required GPointAxis axis}) =>
      GRenderUtil.pointAxisLabelAlignment(axis: axis);

  void doRender({
    required Canvas canvas,
    required GChart chart,
    required C component, required Rect area, required T theme, GPanel? panel,
  });

  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}

class GEmptyRender extends GRender<GComponent, GComponentTheme> {
  const GEmptyRender();

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GComponent component, required Rect area, required GComponentTheme theme, GPanel? panel,
  }) {
    // Do nothing
  }
}
