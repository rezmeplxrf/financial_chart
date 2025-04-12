import 'dart:ui';
import '../../values/value.dart';
import '../component.dart';
import 'marker_render.dart';
import 'marker_theme.dart';

/// Base class for markers.
class GMarker extends GComponent {
  static const int kDefaultLayer = 1000;

  /// The layer of the marker. highest layer will be on the top.
  final GValue<int> _layer;
  int get layer => _layer.value;
  set layer(int value) => _layer.value = value;

  /// [HitTestMode] of the marker.
  final GValue<HitTestMode> _hitTestMode;
  HitTestMode get hitTestMode => _hitTestMode.value;
  set hitTestMode(HitTestMode value) => _hitTestMode.value = value;

  /// Whether the marker is highlighted (or selected).
  final GValue<bool> _highlight = GValue<bool>(false);
  bool get highlight => _highlight.value;
  set highlight(bool value) => _highlight.value = value;

  GMarker({
    super.id,
    super.visible = true,
    super.theme,
    super.render,
    int layer = kDefaultLayer,
    HitTestMode hitTestMode = HitTestMode.border,
  }) : _layer = GValue<int>(layer),
       _hitTestMode = GValue<HitTestMode>(hitTestMode);

  @override
  GMarkerRender<GMarker, GMarkerTheme> getRender() {
    return super.getRender() as GMarkerRender<GMarker, GMarkerTheme>;
  }

  bool hitTest({
    required Offset position,
    double? epsilon,
    autoHighlight = true,
  }) {
    if (hitTestMode == HitTestMode.none) {
      return false;
    }
    bool test = getRender().hitTest(position: position, epsilon: epsilon);
    if (autoHighlight) {
      highlight = test;
    }
    return test;
  }
}
