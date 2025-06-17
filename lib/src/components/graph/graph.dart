import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/graph/graph_render.dart';
import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/components/render.dart';
import 'package:financial_chart/src/components/viewport_v.dart';
import 'package:flutter/foundation.dart';

/// Base class for graph components.
///
/// This is not abstract so we can create a empty [GGraph] with only markers.
class GGraph<T extends GGraphTheme> extends GComponent {
  GGraph({
    super.id,
    this.valueViewPortId = '', // empty means the default view port id
    super.layer,
    super.visible,
    T? super.theme,
    GGraphRender? super.render,
    List<String>? crosshairHighlightValueKeys,
    List<GOverlayMarker> overlayMarkers = const [],
  }) {
    if (overlayMarkers.isNotEmpty) {
      _overlayMarkers.addAll(overlayMarkers);
    }
    if (crosshairHighlightValueKeys != null) {
      this.crosshairHighlightValueKeys.addAll(crosshairHighlightValueKeys);
    }
  }
  static const String typeName = 'graph';

  /// The value viewport id of the graph.
  ///
  /// see [GValueViewPort] for more details.
  final String valueViewPortId;

  /// The keys of the series value in the data source that
  /// will be highlighted by drawing a circle on the graph.
  final List<String> crosshairHighlightValueKeys = [];

  /// The graph markers of the graph.
  List<GOverlayMarker> get overlayMarkers => List.unmodifiable(_overlayMarkers);
  final List<GOverlayMarker> _overlayMarkers = [];

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('valueViewPortId', valueViewPortId));
    if (crosshairHighlightValueKeys.isNotEmpty) {
      properties.add(
        IterableProperty<String>(
          'crosshairHighlightValueKeys',
          crosshairHighlightValueKeys,
        ),
      );
    }
  }
}
