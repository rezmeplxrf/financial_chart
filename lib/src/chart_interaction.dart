import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'chart.dart';
import 'components/graph/graph.dart';
import 'components/panel/panel.dart';
import 'components/viewport_v.dart';
import 'components/axis/axis.dart';
import 'components/viewport_h.dart';
import 'values/range.dart';
import 'values/value.dart';

part 'chart_interaction_gesture_recognizers.dart';
part 'chart_interaction_gesture_factory.dart';

/// [GChartInteractionHandler] for handling user interactions for the attached chart.
// ignore: must_be_immutable
class GChartInteractionHandler {
  late final GChart _chart;

  final GValue<bool> _isTouchEvent = GValue(false);
  final GValue<bool> _isTouchCrossMode = GValue(false);

  GPointViewPortInteractionHelper pointViewPortInteractionHelper =
      GPointViewPortInteractionHelper();
  GValueViewPortInteractionHelper valueViewPortInteractionHelper =
      GValueViewPortInteractionHelper();
  bool get isScaling =>
      pointViewPortInteractionHelper.isScaling ||
      valueViewPortInteractionHelper.isScaling;

  GChartInteractionHandler();

  void Function({
    required Offset position,
    required double scale,
    required double verticalScale,
  })?
  _hookScaleUpdate;
  void Function(Velocity? velocity)? _hookScaleEnd;

  void attach(GChart chart) {
    _chart = chart;
  }

