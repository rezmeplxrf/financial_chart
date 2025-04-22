import 'dart:ui';
import '../component.dart';
import 'marker_render.dart';
import 'marker_theme.dart';

/// Base class for markers.
class GMarker extends GComponent {
  static const int kDefaultLayer = 1000;

  GMarker({
    super.id,
    super.visible = true,
    super.theme,
    super.render,
    super.layer,
    super.hitTestMode,
  });

  @override
  GMarkerRender<GMarker, GMarkerTheme> getRender() {
    return super.getRender() as GMarkerRender<GMarker, GMarkerTheme>;
  }

  bool hitTest({
    required Offset position,
    double? epsilon,
    autoHighlight = true,
  }) {
    if (hitTestMode == GHitTestMode.none) {
      return false;
    }
    bool test = getRender().hitTest(position: position, epsilon: epsilon);
    if (autoHighlight) {
      highlight = test;
    }
    return test;
  }
}
