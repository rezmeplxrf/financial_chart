// ignore_for_file: avoid_positional_boolean_parameters

import 'package:financial_chart/src/chart.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/components/viewport_resize.dart';
import 'package:financial_chart/src/components/viewport_v_scaler.dart';
import 'package:financial_chart/src/values/range.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Viewport for value (vertical) axis
class GValueViewPort extends ChangeNotifier with Diagnosticable {
  /// Create a value viewport.
  ///
  /// Set proper [initialEndValue] and [initialStartValue] when [autoScaleStrategy] not provided.
  GValueViewPort({
    required this.valuePrecision,
    this.id = '',
    double? initialEndValue,
    double? initialStartValue,
    this.autoScaleStrategy,
    GViewPortResizeMode? resizeMode,
    int animationMilliseconds = 200,
    this.onRangeUpdate,
    this.maxRangeSize,
    this.minRangeSize,
  }) {
    assert(
      (initialStartValue == null && initialEndValue == null) ||
          (initialStartValue != null && initialEndValue != null),
    );
    if (initialStartValue != null && initialEndValue != null) {
      assert(initialEndValue > initialStartValue);
      _autoScale.value = false;
    }
    if (maxRangeSize != null) {
      assert(maxRangeSize! > 0);
    }
    if (maxRangeSize != null) {
      assert(maxRangeSize! > 0);
      if (minRangeSize != null) {
        assert(minRangeSize! < maxRangeSize!);
      }
    }
    _range.update(initialStartValue ?? 0, initialEndValue ?? 1);
    _animationMilliseconds.value = animationMilliseconds;
    if (resizeMode != null) {
      _resizeMode.value = resizeMode;
    }
  }

  /// Identifier of the viewport which being referenced by components.
  final String id;

  /// The decimal precision of the value.
  final int valuePrecision;

  /// Current value range (top and bottom) of the viewport.
  final GRange _range = GRange.empty();
  GRange get range => _range;
  bool get isValid => _range.isNotEmpty;

  /// The end (top) value of the viewport.
  double get endValue => _range.last!;

  /// The start (bottom) value of the viewport.
  double get startValue => _range.first!;

  /// The center value of the viewport.
  double get centerValue => (endValue + startValue) / 2;

  /// The value range of the viewport ([endValue]-[startValue]).
  double get rangeSize => endValue - startValue;

  /// The range when selecting. will be cleared when selection finished.
  GRange get selectedRange => _selectedRange;
  final GRange _selectedRange = GRange.empty();

  /// Whether the viewport is auto scaling mode.
  bool get autoScaleFlg => _autoScale.value;
  set autoScaleFlg(bool value) => _autoScale.value = value;
  final GValue<bool> _autoScale = GValue<bool>(true);

  /// The auto scale strategy to calculate the range when auto scale enabled.
  final GValueViewPortAutoScaleStrategy? autoScaleStrategy;

  /// Defines the behavior of how to update the viewport range when view size changed.
  final GValue<GViewPortResizeMode> _resizeMode = GValue<GViewPortResizeMode>(
    GViewPortResizeMode.keepRange,
  );
  GViewPortResizeMode get resizeMode => _resizeMode.value;
  set resizeMode(GViewPortResizeMode value) => _resizeMode.value = value;

  /// The minimum value range when scaling.
  final double? minRangeSize;

  /// The maximum value range when scaling.
  final double? maxRangeSize;

  /// Callback when range updated.
  final GRange Function({required GRange updatedRange, required bool finished})?
  onRangeUpdate;

  /// The animation milliseconds when auto scaling.
  ///
  /// set to 0 to disable animation.
  final GValue<int> _animationMilliseconds = GValue<int>(2000);
  int get animationMilliseconds => _animationMilliseconds.value;
  set animationMilliseconds(int value) {
    assert(
      value >= 0,
      'animationMilliseconds should be greater than or equal to 0.',
    );
    if (_animationMilliseconds.value == value) {
      return;
    }
    _animationMilliseconds.value = value;
    if (_rangeAnimationController != null) {
      _rangeAnimationController!.duration = Duration(
        milliseconds: animationMilliseconds,
      );
    }
  }

