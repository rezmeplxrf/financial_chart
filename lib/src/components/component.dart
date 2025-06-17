import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/render.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// Base class for all view components.
abstract class GComponent<T extends GComponentTheme> with Diagnosticable {
  GComponent({
    this.id,
    bool visible = true,
    int layer = kDefaultLayer,
    T? theme,
    this.render,
  }) : _theme = GValue<T?>(theme),
       _visible = GValue<bool>(visible),
       _layer = GValue<int>(layer);
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

  GRender getRender() {
    return render!;
  }

  @override
  @mustCallSuper
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<String>('id', id))
      ..add(DiagnosticsProperty<bool>('visible', visible))
      ..add(IntProperty('layer', layer))
      ..add(DiagnosticsProperty<bool>('highlight', highlight))
      ..add(EnumProperty<GHitTestMode>('hitTestMode', hitTestMode));
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
