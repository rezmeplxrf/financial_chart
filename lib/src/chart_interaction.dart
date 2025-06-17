import 'dart:math';

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/values/range.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

part 'chart_interaction_gesture_factory.dart';
part 'chart_interaction_gesture_recognizers.dart';
part 'chart_interaction_viewports.dart';

/// [GChartInteractionHandler] for handling user interactions for the attached chart.
// ignore: must_be_immutable
class GChartInteractionHandler with Diagnosticable {
  GChartInteractionHandler();
  late final GChart _chart;

  final GValue<bool> _isTouchEvent = GValue(false);
  final GValue<bool> _isTouchCrossMode = GValue(false);

  GPointViewPortInteractionHelper pointViewPortInteractionHelper =
      GPointViewPortInteractionHelper();
  GValueViewPortInteractionHelper valueViewPortInteractionHelper =
      GValueViewPortInteractionHelper();
  bool get isScalingViewPort =>
      pointViewPortInteractionHelper.isScaling ||
      valueViewPortInteractionHelper.isScaling;

  void Function({
    required Offset position,
    required double scale,
    required double verticalScale,
  })?
  _hookScaleUpdate;
  void Function(int pointerCount, double scaleVelocity, Velocity? velocity)?
  _hookScaleEnd;

  // ignore: use_setters_to_change_properties
  void attach(GChart chart) {
    _chart = chart;
  }

