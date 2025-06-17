import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A wrapper of a pair of values with general type <[T]>.
class GPair<T> extends Equatable {
  GPair.pair(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  GPair.empty() {
    clear();
  }
  final List<T?> _range = List<T?>.filled(2, null);

  bool get isEmpty => _range[0] == null || _range[1] == null;
  bool get isNotEmpty => _range[0] != null && _range[1] != null;

  T? get begin => _range[0];
  T? get end => _range[1];
  T? get first => _range[0];
  T? get last => _range[1];

  void update(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  void copy(GPair<T> range) {
    _range[0] = range.begin;
    _range[1] = range.end;
  }

  void clear() {
    _range[0] = null;
    _range[1] = null;
  }

  @override
  List<Object?> get props => [..._range];
}

/// A wrapper of a pair of [double] values.
class GDoublePair extends GPair<double> with Diagnosticable {
  GDoublePair.pair(super.begin, super.end) : super.pair();
  GDoublePair.empty() : super.empty();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('begin', isEmpty ? null : begin))
      ..add(DoubleProperty('end', isEmpty ? null : end));
  }
}
