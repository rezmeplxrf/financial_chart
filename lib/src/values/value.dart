import 'package:flutter/foundation.dart';

bool _defaultValidator(dynamic value) => true;

/// A wrapper of a single value with type <[T]> and an optional validator.
class GValue<T> extends ValueNotifier<T> {

  GValue(T initialValue, {this.validator = _defaultValidator})
    : super(initialValue) {
    assert(validator(initialValue), 'Invalid value');
  }
  final bool Function(T) validator;

  /// Set new value with validation.
  @override
  set value(T newValue) {
    assert(validator(newValue), 'Invalid value');
    super.value = newValue;
    if (super.hasListeners) {
      notifyListeners();
    }
  }
}
