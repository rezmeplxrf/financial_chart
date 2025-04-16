import '../../values/value.dart';
import '../marker/overlay_marker.dart';
import '../render.dart';
import 'graph_render.dart';
import 'graph_theme.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../viewport_v.dart';

/// Base class for graph components.
///
/// This is not abstract so we can create a empty [GGraph] with only markers.
class GGraph<T extends GGraphTheme> extends GComponent {
  static const String typeName = 'graph';

  static const int kDefaultLayer = 1000;

  /// The layer of the graph. highest layer will be on the top.
  final GValue<int> _layer;
  int get layer => _layer.value;
  set layer(int value) => _layer.value = value;

  /// Whether the graph is highlighted (or selected).
  final GValue<bool> _highlight = GValue<bool>(false);
  bool get highlight => _highlight.value;
  set highlight(bool value) => _highlight.value = value;

  /// The value viewport id of the graph.
  ///
  /// see [GValueViewPort] for more details.
  /// point viewport is shared for the whole panel. see [GPanel.pointViewPortId]
  final String valueViewPortId;

  /// The hit test mode of the graph.
  ///
  /// see [GHitTestMode] for more details.
  final GValue<GHitTestMode> _hitTestMode = GValue<GHitTestMode>(
    GHitTestMode.border,
  );
  GHitTestMode get hitTestMode => _hitTestMode.value;
  set hitTestMode(GHitTestMode value) => _hitTestMode.value = value;

  final List<String> crosshairHighlightValueKeys = [];

  /// The graph markers of the graph.
  List<GOverlayMarker> get overlayMarkers => List.unmodifiable(_overlayMarkers);
  final List<GOverlayMarker> _overlayMarkers = [];

  GGraph({
    String? id,
    this.valueViewPortId = "", // empty means the default view port id
    int layer = kDefaultLayer,
    super.visible,
    GHitTestMode hitTestMode = GHitTestMode.border,
    T? theme,
    GGraphRender? render,
    List<String>? crosshairHighlightValueKeys,
    List<GOverlayMarker> overlayMarkers = const [],
  }) : _layer = GValue<int>(layer),
       super(id: id, render: render, theme: theme) {
    _hitTestMode.value = hitTestMode;
    if (overlayMarkers.isNotEmpty) {
      _overlayMarkers.addAll(overlayMarkers);
    }
    if (crosshairHighlightValueKeys != null) {
      this.crosshairHighlightValueKeys.addAll(crosshairHighlightValueKeys);
    }
  }

  GOverlayMarker? findMarker(String id) {
    return _overlayMarkers.where((marker) => marker.id == id).firstOrNull;
  }

  GOverlayMarker? removeMarkerById(String id) {
    final marker = findMarker(id);
    if (marker != null) {
      _overlayMarkers.remove(marker);
      return marker;
    }
    return null;
  }

  bool removeMarker(GOverlayMarker marker) {
    return _overlayMarkers.remove(marker);
  }

  void addMarker(GOverlayMarker marker) {
    _overlayMarkers.add(marker);
  }

  @override
  GRender getRender() {
    return render ?? const GGraphRender();
  }

  String get type => typeName;
}
