import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render.dart';
import 'package:financial_chart/src/components/splitter/splitter.dart';
import 'package:financial_chart/src/components/splitter/splitter_theme.dart';

/// The render for [GSplitter].
class GSplitterRender extends GRender<GSplitter, GSplitterTheme> {
  const GSplitterRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GSplitter component,
    required Rect area,
    required GSplitterTheme theme,
    GPanel? panel,
  }) {
    final crossPosition = chart.crosshair.getCrossPosition() ?? Offset.infinite;
    if (chart.isScaling) {
      return;
    }
    for (var p = 0; p < chart.panels.length - 1; p++) {
      final panel = chart.panels[p];
      final nextPanel = chart.nextVisiblePanel(startIndex: p + 1);
      if (panel.splitterArea().contains(crossPosition) ||
          p == component.resizingPanelIndex) {
        if (panel.resizable && (nextPanel?.resizable == true)) {
          renderClipped(
            canvas: canvas,
            clipRect: area,
            render:
                () => doRenderSplitter(
                  canvas: canvas,
                  area: panel.splitterArea(),
                  theme: theme,
                ),
          );
        }
      }
    }
  }

  void doRenderSplitter({
    required Canvas canvas,
    required Rect area,
    required GSplitterTheme theme,
  }) {
    final center = area.center;
    final handleLineWidthHalf = theme.handleWidth * 0.5 * 0.6;
    final handleLineOffset = area.height * 0.2;

    final linePath = Path();
    addLinePath(
      toPath: linePath,
      x1: area.left,
      y1: center.dy,
      x2: area.right,
      y2: center.dy,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    final rectPath = Path();
    addRectPath(
      toPath: rectPath,
      rect: Rect.fromCenter(
        center: center,
        width: theme.handleWidth,
        height: area.height,
      ),
      cornerRadius: theme.handleBorderRadius,
    );
    drawPath(canvas: canvas, path: rectPath, style: theme.handleStyle);

    final handleLinesPath = Path();
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx - handleLineWidthHalf,
      y1: center.dy,
      x2: center.dx + handleLineWidthHalf,
      y2: center.dy,
    );
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx + handleLineWidthHalf,
      y1: center.dy - handleLineOffset,
      x2: center.dx - handleLineWidthHalf,
      y2: center.dy - handleLineOffset,
    );
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx + handleLineWidthHalf,
      y1: center.dy + handleLineOffset,
      x2: center.dx - handleLineWidthHalf,
      y2: center.dy + handleLineOffset,
    );
    drawPath(
      canvas: canvas,
      path: handleLinesPath,
      style: theme.handleLineStyle,
    );
  }
}
