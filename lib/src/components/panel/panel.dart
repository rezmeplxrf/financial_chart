// ignore_for_file: inference_failure_on_function_return_type

import 'dart:math';
import 'dart:ui';

import 'package:financial_chart/src/components/axis/axis.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/graph/graph.dart';
import 'package:financial_chart/src/components/panel/panel_render.dart';
import 'package:financial_chart/src/components/panel/panel_theme.dart';
import 'package:financial_chart/src/components/tooltip/tooltip.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

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
  GPanel({
    required this.pointAxes,
    required this.valueAxes,
    required this.valueViewPorts,
    required this.graphs,
    super.id,
    this.tooltip,
    double heightWeight = 1.0,
    bool resizable = true,
    GGraphPanMode graphPanMode = GGraphPanMode.auto,
    this.splitterHeight = 16.0,
    double momentumScrollSpeed = 0.5,
    Function(Offset)? onTapGraphArea,
    Function(Offset)? onDoubleTapGraphArea,
    Function(Offset)? onLongPressDownGraphArea,
    Function(Offset)? onLongPressUpGraphArea,
    Function(Offset)? onLongPressMoveGraphArea,
    GPanelTheme? theme,
    GPanelRender? render,
  }) : super(render: render ?? const GPanelRender(), theme: theme) {
    assert(heightWeight >= 0);
    _heightWeight.value = heightWeight;
    _resizable.value = resizable;
    _momentumScrollSpeed.value = min(max(momentumScrollSpeed, 0), 1);
    _graphPanMode.value = graphPanMode;
    _onTapGraphArea.value = onTapGraphArea;
    _onDoubleTapGraphArea.value = onDoubleTapGraphArea;
    _onLongPressStartGraphArea.value = onLongPressDownGraphArea;
    _onLongPressEndGraphArea.value = onLongPressUpGraphArea;
    _onLongPressMoveGraphArea.value = onLongPressMoveGraphArea;
    // at least one value viewport is required
    assert(valueViewPorts.isNotEmpty);
    // no duplicate id for value viewport
    assert(
      valueViewPorts.map((e) => e.id).toSet().length == valueViewPorts.length,
      'Duplicate id for value viewport is not allowed.',
    );
    // only one value viewport with empty id is allowed
  }

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
  bool get resizable => _resizable.value && visible;
  set resizable(bool value) => _resizable.value = value;

  /// The height weight of the panel. height will be chart.height * [_heightWeight].
  final GValue<double> _heightWeight = GValue(1);
  double get heightWeight => _heightWeight.value;
  set heightWeight(double value) => _heightWeight.value = value;

  /// The speed of the momentum scrolling.
  ///
  /// A value between 0 and 1.0, larger value means faster scrolling, 0 to disable.
  final GValue<double> _momentumScrollSpeed = GValue(0.5);
  double get momentumScrollSpeed => _momentumScrollSpeed.value;
  set momentumScrollSpeed(double value) =>
      _momentumScrollSpeed.value = min(max(value, 0), 1);

  /// The action mode when panning the graph area of the panel.
  final GValue<GGraphPanMode> _graphPanMode = GValue(GGraphPanMode.auto);
  GGraphPanMode get graphPanMode => _graphPanMode.value;
  set graphPanMode(GGraphPanMode value) => _graphPanMode.value = value;

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
  Rect pointAxisAreaOf(GPointAxis axis) => _areas[pointAxes.indexOf(axis)];

  /// The render area of the value axis at [index] of [valueAxes].
  Rect valueAxisArea(int index) => _areas[pointAxes.length + index];
  Rect valueAxisAreaOf(GValueAxis axis) =>
      _areas[pointAxes.length + valueAxes.indexOf(axis)];

  /// The render area of graphs.
  Rect graphArea() => _areas[pointAxes.length + valueAxes.length];

  /// The render area of the panel.
  Rect panelArea() => _areas[_areas.length - 2];

  /// The render area of the splitter.
  Rect splitterArea() => _areas.last;

  /// The active graph.
  GGraph get activeGraph => graphs.last;

  /// The callback function when tap (up) the graph area.
  ///
  /// NOTICE that when [onDoubleTapGraphArea] also being set there is a delay cause by distinguishing single from double taps
  final GValue<Function(Offset)?> _onTapGraphArea = GValue(null);
  Function(Offset)? get onTapGraphArea => _onTapGraphArea.value;
  set onTapGraphArea(Function(Offset)? value) => _onTapGraphArea.value = value;

  /// The callback function when double tap (down) the graph area.
  ///
  /// NOTICE that when this being set it will cause a delay on [onTapGraphArea] for distinguishing single from double taps
  final GValue<Function(Offset)?> _onDoubleTapGraphArea = GValue(null);
  Function(Offset)? get onDoubleTapGraphArea => _onDoubleTapGraphArea.value;
  set onDoubleTapGraphArea(Function(Offset)? value) =>
      _onDoubleTapGraphArea.value = value;

  /// The callback function when long press down the graph area.
  final GValue<Function(Offset)?> _onLongPressStartGraphArea = GValue(null);
  Function(Offset)? get onLongPressStartGraphArea =>
      _onLongPressStartGraphArea.value;
  set onLongPressStartGraphArea(Function(Offset)? value) =>
      _onLongPressStartGraphArea.value = value;

  /// The callback function when long press up the graph area.
  final GValue<Function(Offset)?> _onLongPressEndGraphArea = GValue(null);
  Function(Offset)? get onLongPressEndGraphArea =>
      _onLongPressEndGraphArea.value;
  set onLongPressEndGraphArea(Function(Offset)? value) =>
      _onLongPressEndGraphArea.value = value;

  /// The callback function when long press move the graph area.
  final GValue<Function(Offset)?> _onLongPressMoveGraphArea = GValue(null);
  Function(Offset)? get onLongPressMoveGraphArea =>
      _onLongPressMoveGraphArea.value;
  set onLongPressMoveGraphArea(Function(Offset)? value) =>
      _onLongPressMoveGraphArea.value = value;

  void layout(Rect panelArea, {required bool hasSplitter}) {
    _areas.clear();
    final (axesAreas, graphArea) = GAxis.placeAxes(panelArea, [
      ...pointAxes,
      ...valueAxes,
    ]);
    final splitterArea =
        hasSplitter
            ? Rect.fromCenter(
              center: panelArea.bottomCenter,
              width: panelArea.width,
              height: splitterHeight,
            )
            : Rect.zero;
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
        'Value viewport with id $id not found. Available ids: ${valueViewPorts.map((e) => e.id).toList()}',
      );
    }
    return found;
  }

  GViewPortCoord? positionToViewPortCoord({
    required Offset position,
    required GPointViewPort pointViewPort,
    String valueViewPortId = '',
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

  void dispose() {
    for (final valueViewPort in valueViewPorts) {
      valueViewPort.dispose();
    }
    tooltip?.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<List<GValueViewPort>>(
          'valueViewPorts',
          valueViewPorts,
        ),
      )
      ..add(
        DiagnosticsProperty<List<GPointAxis>>('pointAxes', pointAxes),
      )
      ..add(
        DiagnosticsProperty<List<GValueAxis>>('valueAxes', valueAxes),
      )
      ..add(DiagnosticsProperty<List<GGraph>>('graphs', graphs))
      ..add(DiagnosticsProperty<GTooltip>('tooltip', tooltip))
      ..add(DiagnosticsProperty<bool>('resizable', resizable))
      ..add(DoubleProperty('heightWeight', heightWeight))
      ..add(DoubleProperty('momentumScrollSpeed', momentumScrollSpeed))
      ..add(EnumProperty<GGraphPanMode>('graphPanMode', graphPanMode))
      ..add(
        DiagnosticsProperty<bool>('onTapGraphArea', onTapGraphArea != null),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'onDoubleTapGraphArea',
          onDoubleTapGraphArea != null,
        ),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'onLongPressDownGraphArea',
          onLongPressStartGraphArea != null,
        ),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'onLongPressUpGraphArea',
          onLongPressEndGraphArea != null,
        ),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'onLongPressMoveGraphArea',
          onLongPressMoveGraphArea != null,
        ),
      )
      ..add(
        DiagnosticsProperty<double>('splitterHeight', splitterHeight),
      )
      ..add(DiagnosticsProperty<bool>('isLayoutReady', isLayoutReady));
    if (isLayoutReady) {
      properties
        ..add(DiagnosticsProperty<Rect>('graphArea', graphArea()))
        ..add(DiagnosticsProperty<Rect>('panelArea', panelArea()))
        ..add(DiagnosticsProperty<Rect>('splitterArea', splitterArea()))
        ..add(
          IterableProperty<Rect>(
            'pointAxisAreas',
            pointAxes.map(pointAxisAreaOf).toList(),
          ),
        )
        ..add(
          IterableProperty<Rect>(
            'valueAxisAreas',
            valueAxes.map(valueAxisAreaOf).toList(),
          ),
        );
    }
  }
}
