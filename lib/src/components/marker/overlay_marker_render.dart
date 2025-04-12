import 'overlay_marker.dart';
import 'marker_render.dart';
import 'overlay_marker_theme.dart';

/// Base class for rendering a [GOverlayMarker].
abstract class GOverlayMarkerRender<
  M extends GOverlayMarker,
  T extends GOverlayMarkerTheme
>
    extends GMarkerRender<M, T> {
  const GOverlayMarkerRender();
}
