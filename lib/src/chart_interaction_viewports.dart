part of 'chart_interaction.dart';

/// Helper class for handling [GPointViewPort] interactions.
class GPointViewPortInteractionHelper {
  GPointViewPort? _pointViewPort;
  final GRange _pointRangeScaling = GRange.empty();

  bool get isScaling => _pointViewPort != null && _pointRangeScaling.isNotEmpty;

  void interactionStart(GPointViewPort pointViewPort) {
    _pointViewPort = pointViewPort;
    _pointRangeScaling.copy(pointViewPort.range);
  }

  void interactionEnd({bool notify = true}) {
    _pointRangeScaling.clear();
    _pointViewPort?.selectedRange.clear();
    if (notify) {
      _pointViewPort?.notify(finished: true);
    }
    _pointViewPort = null;
  }

  void interactionZoomUpdate(
    Rect area,
    Offset startPosition,
    Offset? position,
    double zoomRatio,
  ) {
    if (_pointViewPort == null || _pointRangeScaling.isEmpty) {
      return;
    }
    var point = _pointRangeScaling.last!;
    if (position != null) {
      point = _pointViewPort!.positionToPoint(area, position.dx);
    }
    _pointViewPort!.zoom(
      area,
      zoomRatio,
      startRange: _pointRangeScaling,
      centerPoint: point, //_pointRangeScaling.last,
      animate: false,
      finished: false,
    );
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (_pointViewPort == null || _pointRangeScaling.isEmpty) {
      return;
    }
    final pointWidthStart = _pointViewPort!.pointSize(
      area.width,
      range: _pointRangeScaling,
    );
    final pointsMoved = movedDistance / pointWidthStart;
    final startPointNew = _pointRangeScaling.begin! - pointsMoved;
    final endPointNew = _pointRangeScaling.end! - pointsMoved;
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
      final value1 = _pointViewPort!.selectedRange.begin!;
      final value2 = _pointViewPort!.selectedRange.end!;
      double pointLeftNew = max(min(value1, value2), _pointRangeScaling.begin!);
      double pointRightNew = min(max(value1, value2), _pointRangeScaling.end!);
      final minPoints = area.width / _pointViewPort!.maxPointWidth;
      if (pointRightNew - pointLeftNew < minPoints) {
        // adjust to make sure the width is not less than minPointWidth
        final center = (pointLeftNew + pointRightNew) / 2;
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
      notify: notify,
    );
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (!isScaling) {
      return;
    }
    final valueMoved =
        (movedDistance / area.height) *
        (_rangeScaling.last! - _rangeScaling.first!);
    final endValueNew = _rangeScaling.last! + valueMoved;
    final startValueNew = _rangeScaling.first! + valueMoved;
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
