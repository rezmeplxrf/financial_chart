import 'dart:math';
import 'dart:ui';

import 'panel_render.dart';
import 'panel_theme.dart';
import '../component.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import '../tooltip/tooltip.dart';
import '../graph/graph.dart';
import '../axis/axis.dart';
import '../viewport_h.dart';
import '../viewport_v.dart';

/// The action mode when panning the graph area of the panel.
enum GGraphPanMode {
  /// no pan interaction
  none,

  /// pan the graph
  auto,
}

/// Panel of the chart.
///
/// A chart is composed of multiple panels with vertical layout.
/// A panel is a container for [GPointAxis], [GValueAxis], [GGraph], [GPointViewPort], [GValueViewPort] and [GTooltip].
class GPanel extends GComponent {
  /// The only one point viewport of the panel which shared by all the components in the panel.
  /// final GPointViewPort pointViewPort;

  /// The value viewports. axis and graph will refer to a value viewport by its id.
  final List<GValueViewPort> valueViewPorts;

  /// The point axes.
  final List<GPointAxis> pointAxes;

  /// The value axes.
  final List<GValueAxis> valueAxes;

  /// The graphs and their markers.
  final List<GGraph> graphs;

  /// The tooltip of the panel.
  final GTooltip? tooltip;

  /// Whether the panel is resizable.
  ///
  /// A resize handle will be shown at the middle of two panels when both are resizable.
  final GValue<bool> _resizable = GValue(true);
  bool get resizable => _resizable();
  set resizable(bool value) => _resizable(newValue: value);

  /// The height weight of the panel. height will be chart.height * [_heightWeight].
  final GValue<double> _heightWeight = GValue(1.0);
  double get heightWeight => _heightWeight();
  set heightWeight(double value) => _heightWeight(newValue: value);

  /// The speed of the momentum scrolling.
  ///
  /// A value between 0 and 1.0, larger value means faster scrolling, 0 to disable.
  final GValue<double> _momentumScrollSpeed = GValue(0.5);
  double get momentumScrollSpeed => _momentumScrollSpeed();
  set momentumScrollSpeed(double value) =>
      _momentumScrollSpeed(newValue: value);

  /// The action mode when panning the graph area of the panel.
  final GValue<GGraphPanMode> _graphPanMode = GValue(GGraphPanMode.auto);
  GGraphPanMode get graphPanMode => _graphPanMode();
  set graphPanMode(GGraphPanMode value) => _graphPanMode(newValue: value);

  @override
  bool get visible => super.visible && heightWeight > 0;

  /// The areas of children components.
  ///
  /// contains areas: [...pointAxesAreas, ...valueAxesAreas, graphArea, panelArea, splitterArea]
  final List<Rect> _areas = [];

  /// The height of the splitter (resize handle).
  final double splitterHeight;

  /// Whether the layout is ready.
  bool get isLayoutReady => _areas.isNotEmpty;

  /// The render area of the point axis at [index] of [pointAxes].
  Rect pointAxisArea(int index) => _areas[index];

  /// The render area of the value axis at [index] of [valueAxes].
  Rect valueAxisArea(int index) => _areas[pointAxes.length + index];

  /// The render area of graphs.
  Rect graphArea() => _areas[pointAxes.length + valueAxes.length];

  /// The render area of the panel.
  Rect panelArea() => _areas[_areas.length - 2];

  /// The render area of the splitter.
  Rect splitterArea() => _areas.last;

  /// The active graph.
  GGraph get activeGraph => graphs.last;

  GPanel({
    required this.pointAxes,
    required this.valueAxes,
    required this.valueViewPorts,
    required this.graphs,
    this.tooltip,
    double heightWeight = 1.0,
    bool resizable = true,
    GGraphPanMode graphPanMode = GGraphPanMode.auto,
    this.splitterHeight = 12,
    double momentumScrollSpeed = 0.5,
    GPanelTheme? theme,
    GPanelRender? render,
  }) : super(render: render ?? const GPanelRender(), theme: theme) {
    assert(heightWeight >= 0);
    _heightWeight.value = heightWeight;
    _resizable.value = resizable;
    _momentumScrollSpeed.value = min(max(momentumScrollSpeed, 0), 1.0);
    _graphPanMode.value = graphPanMode;
    // at least one value viewport is required
    assert(valueViewPorts.isNotEmpty);
    // no duplicate id for value viewport
    assert(
      valueViewPorts.map((e) => e.id).toSet().length == valueViewPorts.length,
      "Duplicate id for value viewport is not allowed.",
    );
    // only one value viewport with empty id is allowed
  }

  void layout(Rect panelArea) {
    _areas.clear();
    final (axesAreas, graphArea) = GAxis.placeAxes(panelArea, [
      ...pointAxes,
      ...valueAxes,
    ]);
    final splitterArea = Rect.fromCenter(
      center: panelArea.bottomCenter,
      width: panelArea.width,
      height: splitterHeight,
    );
    _areas
      ..addAll(axesAreas)
      ..add(graphArea)
      ..add(panelArea)
      ..add(splitterArea);
  }

  GValueViewPort findValueViewPortById(String id) {
    final found =
        valueViewPorts.where((element) => element.id == id).firstOrNull;
    if (found == null) {
      throw Exception(
        "Value viewport with id $id not found. Available ids: ${valueViewPorts.map((e) => e.id).toList()}",
      );
    }
    return found;
  }

  GViewPortCoord? positionToViewPortCoord({
    required Offset position,
    required GPointViewPort pointViewPort,
    String valueViewPortId = "",
  }) {
    if (!graphArea().contains(position)) {
      return null;
    }
    final valueViewPort =
        valueViewPorts
            .where((element) => element.id == valueViewPortId)
            .firstOrNull;
    if (valueViewPort == null) {
      return null;
    }
    return GViewPortCoord(
      point: pointViewPort.positionToPoint(graphArea(), position.dx),
      value: valueViewPort.positionToValue(graphArea(), position.dy),
    );
  }

  GGraph? findGraphById(String id) {
    return graphs.where((element) => element.id == id).firstOrNull;
  }

  dispose() {
    for (var valueViewPort in valueViewPorts) {
      valueViewPort.dispose();
    }
  }
}
