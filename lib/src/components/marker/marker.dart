import 'dart:ui';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/marker_render.dart';
import 'package:financial_chart/src/components/marker/marker_theme.dart';

/// Base class for markers.
class GMarker extends GComponent {
  GMarker({
    super.id,
    super.visible = true,
    super.theme,
    super.render,
    super.layer,
  });
  static const int kDefaultLayer = 1000;

  @override
  GMarkerRender<GMarker, GMarkerTheme> getRender() {
    return super.getRender() as GMarkerRender<GMarker, GMarkerTheme>;
  }

  bool hitTest({
    required Offset position,
    double? epsilon,
    bool autoHighlight = true,
  }) {
    if (hitTestMode == GHitTestMode.none) {
      return false;
    }
    final test = getRender().hitTest(position: position, epsilon: epsilon);
    if (autoHighlight) {
      highlight = test;
    }
    return test;
  }
}