  void mouseEnter({required Offset position}) {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.mouseEnter,
    );
    _notify();
  }

  void mouseExit() {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      trigger: GCrosshairTrigger.mouseExit,
    );
    _notify();
  }

  MouseCursor _mouseCursor({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return _chart.dataSource.isLoading
          ? SystemMouseCursors.wait
          : SystemMouseCursors.basic;
    }
    for (var p = 0; p < _chart.panels.length; p++) {
      final panel = _chart.panels[p];
      // test if hit resize splitter
      if (panel.resizable &&
          p < _chart.panels.length - 1 &&
          _chart.panels[p + 1].resizable &&
          panel.splitterArea().contains(position)) {
        return SystemMouseCursors.resizeUpDown;
      }
      // test if hit axes (in case the axes may be inside graph area we test before testing graph)
      for (var n = 0; n < panel.valueAxes.length; n++) {
        final axisArea = panel.valueAxisArea(n);
        if (axisArea.contains(position)) {
          if (panel.valueAxes[n].scaleMode == GAxisScaleMode.move) {
            return SystemMouseCursors.grab;
          } else if (panel.valueAxes[n].scaleMode == GAxisScaleMode.zoom) {
            return SystemMouseCursors.resizeUpDown;
          } else if (panel.valueAxes[n].scaleMode == GAxisScaleMode.select) {
            return SystemMouseCursors.resizeUpDown;
          }
          return SystemMouseCursors.basic;
        }
      }
      for (var n = 0; n < panel.pointAxes.length; n++) {
        final axisArea = panel.pointAxisArea(n);
        if (axisArea.contains(position)) {
          if (panel.pointAxes[n].scaleMode == GAxisScaleMode.move) {
            return SystemMouseCursors.grab;
          } else if (panel.pointAxes[n].scaleMode == GAxisScaleMode.zoom) {
            return SystemMouseCursors.resizeLeftRight;
          } else if (panel.pointAxes[n].scaleMode == GAxisScaleMode.select) {
            return SystemMouseCursors.resizeLeftRight;
          }
          return SystemMouseCursors.basic;
        }
      }
      // test if hit graph
      if (panel.graphArea().contains(position)) {
        return SystemMouseCursors.precise;
      }
    }
    return SystemMouseCursors.basic;
  }

  void mouseHover({required Offset position}) {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.mouseHover,
    );
    _chart.mouseCursor.value = _mouseCursor(position: position);
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (var p = 0; p < _chart.panels.length; p++) {
      final panel = _chart.panels[p];
      for (var g = 0; g < panel.graphs.length; g++) {
        panel.graphs[g].highlight = false;
      }
    }
    if (!(pointViewPortInteractionHelper.isScaling ||
        _chart.pointViewPort.isAnimating)) {
      final hit = _chart.hitTestGraph(position: position);
      if (hit != null) {
        hit.$2.highlight = true;
      }
    }
    _notify();
  }

  void pointerScroll({required Offset position, required Offset scrollDelta}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_chart.pointerScrollMode == GPointerScrollMode.none) {
      return;
    }
    for (var n = 0; n < _chart.panels.length; n++) {
      final area = _chart.panels[n].graphArea();
      if (area.contains(position)) {
        final pointViewPort = _chart.pointViewPort..stopAnimation();
        if (_chart.pointerScrollMode == GPointerScrollMode.move) {
          final pointSize = pointViewPort.pointSize(area.width);
          final distance = scrollDelta.dy / pointSize;
          final newRange = GRange.range(
            pointViewPort.startPoint - distance,
            pointViewPort.endPoint - distance,
          );
          pointViewPort
            ..autoScaleFlg = false
            ..setRange(
              startPoint: newRange.begin!,
              endPoint: newRange.end!,
              finished: true,
            );
        } else if (_chart.pointerScrollMode == GPointerScrollMode.zoom) {
          final centerPoint = pointViewPort.positionToPoint(area, position.dx);
          final scaleRatio = 1 - scrollDelta.dy / area.height;
          pointViewPort
            ..autoScaleFlg = false
            ..zoom(area, scaleRatio, centerPoint: centerPoint);
        }
        _notify();
        break;
      }
    }
  }

  void scaleStart({required Offset start, required int pointerCount}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: start.dx,
      y: start.dy,
      trigger: GCrosshairTrigger.scaleStart,
    );
    // hit test splitters
    for (var n = 0; n < _chart.panels.length; n++) {
      final panel = _chart.panels[n];
      final nextPanel = _chart.nextVisiblePanel(startIndex: n + 1);
      if (nextPanel != null && panel.splitterArea().contains(start)) {
        final splitterPanel = _tryScalingSplitter(n, panel, nextPanel, start);
        if (splitterPanel != null) {
          _notify();
          return;
        }
      }
    }
    for (var n = 0; n < _chart.panels.length; n++) {
      final panel = _chart.panels[n];
      if (panel.panelArea().contains(start)) {
        // hit test hAxis
        final pointAxis = _tryScalingPointAxis(panel, start);
        if (pointAxis != null) {
          _notify();
          return;
        }
        // hit test vAxis
        final valueAxis = _tryScalingValueAxis(panel, start);
        if (valueAxis != null) {
          _notify();
          return;
        }
      }
    }
    for (var n = 0; n < _chart.panels.length; n++) {
      final panel = _chart.panels[n];
      // hit test graph
      if (panel.graphArea().contains(start)) {
        final graph = _tryScalingGraph(panel, start, pointerCount);
        if (graph != null) {
          _notify();
          return;
        }
      }
    }
  }

  void scaleUpdate({
    required Offset position,
    required double scale,
    required double verticalScale,
  }) {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.scaleUpdate,
    );

    _hookScaleUpdate?.call(
      position: position,
      scale: scale,
      verticalScale: verticalScale,
    );

    _notify();
  }

  void scaleEnd(int pointerCount, double scaleVelocity, Velocity velocity) {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      trigger: GCrosshairTrigger.scaleEnd,
    );
    if (_hookScaleEnd != null) {
      _hookScaleEnd!(pointerCount, scaleVelocity, velocity);
      _hookScaleUpdate = null;
      _hookScaleEnd = null;
    }
    _notify();
  }

  void longPressStart({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_isTouchEvent.value) {
      _isTouchCrossMode.value = true;
    }
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.longPressStart,
    );
    _notify();
  }

  void longPressMove({required Offset position}) {
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.longPressMove,
    );
    _notify();
  }

  void longPressEnd({required Offset position}) {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
    }
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.longPressEnd,
    );
    _notify();
  }

  void tapDown({required Offset position, required bool isTouch}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      x: position.dx,
      y: position.dy,
      trigger: GCrosshairTrigger.tapDown,
    );
    for (final panel in _chart.panels) {
      if (panel.panelArea().contains(position) &&
          (!panel.resizable || !panel.splitterArea().contains(position))) {
        _isTouchEvent.value = isTouch;
        _notify();
        return;
      }
    }
  }

  void tapUp() {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
    }
    _chart.crosshair.updateCrossPosition(
      chart: _chart,
      trigger: GCrosshairTrigger.tapUp,
    );
    _notify();
  }

  void doubleTap({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (var p = 0; p < _chart.panels.length; p++) {
      final panel = _chart.panels[p];
      if (panel.panelArea().contains(position)) {
        for (var a = 0; a < panel.valueAxes.length; a++) {
          final axis = panel.valueAxes[a];
          final axisArea = panel.valueAxisArea(a);
          if (axisArea.contains(position)) {
            panel
                .findValueViewPortById(
                  axis.viewPortId,
                )
                .autoScaleReset(
                  chart: _chart,
                  panel: panel,
                );
            break;
          }
        }
        for (var a = 0; a < panel.pointAxes.length; a++) {
          final axisArea = panel.pointAxisArea(a);
          if (axisArea.contains(position)) {
            _chart.pointViewPort.autoScaleReset(
              chart: _chart,
              panel: panel,
              finished: true,
            );
            break;
          }
        }
        break;
      }
    }
    _notify();
  }

  GPanel? _tryScalingSplitter(
    int panel1Index,
    GPanel panel1,
    GPanel panel2,
    Offset start,
  ) {
    if (!panel1.resizable || !panel2.resizable) {
      return null;
    }
    if (panel1.splitterArea().contains(start)) {
      final h1 = panel1.panelArea().height;
      final h2 = panel2.panelArea().height;
      final moveToleranceMin = -panel1.graphArea().height + 50;
      final moveToleranceMax = panel2.graphArea().height - 50;
      final weightDensity =
          (panel1.heightWeight + panel2.heightWeight) / (h1 + h2);
      _chart.splitter.resizingPanelIndex = panel1Index;
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        final double moveDistance = min(
          max(position.dy - start.dy, moveToleranceMin),
          moveToleranceMax,
        );
        final h1New = h1 + moveDistance;
        final h2New = h2 - moveDistance;
        panel1.heightWeight = h1New * weightDensity;
        panel2.heightWeight = h2New * weightDensity;
        _chart.resize(newArea: _chart.area, force: true);
      };
      _hookScaleEnd = (
        int pointerCount,
        double scaleVelocity,
        Velocity? velocity,
      ) {
        _chart.splitter.resizingPanelIndex = null;
      };
      return panel1;
    }
    return null;
  }

  GPointAxis? _tryScalingPointAxis(GPanel panel, Offset start) {
    for (var a = 0; a < panel.pointAxes.length; a++) {
      final axis = panel.pointAxes[a];
      final axisArea = panel.pointAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          final pointViewPort = _chart.pointViewPort;
          pointViewPortInteractionHelper.interactionStart(pointViewPort);
          pointViewPort.autoScaleFlg = false;
          var lastX = start.dx;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            if (axis.scaleMode == GAxisScaleMode.zoom ||
                (scale > 0 && scale != 1.0)) {
              final scaleRatio =
                  (axisArea.right - position.dx) / (axisArea.right - start.dx);
              if (scale > 0 && scale != 1.0) {
                pointViewPortInteractionHelper.interactionZoomUpdate(
                  axisArea,
                  start,
                  position,
                  scale,
                );
              } else {
                pointViewPortInteractionHelper.interactionZoomUpdate(
                  axisArea,
                  start,
                  null,
                  scaleRatio,
                );
              }
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              final moveDistance = position.dx - start.dx;
              pointViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dx,
                position.dx,
              );
            }
            lastX = position.dx;
          };
          _hookScaleEnd = (
            int pointerCount,
            double scaleVelocity,
            Velocity? velocity,
          ) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dx,
                lastX,
                finished: true,
              );
            }
            pointViewPortInteractionHelper.interactionEnd();
          };
          return axis;
        }
      }
    }
    return null;
  }

  GValueAxis? _tryScalingValueAxis(GPanel panel, Offset start) {
    // test if hit vAxis
    for (var a = 0; a < panel.valueAxes.length; a++) {
      final axis = panel.valueAxes[a];
      final axisArea = panel.valueAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          final viewPort = panel.findValueViewPortById(
            axis.viewPortId,
          )..autoScaleFlg = false;
          valueViewPortInteractionHelper.interactionStart(viewPort);
          var lastY = start.dy;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            if (axis.scaleMode == GAxisScaleMode.zoom) {
              final double scaleRatio = min(
                max(
                  (axisArea.bottom - start.dy) /
                      (axisArea.bottom - min(position.dy, axisArea.bottom - 1)),
                  0.01,
                ),
                100,
              );
              valueViewPortInteractionHelper.interactionZoomUpdate(
                axisArea,
                scaleRatio,
              );
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              final moveDistance = position.dy - start.dy;
              valueViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              valueViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dy,
                position.dy,
              );
            }
            lastY = position.dy;
          };
          _hookScaleEnd = (
            int pointerCount,
            double scaleVelocity,
            Velocity? velocity,
          ) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              valueViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dy,
                lastY,
                finished: true,
              );
            }
            valueViewPortInteractionHelper.interactionEnd();
          };
          return axis;
        }
      }
    }
    return null;
  }

  GGraph? _tryScalingGraph(GPanel panel, Offset start, int pointerCount) {
    final graphArea = panel.graphArea();
    if (!graphArea.contains(start)) {
      return null;
    }
    final graph =
        _chart.hitTestPanelGraphs(panel: panel, position: start) ??
        panel.graphs.last;
    if (_isTouchCrossMode.value || panel.graphPanMode == GGraphPanMode.none) {
      // move crosshair only
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        _chart.mouseCursor.value = SystemMouseCursors.precise;
      };
      _hookScaleEnd =
          (int pointerCount, double scaleVelocity, Velocity? velocity) {};
      return graph;
    }
    final pointViewPort = _chart.pointViewPort;
    final valueViewPort = panel.findValueViewPortById(
      graph.valueViewPortId,
    );
    pointViewPortInteractionHelper.interactionStart(pointViewPort);
    pointViewPort
      ..stopAnimation()
      ..autoScaleFlg = false;
    final scaleValue = !valueViewPort.autoScaleFlg;
    if (scaleValue) {
      valueViewPortInteractionHelper.interactionStart(valueViewPort);
    }
    _hookScaleUpdate = ({
      required Offset position,
      required double scale,
      required double verticalScale,
    }) {
      _chart.mouseCursor.value = SystemMouseCursors.grab;
      final moveDistanceX = position.dx - start.dx;
      if (scale != 1.0) {
        if (scale != 1.0 && scale > 0) {
          //pointViewPort.interactionMoveUpdate(graphArea, moveDistanceX);
          pointViewPortInteractionHelper.interactionZoomUpdate(
            graphArea,
            start,
            position,
            scale,
          );
        }
        if (verticalScale != 1.0 && verticalScale > 0 && scaleValue) {
          //valueViewPort.interactionZoomUpdate(graphArea, verticalScale);
        }
        return;
      }
      pointViewPortInteractionHelper.interactionMoveUpdate(
        graphArea,
        moveDistanceX,
      );
      if (scaleValue) {
        final moveDistanceY = position.dy - start.dy;
        valueViewPortInteractionHelper.interactionMoveUpdate(
          graphArea,
          moveDistanceY,
        );
      }
    };
    _hookScaleEnd = (
      int pointerCount,
      double scaleVelocity,
      Velocity? velocity,
    ) {
      _hookScaleEnd = null;
      _chart.mouseCursor.value = SystemMouseCursors.precise;
      final momentum =
          velocity != null &&
          panel.momentumScrollSpeed > 0 &&
          velocity.pixelsPerSecond.dx.abs() > 1;
      pointViewPortInteractionHelper.interactionEnd(notify: !momentum);
      if (scaleValue) {
        valueViewPortInteractionHelper.interactionEnd();
      }
      if (momentum) {
        // momentum scrolling
        final pointSize = pointViewPort.pointSize(graphArea.width);
        final distance =
            velocity.pixelsPerSecond.dx / pointSize * panel.momentumScrollSpeed;
        var newRange = GRange.range(
          pointViewPort.startPoint - distance,
          pointViewPort.endPoint - distance,
        );
        // make sure do not scroll too far that it goes out of current data point range
        final startMin =
            _chart.dataSource.firstPoint - pointViewPort.pointRangeSize;
        final endMax =
            _chart.dataSource.lastPoint + pointViewPort.pointRangeSize;
        newRange = pointViewPort.clampRange(
          newRange.first!,
          newRange.last!,
          startMin: startMin,
          endMax: endMax,
        );
        final simulation = FrictionSimulation.through(0, 1, 1, 0.9);
        pointViewPort.animateToRange(
          newRange,
          true,
          true,
          simulation: simulation,
        );
      }
    };
    return graph;
  }

  void _notify() {
    _chart.repaint(layout: false);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<bool>('isTouchEvent', _isTouchEvent.value),
      )
      ..add(
        DiagnosticsProperty<bool>('isTouchCrossMode', _isTouchCrossMode.value),
      );
  }
}
