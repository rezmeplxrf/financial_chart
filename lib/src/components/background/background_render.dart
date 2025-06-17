import 'dart:ui';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/background/background.dart';
import 'package:financial_chart/src/components/background/background_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/render.dart';

/// The render for [GBackground].
class GBackgroundRender extends GRender<GBackground, GBackgroundTheme> {
  const GBackgroundRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    required GBackground component, required Rect area, required GBackgroundTheme theme, GPanel? panel,
  }) {
    drawPath(canvas: canvas, path: Path()..addRect(area), style: theme.style);
  }
}