  void mouseEnter({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _notify();
  }

  void mouseExit() {
    _chart.crosshair.clearCrossPosition();
    _notify();
  }

  MouseCursor _mouseCursor({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return _chart.dataSource.isLoading
          ? SystemMouseCursors.wait
          : SystemMouseCursors.basic;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      // test if hit resize splitter
      if (panel.resizable &&
          p < _chart.panels.length - 1 &&
          _chart.panels[p + 1].resizable &&
          panel.splitterArea().contains(position)) {
        return SystemMouseCursors.resizeUpDown;
      }
      // test if hit axes (in case the axes may be inside graph area we test before testing graph)
      for (int n = 0; n < panel.valueAxes.length; n++) {
        Rect axisArea = panel.valueAxisArea(n);
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
      for (int n = 0; n < panel.pointAxes.length; n++) {
        Rect axisArea = panel.pointAxisArea(n);
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
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _chart.mouseCursor.value = _mouseCursor(position: position);
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      for (int g = 0; g < panel.graphs.length; g++) {
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
    for (int n = 0; n < _chart.panels.length; n++) {
      Rect area = _chart.panels[n].graphArea();
      if (area.contains(position)) {
        final pointViewPort = _chart.pointViewPort;
        pointViewPort.stopAnimation();
        if (_chart.pointerScrollMode == GPointerScrollMode.move) {
          final pointSize = pointViewPort.pointSize(area.width);
          final distance = scrollDelta.dy / pointSize;
          final newRange = GRange.range(
            pointViewPort.startPoint - distance,
            pointViewPort.endPoint - distance,
          );
          pointViewPort.autoScaleFlg = false;
          pointViewPort.animateToRange(newRange, true, false);
        } else if (_chart.pointerScrollMode == GPointerScrollMode.zoom) {
          final centerPoint =
              pointViewPort.positionToPoint(area, position.dx).toDouble();
          final scaleRatio = 1 + scrollDelta.dy / area.height;
          pointViewPort.autoScaleFlg = false;
          pointViewPort.zoom(area, scaleRatio, centerPoint: centerPoint);
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
    // hit test splitters
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      if (n < _chart.panels.length - 1 &&
          panel.splitterArea().contains(start)) {
        GPanel? splitterPanel = _tryScalingSplitter(
          n,
          _chart.panels[n],
          _chart.panels[n + 1],
          start,
        );
        if (splitterPanel != null) {
          _notify();
          return;
        }
      }
    }
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      if (panel.panelArea().contains(start)) {
        // hit test hAxis
        GPointAxis? pointAxis = _tryScalingPointAxis(panel, start);
        if (pointAxis != null) {
          break;
        }
        // hit test vAxis
        GValueAxis? valueAxis = _tryScalingValueAxis(panel, start);
        if (valueAxis != null) {
          break;
        }
        // hit test graph
        if (panel.graphArea().contains(start)) {
          _tryScalingGraph(panel, start, pointerCount);
        }
        break;
      }
    }
    _notify();
  }

  void scaleUpdate({
    required Offset position,
    required double scale,
    required double verticalScale,
  }) {
    if (_hookScaleUpdate != null) {
      _hookScaleUpdate!(
        position: position,
        scale: scale,
        verticalScale: verticalScale,
      );
    } else {
      _chart.crosshair.setCrossPosition(position.dx, position.dy);
    }
    _notify();
  }

  void scaleEnd(Velocity velocity) {
    if (_hookScaleEnd != null) {
      _hookScaleEnd!(velocity);
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
      _chart.crosshair.setCrossPosition(position.dx, position.dy);
      _notify();
    }
  }

  void longPressMove({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _notify();
  }

  void longPressEnd({required Offset position}) {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
      _chart.crosshair.clearCrossPosition();
      _notify();
    }
  }

  void tapDown({required Offset position, required bool isTouch}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (final panel in _chart.panels) {
      if (panel.panelArea().contains(position) &&
          (!panel.resizable || !panel.splitterArea().contains(position))) {
        _chart.crosshair.setCrossPosition(position.dx, position.dy);
        _isTouchEvent.value = isTouch;
        _notify();
        return;
      }
    }
  }

  void tapUp() {
    _clearTouchCross();
  }

  void _clearTouchCross() {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
      _chart.crosshair.clearCrossPosition();
      _notify();
    }
  }

  void doubleTap({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      if (panel.panelArea().contains(position)) {
        for (int a = 0; a < panel.valueAxes.length; a++) {
          GValueAxis axis = panel.valueAxes[a];
          Rect axisArea = panel.valueAxisArea(a);
          if (axisArea.contains(position)) {
            GValueViewPort? valueViewPort = panel.findValueViewPortById(
              axis.viewPortId,
            );
            valueViewPort.autoScaleReset(
              chart: _chart,
              panel: panel,
              autoScaleFlg: true,
            );
            break;
          }
        }
        for (int a = 0; a < panel.pointAxes.length; a++) {
          Rect axisArea = panel.pointAxisArea(a);
          if (axisArea.contains(position)) {
            _chart.pointViewPort.autoScaleReset(
              chart: _chart,
              panel: panel,
              finished: true,
              animation: true,
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
      double h1 = panel1.panelArea().height;
      double h2 = panel2.panelArea().height;
      double moveToleranceMin = -panel1.graphArea().height + 50;
      double moveToleranceMax = panel2.graphArea().height - 50;
      double weightUnit = panel1.heightWeight / (h1 / _chart.size.height);
      _chart.splitter.resizingPanelIndex = panel1Index;
      _chart.crosshair.crossPosition.clear();
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        double moveDistance = min(
          max((position.dy - start.dy), moveToleranceMin),
          moveToleranceMax,
        );
        double h1New = h1 + moveDistance;
        double h2New = h2 - moveDistance;
        panel1.heightWeight = h1New * weightUnit;
        panel2.heightWeight = h2New * weightUnit;
        _chart.layout(_chart.area);
      };
      _hookScaleEnd = (Velocity? velocity) {
        _chart.splitter.resizingPanelIndex = null;
      };
      return panel1;
    }
    return null;
  }

  GPointAxis? _tryScalingPointAxis(GPanel panel, Offset start) {
    for (int a = 0; a < panel.pointAxes.length; a++) {
      GPointAxis axis = panel.pointAxes[a];
      Rect axisArea = panel.pointAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          GPointViewPort pointViewPort = _chart.pointViewPort;
          pointViewPortInteractionHelper.interactionStart(pointViewPort);
          pointViewPort.autoScaleFlg = false;
          double lastX = start.dx;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            _chart.crosshair.setCrossPosition(position.dx, position.dy);
            if (axis.scaleMode == GAxisScaleMode.zoom) {
              double scaleRatio =
                  (axisArea.right - position.dx) / (axisArea.right - start.dx);
              pointViewPortInteractionHelper.interactionZoomUpdate(
                axisArea,
                scaleRatio,
              );
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              double moveDistance = (position.dx - start.dx);
              pointViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dx,
                position.dx,
                finished: false,
              );
            }
            lastX = position.dx;
          };
          _hookScaleEnd = (Velocity? velocity) {
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
        }
        return axis;
      }
    }
    return null;
  }

  GValueAxis? _tryScalingValueAxis(GPanel panel, Offset start) {
    // test if hit vAxis
    for (int a = 0; a < panel.valueAxes.length; a++) {
      GValueAxis axis = panel.valueAxes[a];
      Rect axisArea = panel.valueAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          GValueViewPort? viewPort = panel.findValueViewPortById(
            axis.viewPortId,
          );
          viewPort.autoScaleFlg = false;
          valueViewPortInteractionHelper.interactionStart(viewPort);
          double lastY = start.dy;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            _chart.crosshair.setCrossPosition(position.dx, position.dy);
            if (axis.scaleMode == GAxisScaleMode.zoom) {
              double scaleRatio = min(
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
              double moveDistance = (position.dy - start.dy);
              valueViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              valueViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dy,
                position.dy,
                finished: false,
              );
            }
            lastY = position.dy;
          };
          _hookScaleEnd = (Velocity? velocity) {
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
    Rect graphArea = panel.graphArea();
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
        _chart.crosshair.setCrossPosition(position.dx, position.dy);
      };
      _hookScaleEnd = (Velocity? velocity) {};
      return graph;
    }
    GPointViewPort pointViewPort = _chart.pointViewPort;
    GValueViewPort? valueViewPort = panel.findValueViewPortById(
      graph.valueViewPortId,
    );
    pointViewPortInteractionHelper.interactionStart(pointViewPort);
    pointViewPort.stopAnimation();
    pointViewPort.autoScaleFlg = false;
    bool scaleValue = !valueViewPort.autoScaleFlg;
    if (scaleValue) {
      valueViewPortInteractionHelper.interactionStart(valueViewPort);
    }
    _hookScaleUpdate = ({
      required Offset position,
      required double scale,
      required double verticalScale,
    }) {
      _chart.crosshair.clearCrossPosition();
      _chart.mouseCursor.value = SystemMouseCursors.grab;
      double moveDistanceX = (position.dx - start.dx);
      if (scale != 1.0) {
        if (scale != 1.0 && scale > 0) {
          //pointViewPort.interactionMoveUpdate(graphArea, moveDistanceX);
          pointViewPortInteractionHelper.interactionZoomUpdate(
            graphArea,
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
        double moveDistanceY = (position.dy - start.dy);
        valueViewPortInteractionHelper.interactionMoveUpdate(
          graphArea,
          moveDistanceY,
        );
      }
    };
    _hookScaleEnd = (Velocity? velocity) {
      _chart.mouseCursor.value = SystemMouseCursors.precise;
      pointViewPortInteractionHelper.interactionEnd();
      if (scaleValue) {
        valueViewPortInteractionHelper.interactionEnd();
      }
      if (velocity != null && panel.momentumScrollSpeed > 0) {
        // momentum scrolling
        final pointSize = pointViewPort.pointSize(graphArea.width);
        final distance =
            velocity.pixelsPerSecond.dx / pointSize * panel.momentumScrollSpeed;
        final newRange = GRange.range(
          pointViewPort.startPoint - distance,
          pointViewPort.endPoint - distance,
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
}

/// Helper class for handling [GPointViewPort] interactions.
class GPointViewPortInteractionHelper {
  GPointViewPort? _pointViewPort;
  final GRange _pointRangeScaling = GRange.empty();

  bool get isScaling => _pointViewPort != null;

  void interactionStart(GPointViewPort pointViewPort) {
    _pointViewPort = pointViewPort;
    _pointRangeScaling.copy(pointViewPort.range);
  }

  void interactionEnd() {
    _pointRangeScaling.clear();
    _pointViewPort?.selectedRange.clear();
    _pointViewPort = null;
    // _notify(finished: true);
  }

  void interactionZoomUpdate(Rect area, double zoomRatio) {
    if (_pointViewPort == null || _pointRangeScaling.isEmpty) {
      return;
    }
    _pointViewPort!.zoom(
      area,
      zoomRatio,
      startRange: _pointRangeScaling,
      centerPoint: _pointRangeScaling.last,
      animate: false,
      finished: false,
    );
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (_pointViewPort == null || _pointRangeScaling.isEmpty) {
      return;
    }
    double pointWidthStart = _pointViewPort!.pointSize(
      area.width,
      range: _pointRangeScaling,
    );
    double pointsMoved = movedDistance / pointWidthStart;
    double startPointNew = _pointRangeScaling.begin! - pointsMoved;
    double endPointNew = _pointRangeScaling.end! - pointsMoved;
    _pointViewPort!.setRange(
      startPoint: startPointNew,
      endPoint: endPointNew,
      finished: false,
    );
  }

  void interactionSelectUpdate(
    Rect area,
    double startPosition,
    double position, {
    bool animation = true,
    bool finished = false,
  }) {
    if (_pointViewPort == null || _pointRangeScaling.isEmpty) {
      return;
    }
    final position1 = min(startPosition, position);
    final position2 = max(startPosition, position);
    _pointViewPort!.selectedRange.update(
      _pointViewPort!.positionToPoint(
        area,
        max(area.left, min(area.right, position1)),
      ),
      _pointViewPort!.positionToPoint(
        area,
        max(area.left, min(area.right, position2)),
      ),
    );
    if (finished) {
      double value1 = _pointViewPort!.selectedRange.begin!;
      double value2 = _pointViewPort!.selectedRange.end!;
      double pointLeftNew = max(min(value1, value2), _pointRangeScaling.begin!);
      double pointRightNew = min(max(value1, value2), _pointRangeScaling.end!);
      double minPoints = area.width / _pointViewPort!.maxPointWidth;
      if (pointRightNew - pointLeftNew < minPoints) {
        // adjust to make sure the width is not less than minPointWidth
        double center = (pointLeftNew + pointRightNew) / 2;
        pointLeftNew = center - minPoints / 2;
        pointRightNew = center + minPoints / 2;
      }
      _pointViewPort!.animateToRange(
        GRange.range(pointLeftNew, pointRightNew),
        finished,
        animation,
      );
    }
  }
}

/// Helper class for handling [GValueViewPort] interactions.
class GValueViewPortInteractionHelper {
  GValueViewPort? _valueViewPort;
  final GRange _rangeScaling = GRange.empty();

  bool get isScaling => _valueViewPort != null;

  void interactionStart(GValueViewPort valueViewPort) {
    _valueViewPort = valueViewPort;
    _rangeScaling.copy(valueViewPort.range);
  }

  void interactionEnd() {
    _rangeScaling.clear();
    _valueViewPort?.selectedRange.clear();
    _valueViewPort = null;
    // _notify(finished: true);
  }

  void interactionZoomUpdate(
    Rect area,
    double zoomRatio, {
    bool notify = true,
  }) {
    if (!isScaling) {
      return;
    }
    _valueViewPort!.zoom(
      area,
      zoomRatio,
      startRange: _rangeScaling,
      animate: false,
      finished: true,
      notify: notify,
    );
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (!isScaling) {
      return;
    }
    double valueMoved =
        (movedDistance / area.height) *
        (_rangeScaling.last! - _rangeScaling.first!);
    double endValueNew = _rangeScaling.last! + valueMoved;
    double startValueNew = _rangeScaling.first! + valueMoved;
    _valueViewPort!.setRange(startValue: startValueNew, endValue: endValueNew);
  }

  void interactionSelectUpdate(
    Rect area,
    double startPosition,
    double position, {
    bool finished = false,
  }) {
    if (!isScaling) {
      return;
    }
    final value1 = _valueViewPort!.positionToValue(
      area,
      max(area.top, min(area.bottom, startPosition)),
    );
    final value2 = _valueViewPort!.positionToValue(
      area,
      max(area.top, min(area.bottom, position)),
    );
    _valueViewPort!.selectedRange.update(
      min(value1, value2),
      max(value1, value2),
    );
    if (finished) {
      double endValueNew = min(
        _valueViewPort!.selectedRange.last!,
        _rangeScaling.last!,
      );
      double startValueNew = max(
        _valueViewPort!.selectedRange.first!,
        _rangeScaling.first!,
      );
      (startValueNew, endValueNew) = _valueViewPort!.clampScaleRange(
        startValueNew,
        endValueNew,
      );
      _valueViewPort!.animateToRange(
        GRange.range(startValueNew, endValueNew),
        finished,
        true,
      );
    }
  }
}
