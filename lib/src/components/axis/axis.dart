import 'dart:ui';

import 'package:financial_chart/src/components/axis/axis_render.dart';
import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/marker/axis_marker.dart';
import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/components/ticker.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

const defaultHAxisSize = 30.0; // in pixel
const defaultVAxisSize = 60.0; // in pixel

/// The position of the axis relative to the graph area.
enum GAxisPosition {
  /// the axis is placed besides the graph area at the start (left or top) position.
  start,

  /// the axis is placed besides the graph area at the end (right or bottom) position.
  end,

  /// the axis is placed inside the graph area at the start (left or top) position
  startInside,

  /// the axis is placed inside the graph area at the end (right or bottom) position
  endInside;

  bool get isInside =>
      this == GAxisPosition.startInside || this == GAxisPosition.endInside;
}

/// The scale mode when drags of the axis interactively.
enum GAxisScaleMode {
  /// no scale
  none,

  /// drag to zoom in/out
  zoom,

  /// drag to move the axis
  move,

  /// drag and select a portion to zoom in
  select,
}

/// The base class of the axis component.
abstract class GAxis extends GComponent {
  GAxis({
    required GAxisPosition position,
    required double size,
    super.id,
    super.visible,
    GAxisScaleMode scaleMode = GAxisScaleMode.zoom,
    super.render,
    super.theme,
    List<GAxisMarker> axisMarkers = const [],
    List<GOverlayMarker> overlayMarkers = const [],
  }) : _position = GValue<GAxisPosition>(position),
       _size = GValue<double>(size),
       _scaleMode = GValue<GAxisScaleMode>(scaleMode),
       super() {
    if (axisMarkers.isNotEmpty) {
      this.axisMarkers.addAll(axisMarkers);
    }
    if (overlayMarkers.isNotEmpty) {
      this.overlayMarkers.addAll(overlayMarkers);
    }
  }

  /// The position of the axis relative to the graph area.
  ///
  /// see [GAxisPosition] for more details.
  final GValue<GAxisPosition> _position;
  GAxisPosition get position => _position.value;
  set position(GAxisPosition value) => _position.value = value;

  /// The size of the axis in pixels.
  final GValue<double> _size;
  double get size => _size.value;
  set size(double value) => _size.value = value;

  /// The scale mode when drags the axis interactively.
  ///
  /// see [GAxisScaleMode] for more details.
  final GValue<GAxisScaleMode> _scaleMode;
  GAxisScaleMode get scaleMode => _scaleMode.value;
  set scaleMode(GAxisScaleMode value) => _scaleMode.value = value;

  /// Axis markers
  final List<GAxisMarker> axisMarkers = [];

  /// Overlay markers on the axis.
  final List<GOverlayMarker> overlayMarkers = [];

  static (List<Rect> axesAreas, Rect areaLeft) placeAxes(
    Rect area,
    List<GAxis> axes,
  ) {
    final axesAreas = <Rect>[];
    var areaAxis = Rect.zero;
    var areaLeft = area;
    // place the axes
    for (var n = 0; n < axes.length; n++) {
      final axis = axes[n];
      if (axis.position == GAxisPosition.startInside ||
          axis.position == GAxisPosition.endInside) {
        axesAreas.add(Rect.zero);
        continue;
      }
      (areaAxis, areaLeft) = axis.placeTo(areaLeft);
      axesAreas.add(areaAxis);
    }
    // adjust the area of inside axes
    for (var n = 0; n < axes.length; n++) {
      final axis = axes[n];
      if (axis.position == GAxisPosition.startInside ||
          axis.position == GAxisPosition.endInside) {
        (areaAxis, areaLeft) = axis.placeTo(areaLeft);
        axesAreas[n] = areaAxis;
      }
    }
    // adjust the area of the axes to fit final graph size
    for (var n = 0; n < axes.length; n++) {
      if (axes[n] is GPointAxis) {
        axesAreas[n] = Rect.fromLTRB(
          areaLeft.left,
          axesAreas[n].top,
          areaLeft.right,
          axesAreas[n].bottom,
        );
      } else {
        axesAreas[n] = Rect.fromLTRB(
          axesAreas[n].left,
          areaLeft.top,
          axesAreas[n].right,
          areaLeft.bottom,
        );
      }
    }
    return (axesAreas, areaLeft);
  }

