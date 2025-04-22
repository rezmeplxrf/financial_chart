import 'package:flutter/foundation.dart';

import '../values/value.dart';
import 'component_theme.dart';
import 'render.dart';

/// Base class for all view components.
abstract class GComponent<T extends GComponentTheme> {
  static const int kDefaultLayer = 1000;

  /// Identifier of the component.
  ///
  /// Set it with a unique value if you want to access the component instance later by this id.
  final String? id;

  /// Whether the graph is visible.
  final GValue<bool> _visible;
  bool get visible => _visible.value;
  set visible(bool value) => _visible.value = value;

  /// The layer of the graph. highest layer will be on the top.
  final GValue<int> _layer;
  int get layer => _layer.value;
  set layer(int value) => _layer.value = value;

  /// Whether the graph is highlighted (or selected).
  final GValue<bool> _highlight = GValue<bool>(false);
  bool get highlight => _highlight.value;
  set highlight(bool value) => _highlight.value = value;

  /// The hit test mode of the graph.
  ///
  /// see [GHitTestMode] for more details.
  final GValue<GHitTestMode> _hitTestMode = GValue<GHitTestMode>(
    GHitTestMode.border,
  );
  GHitTestMode get hitTestMode => _hitTestMode.value;
  set hitTestMode(GHitTestMode value) => _hitTestMode.value = value;

  /// Theme of the component to override the global default theme.
  final GValue<T?> _theme;
  T? get theme => _theme.value;
  set theme(T? value) => _theme.value = value;

  /// Render of the component.
  @protected
  GRender? render;

  GComponent({
    this.id,
    bool visible = true,
    int layer = kDefaultLayer,
    GHitTestMode hitTestMode = GHitTestMode.border,
    T? theme,
    this.render,
  }) : _theme = GValue<T?>(theme),
       _visible = GValue<bool>(visible),
       _layer = GValue<int>(layer);

  GRender getRender() {
    return render!;
  }
}

/// Hit test mode of the component.
enum GHitTestMode {
  /// No hit test.
  none,

  /// Hit test the border lines of the component.
  border,

  /// Hit test the area of the component.
  area,
}
