import 'dart:ui';

import '../../values/coord.dart';
import '../../values/range.dart';
import '../../values/value.dart';
import '../component.dart';
import '../component_theme.dart';
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

/// Markers on the axis.
class GAxisMarker extends GMarker {
  /// render a label for each of the [values] on value axis.
  final List<double> values;

  /// render a label for each of the [points] on point axis.
  final List<int> points;

  /// render a range for each of the [valueRanges] on value axis.
  final List<GRange> valueRanges;

  /// render a range for each of the [pointRanges] on point axis.
  final List<GRange> pointRanges;

  GAxisMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    super.render = const GAxisMarkerRender(),
    this.values = const [],
    this.points = const [],
    this.valueRanges = const [],
    this.pointRanges = const [],
  });
}

/// Base class for Marker on the graph.
abstract class GGraphMarker extends GMarker {
  /// Key points decides the shape of the marker.
  final List<GCoordinate> keyCoordinates;

  /// Control points allow to adjust the shape of the marker interactively.
  List<GCoordinate> controlCoordinates = [];

  @override
  GGraphMarkerTheme? get theme => super.theme as GGraphMarkerTheme?;

  @override
  set theme(GComponentTheme? value) {
    if (value != null && value is! GGraphMarkerTheme) {
      throw ArgumentError('theme must be a GGraphMarkerTheme');
    }
    super.theme = value;
  }

  GGraphMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    GGraphMarkerTheme? theme,
    GGraphMarkerRender? render,
    this.keyCoordinates = const [],
  }) : super(theme: theme, render: render);

  @override
  GGraphMarkerRender<GGraphMarker, GGraphMarkerTheme> getRender() {
    return super.getRender()
        as GGraphMarkerRender<GGraphMarker, GGraphMarkerTheme>;
  }
}