  AnimationController? _rangeAnimationController;
  Animation<double>? _rangeAnimation;
  final GRange _animationStartRange = GRange.empty();
  final GRange _animationTargetRange = GRange.empty();
  bool get isAnimating => _animationStartRange.isNotEmpty;

  void initializeAnimation(TickerProvider vsync) {
    if (_rangeAnimationController == null && animationMilliseconds > 0) {
      _rangeAnimationController = AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: animationMilliseconds),
      );
      _rangeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _rangeAnimationController!,
          curve: Curves.easeOutCubic,
        ),
      );
      _rangeAnimation!.addListener(_rangeAnimationListener);
    }
  }

  void _notifyRangeUpdated({required bool finished}) {
    if (!_disposed && super.hasListeners) {
      notifyListeners();
    }
    if (onRangeUpdate != null) {
      _range.copy(
        onRangeUpdate!.call(updatedRange: _range, finished: finished),
      );
    }
  }

  void stopAnimation() {
    if (_disposed) {
      return;
    }
    _rangeAnimationController?.stop();
    _animationStartRange.clear();
    _animationTargetRange.clear();
  }

  void _rangeAnimationListener() {
    if (_disposed) {
      return;
    }
    if (_animationStartRange.isEmpty || _animationTargetRange.isEmpty) {
      return;
    }
    final updatedRange = GRange.lerp(
      _animationStartRange,
      _animationTargetRange,
      _rangeAnimation!.value,
    );
    setRange(
      startValue: updatedRange.first!,
      endValue: updatedRange.last!,
      finished: false,
    );
  }

  void animateToRange(
    GRange targetRange,
    bool finished,
    bool animation, {
    VoidCallback? onFinished,
    bool notify = true,
  }) {
    if (_disposed) {
      return;
    }
    if (!animation ||
        _rangeAnimationController == null ||
        (targetRange == _range)) {
      setRange(
        startValue: targetRange.begin!,
        endValue: targetRange.end!,
        finished: finished,
        notify: notify,
      );
      onFinished?.call();
      return;
    }
    stopAnimation();
    _animationStartRange.update(startValue, endValue);
    _animationTargetRange.copy(targetRange);

    Future.delayed(const Duration(milliseconds: 10), () {
      _rangeAnimationController!.reset();
      _rangeAnimationController!.forward().then((_) {
        stopAnimation();
        onFinished?.call();
      }, onError: (_, _) => stopAnimation());
    });
  }

  void setRange({
    required double startValue,
    required double endValue,
    bool finished = true,
    bool notify = true,
  }) {
    if (_disposed) {
      return;
    }
    assert(endValue > startValue);
    if (onRangeUpdate == null) {
      if (endValue == this.endValue && startValue == this.startValue) {
        return;
      }
    }
    final (startValueClamped, endValueClamped) = clampScaleRange(
      startValue,
      endValue,
    );
    _range.update(startValueClamped, endValueClamped);
    if (notify) {
      _notifyRangeUpdated(finished: finished);
    }
  }

  /// update the viewport range when view size changed (ignored when auto scaling is on).
  void resize(double fromSize, double toSize, bool notify) {
    if (_disposed) {
      return;
    }
    if (resizeMode == GViewPortResizeMode.keepRange ||
        fromSize == toSize ||
        !isValid ||
        autoScaleFlg) {
      return;
    }
    final valueDensityCurrent = (endValue - startValue) / fromSize;
    if (valueDensityCurrent <= 0) {
      return;
    }
    switch (resizeMode) {
      case GViewPortResizeMode.keepStart:
        setRange(
          startValue: startValue,
          endValue: startValue + valueDensityCurrent * toSize,
          notify: notify,
        );
      case GViewPortResizeMode.keepEnd:
        setRange(
          startValue: endValue - valueDensityCurrent * toSize,
          endValue: endValue,
          notify: notify,
        );
      case GViewPortResizeMode.keepCenter:
        final centerValue = (endValue + startValue) / 2;
        final newStartValue = centerValue - valueDensityCurrent * toSize / 2;
        final newEndValue = centerValue + valueDensityCurrent * toSize / 2;
        setRange(
          startValue: newStartValue,
          endValue: newEndValue,
          notify: notify,
        );
      case GViewPortResizeMode.keepRange:
        break;
    }
  }

  /// convert value to position
  double valueToPosition(Rect area, double value) {
    return area.bottom -
        (value - startValue) / (endValue - startValue) * area.height;
  }

  /// convert position to value
  double positionToValue(Rect area, double position) {
    return startValue +
        (area.bottom - position) / area.height * (endValue - startValue);
  }

  /// convert value to size
  double valueToSize(double viewSize, double value) {
    return value * viewSize / (endValue - startValue);
  }

  /// convert size to value
  double sizeToValue(double viewSize, double size) {
    return size * (endValue - startValue) / viewSize;
  }

  (double startValueClamped, double endValueClamped) clampScaleRange(
    double startValue,
    double endValue,
  ) {
    var endValueClamped = endValue;
    var startValueClamped = startValue;
    if (minRangeSize != null) {
      if (endValueClamped - startValueClamped < minRangeSize!) {
        // expand from center
        final centerValue = (endValue + startValue) / 2;
        endValueClamped = centerValue + minRangeSize! / 2;
        startValueClamped = centerValue - minRangeSize! / 2;
      }
    }
    if (maxRangeSize != null) {
      if (endValueClamped - startValueClamped > maxRangeSize!) {
        // shrink from center
        final centerValue = (endValue + startValue) / 2;
        endValueClamped = centerValue + maxRangeSize! / 2;
        startValueClamped = centerValue - maxRangeSize! / 2;
      }
    }
    return (startValueClamped, endValueClamped);
  }

  /// zoom in/out the viewport range.
  void _zoom(
    GRange startRange,
    Rect area,
    double zoomRatio, {
    bool animate = false,
    bool finished = true,
    bool notify = true,
  }) {
    if (startRange.isEmpty) {
      return;
    }
    autoScaleFlg = false;
    final centerValue = (startRange.first! + startRange.last!) / 2;
    var endValueNew =
        centerValue + (startRange.last! - centerValue) / zoomRatio;
    var startValueNew =
        centerValue + (startRange.first! - centerValue) / zoomRatio;
    (startValueNew, endValueNew) = clampScaleRange(startValueNew, endValueNew);
    animateToRange(
      GRange.range(startValueNew, endValueNew),
      true,
      animate,
      notify: notify,
    );
  }

  void zoom(
    Rect area,
    double zoomRatio, {
    GRange? startRange,
    bool animate = true,
    bool finished = true,
    bool notify = true,
  }) {
    _zoom(
      startRange ?? _range,
      area,
      zoomRatio,
      animate: animate,
      finished: finished,
      notify: notify,
    );
  }

  void autoScaleReset({
    required GChart chart,
    required GPanel panel,
    bool autoScaleFlg = true,
    bool finished = true,
    bool animation = true,
    VoidCallback? onFinished,
    bool notify = true,
  }) {
    _autoScale.value = autoScaleFlg;
    if (autoScaleStrategy == null) {
      return;
    }
    final newRange = autoScaleStrategy!.getScale(
      chart: chart,
      panel: panel,
      valueViewPort: this,
    );
    if (newRange.isEmpty || newRange.begin! >= newRange.end!) {
      return;
    }
    final (startValueClamped, endValueClamped) = clampScaleRange(
      newRange.begin!,
      newRange.end!,
    );
    animateToRange(
      GRange.range(startValueClamped, endValueClamped),
      finished,
      animation,
      onFinished: onFinished,
      notify: notify,
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _rangeAnimation?.removeListener(_rangeAnimationListener);
    _rangeAnimationController
      ?..stop()
      ..dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('id', id))
      ..add(DiagnosticsProperty<GRange>('range', range))
      ..add(DoubleProperty('rangeSize', rangeSize))
      ..add(IntProperty('valuePrecision', valuePrecision))
      ..add(DiagnosticsProperty<GRange>('selectedRange', selectedRange))
      ..add(DiagnosticsProperty<bool>('autoScaleFlg', autoScaleFlg))
      ..add(
        DiagnosticsProperty<bool>(
          'autoScaleStrategy',
          autoScaleStrategy != null,
        ),
      )
      ..add(IntProperty('animationMilliseconds', animationMilliseconds))
      ..add(
        DiagnosticsProperty<GViewPortResizeMode>('resizeMode', resizeMode),
      );
  }
}