  (Rect used, Rect areaLeft) placeTo(Rect area);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GAxisPosition>('position', position))
      ..add(DoubleProperty('size', size))
      ..add(EnumProperty<GAxisScaleMode>('scaleMode', scaleMode));
  }
}

/// value axis for vertical direction.
class GValueAxis extends GAxis {
  GValueAxis({
    super.id,
    this.viewPortId = '', // empty means the default view port id
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultVAxisSize,
    this.valueTickerStrategy = const GValueTickerStrategyDefault(),
    this.valueFormatter,
    List<GValueAxisMarker> axisMarkers = const [],
    super.overlayMarkers,
    super.theme,
    super.render = const GValueAxisRender(),
  }) : super(axisMarkers: axisMarkers);

  /// The value view port id of the value axis.
  final String viewPortId;

  /// The strategy to calculate the value ticks.
  final GValueTickerStrategy valueTickerStrategy;

  /// The formatter to format the value.
  final String Function(double value, int precision)? valueFormatter;

  bool get isAlignRight =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;
  bool get isAlignLeft =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

  /// place the axis to the given [area] and return the areas of the axis ([areaAxis]) and the area left ([areaLeft]).
  @override
  (Rect areaAxis, Rect areaLeft) placeTo(Rect area) {
    if (position == GAxisPosition.start) {
      return (
        Rect.fromLTWH(area.left, area.top, size, area.height),
        Rect.fromLTWH(
          area.left + size,
          area.top,
          area.width - size,
          area.height,
        ),
      );
    } else if (position == GAxisPosition.end) {
      return (
        Rect.fromLTWH(area.right - size, area.top, size, area.height),
        Rect.fromLTWH(area.left, area.top, area.width - size, area.height),
      );
    } else if (position == GAxisPosition.startInside) {
      return (
        Rect.fromLTWH(area.left, area.top, size, area.height),
        area.inflate(0),
      );
    } else if (position == GAxisPosition.endInside) {
      return (
        Rect.fromLTWH(area.right - size, area.top, size, area.height),
        area.inflate(0),
      );
    } else {
      return (Rect.zero, area.inflate(0));
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('viewPortId', viewPortId));
  }
}

/// point axis for horizontal direction.
class GPointAxis extends GAxis {
  GPointAxis({
    super.id,
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultHAxisSize,
    super.overlayMarkers,
    List<GPointAxisMarker> axisMarkers = const [],
    this.pointTickerStrategy = const GPointTickerStrategyDefault(),
    this.pointFormatter,
    super.theme,
    super.render = const GPointAxisRender(),
  }) : super(axisMarkers: axisMarkers);

  /// The strategy to calculate the point ticks.
  final GPointTickerStrategy pointTickerStrategy;

  /// The formatter to format the point value.
  final String Function(int, dynamic)? pointFormatter;

  bool get isAlignBottom =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;
  bool get isAlignTop =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

  /// place the axis to the given [area] and return the areas of the axis ([areaAxis]) and the area left ([areaLeft]).
  @override
  (Rect areaAxis, Rect areaLeft) placeTo(Rect area) {
    if (position == GAxisPosition.start) {
      return (
        Rect.fromLTWH(area.left, area.top, area.width, size),
        Rect.fromLTWH(
          area.left,
          area.top + size,
          area.width,
          area.height - size,
        ),
      );
    } else if (position == GAxisPosition.end) {
      return (
        Rect.fromLTWH(area.left, area.bottom - size, area.width, size),
        Rect.fromLTWH(area.left, area.top, area.width, area.height - size),
      );
    } else if (position == GAxisPosition.startInside) {
      return (
        Rect.fromLTWH(area.left, area.top, area.width, size),
        area.inflate(0),
      );
    } else if (position == GAxisPosition.endInside) {
      return (
        Rect.fromLTWH(area.left, area.bottom - size, area.width, size),
        area.inflate(0),
      );
    } else {
      return (Rect.zero, area.inflate(0));
    }
  }
}
