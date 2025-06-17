// ignore_for_file: one_member_abstracts

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/viewport_h.dart';
import 'package:financial_chart/src/values/range.dart';

/// Auto scale strategy for point [GPointViewPort].
abstract class GPointViewPortAutoScaleStrategy {
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  });
}

/// Auto scale strategy to let last point at the end (right) of graph area and point width is [GPointViewPort.defaultPointWidth].
class GPointViewPortAutoScaleStrategyLatest
    implements GPointViewPortAutoScaleStrategy {
  const GPointViewPortAutoScaleStrategyLatest({this.endSpacingPoints = 2});
  final int endSpacingPoints;
  @override
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  }) {
    final dataSource = chart.dataSource;
    final lastPoint =
        ((dataSource.isEmpty && pointViewPort.isValid)
            ? pointViewPort.endPoint
            : dataSource.lastPoint.toDouble()) +
        endSpacingPoints;
    final viewPointCount =
        (panel.graphArea().width / pointViewPort.defaultPointWidth).ceil();
    return GRange.range(
      lastPoint - viewPointCount,
      lastPoint,
    );
  }
}

/// Auto scale strategy that keeps [alignToPosition] and updates start & end to make point width be [GPointViewPort.defaultPointWidth].
class GPointViewPortAutoScaleStrategyAlignTo
    implements GPointViewPortAutoScaleStrategy {
  const GPointViewPortAutoScaleStrategyAlignTo({this.alignToPosition})
    : assert(
        (alignToPosition == null) ||
            (alignToPosition >= 0 && alignToPosition <= 1),
      );

  /// The position to align to.
  ///
  /// When it is null, will calculate from current pointer position each time.
  /// The value should be a range from 0 ~ 1 while 0 means start (left) and 1 is end(right) of the viewPort.
  final double? alignToPosition;
  @override
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  }) {
    final dataSource = chart.dataSource;
    final viewPointCount =
        (panel.graphArea().width / pointViewPort.defaultPointWidth).ceil();
    if (dataSource.isEmpty) {
      return GRange.range(pointViewPort.startPoint, pointViewPort.endPoint);
    }
    if (!pointViewPort.isValid || chart.crosshair.crossPosition.isEmpty) {
      final lastPoint = dataSource.lastPoint + 1;
      return GRange.range(
        (lastPoint - viewPointCount).toDouble(),
        lastPoint.toDouble(),
      );
    }
    final position =
        alignToPosition ??
        (chart.crosshair.crossPosition.begin! - panel.graphArea().left) /
            panel.graphArea().width;
    final alignToPoint =
        pointViewPort.startPoint +
        (pointViewPort.endPoint - pointViewPort.startPoint) * position;
    return GRange.range(
      alignToPoint - viewPointCount * position,
      alignToPoint + viewPointCount * (1 - position),
    );
  }
}
