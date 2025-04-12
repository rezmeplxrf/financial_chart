import 'dart:ui';

import '../../chart.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../render.dart';
import '../graph/graph.dart';
import 'marker.dart';
import 'marker_theme.dart';
import '../viewport_v.dart';
import '../viewport_h.dart';

/// Base class for rendering a [GMarker].
///
/// This has different implementations from super [GRender] for it needs an extra [GGraph] parameter for rendering.
/// use [renderMarker] instead of super [GRender.render] to render a [GMarker].
abstract class GMarkerRender<M extends GMarker, T extends GMarkerTheme>
    extends GRender<M, T> {
  const GMarkerRender();

  void renderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required M marker,
    required Rect area,
    required T theme,
    GValueViewPort? valueViewPort,
  }) {
    if (!component.visible || !marker.visible) {
      return;
    }
    renderClipped(
      canvas: canvas,
      clipRect: area,
      render: () {
        doRenderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel,
          component: component,
          marker: marker,
          area: area,
          theme: theme,
          pointViewPort: chart.pointViewPort,
          valueViewPort: valueViewPort ?? panel.valueViewPorts.first,
        );
      },
    );
  }

  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required M marker,
    required Rect area,
    required T theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  });

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required M component,
    required Rect area,
    required T theme,
  }) {
    throw UnimplementedError("should call renderMarker for GMarkerRender");
  }
}
