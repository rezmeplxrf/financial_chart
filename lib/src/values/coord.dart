import 'dart:ui';

import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:financial_chart/src/values/pair.dart';

/// base class for coordinate
abstract class GCoordinate extends GDoublePair {
  GCoordinate(super.x, super.y) : super.pair();
  double get x => super.begin!;
  double get y => super.end!;

  /// convert the coordinate to position in the view area
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  });
}

/// Coordinate with x and y as position in the view area.
///
/// [x] and [y] can be absolute position or ratio of the width and height of the view area.
class GPositionCoord extends GCoordinate {

  GPositionCoord({
    required double x,
    required double y,
    this.xIsRatio = false,
    this.yIsRatio = false,
    this.xOffset = 0,
    this.yOffset = 0,
  }) : super(x, y);

  /// create a coordinate with absolute position in the view area
  GPositionCoord.absolute({required double x, required double y})
    : this(x: x, y: y, xIsRatio: false, yIsRatio: false);

  /// create a coordinate with ratio of the width and height of the view area
  GPositionCoord.rational({
    required double x,
    required double y,
    double xOffset = 0,
    double yOffset = 0,
  }) : this(
         x: x,
         y: y,
         xOffset: xOffset,
         yOffset: yOffset,
         xIsRatio: true,
         yIsRatio: true,
       );
  /// true if [x] is ratio of the width of the view area, false if x is absolute position
  final bool xIsRatio;

  /// true if [y] is ratio of the height of the view area, false if y is absolute position
  final bool yIsRatio;

  /// An additional x offset to the position
  ///
  /// useful when need to add some offset to the position calculated from rational position.
  final double xOffset;

  /// An additional y offset to the position
  ///
  /// useful when need to add some offset to the position calculated from rational position.
  final double yOffset;

  /// create a copy of this coordinate with some changes
  GPositionCoord copyWith({
    double? x,
    double? y,
    double? xOffset,
    double? yOffset,
  }) {
    return GPositionCoord(
      x: x ?? this.x,
      y: y ?? this.y,
      xIsRatio: xIsRatio,
      yIsRatio: yIsRatio,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
    );
  }

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return Offset(
      (xIsRatio ? (area.width * x) : x) + area.left + xOffset,
      (yIsRatio ? (area.height * y) : y) + area.top + yOffset,
    );
  }
}

/// Coordinate with x as point in the point view port and y as value in the value view port.
///
/// see [GPointViewPort] and [GValueViewPort] for details of viewports.
class GViewPortCoord extends GCoordinate {

  GViewPortCoord({required double point, required double value})
    : super(point, value);

  /// create a coordinate from position in the view area
  GViewPortCoord.fromPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) : this(
         point: pointViewPort.positionToPoint(area, position.dx),
         value: valueViewPort.positionToValue(area, position.dy),
       );
  double get point => super.begin!;
  double get value => super.end!;

  /// create a copy of this coordinate with some changes
  GViewPortCoord copyWith({double? point, double? value}) {
    return GViewPortCoord(
      point: point ?? this.point,
      value: value ?? this.value,
    );
  }

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return Offset(
      pointViewPort.pointToPosition(area, point),
      valueViewPort.valueToPosition(area, value),
    );
  }
}

/// User defined function to convert a value pair ([x], [y]) to position in the view area
typedef GCoordinateConvertor =
    Offset Function({
      required double x,
      required double y,
      required Rect area,
      required GPointViewPort pointViewPort,
      required GValueViewPort valueViewPort,
    });

/// predefined [GCoordinateConvertor] to convert [x] in position and [y] in viewport to position in the view area.
Offset kCoordinateConvertorXPositionYValue({
  required double x,
  required double y,
  required Rect area,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  return Offset(
    (area.width * x) + area.left,
    valueViewPort.valueToPosition(area, y),
  );
}

/// predefined [GCoordinateConvertor] to convert [x] in viewport and [y] in position to position in the view area.
Offset kCoordinateConvertorXPointYPosition({
  required double x,
  required double y,
  required Rect area,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  return Offset(
    pointViewPort.pointToPosition(area, x),
    (area.height * y) + area.top,
  );
}

/// Coordinate with [x] and [y] along with a user defined convertor function
///
/// convertor is function with type of [GCoordinateConvertor].
class GCustomCoord extends GCoordinate {
  GCustomCoord({
    required double x,
    required double y,
    required this.coordinateConvertor,
  }) : super(x, y);
  final GCoordinateConvertor coordinateConvertor;

  /// create a copy of this coordinate with some changes
  GCustomCoord copyWith({
    double? x,
    double? y,
    GCoordinateConvertor? coordinateConvertor,
  }) {
    return GCustomCoord(
      x: x ?? this.x,
      y: y ?? this.y,
      coordinateConvertor: coordinateConvertor ?? this.coordinateConvertor,
    );
  }

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return coordinateConvertor(
      x: x,
      y: y,
      area: area,
      pointViewPort: pointViewPort,
      valueViewPort: valueViewPort,
    );
  }
}
