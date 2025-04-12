import '../../components/marker/overlay_marker.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'polygon_marker_render.dart';

class GPolygonMarker extends GOverlayMarker {
  final GValue<bool> _close;
  bool get close => _close.value;
  set close(bool value) => _close.value = value;

  List<GCoordinate> get coordinates => [...keyCoordinates];

  GPolygonMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required List<GCoordinate> coordinates,
    bool close = true,
    super.render = const GPolygonMarkerRender(),
  }) : _close = GValue<bool>(close),
       super(keyCoordinates: coordinates);
}
