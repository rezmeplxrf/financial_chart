import 'package:financial_chart/src/components/marker/marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';

/// Base class for rendering a [GOverlayMarker].
abstract class GOverlayMarkerRender<
  M extends GOverlayMarker,
  T extends GOverlayMarkerTheme
>
    extends GMarkerRender<M, T> {
  const GOverlayMarkerRender();
}
