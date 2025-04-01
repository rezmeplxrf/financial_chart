import '../../components/marker/marker.dart';
import '../../values/coord.dart';
import 'line_marker_render.dart';

class GLineMarker extends GGraphMarker {
  GLineMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required List<GCoordinate> coordinates,
    super.render = const GLineMarkerRender(),
  }) : super(keyCoordinates: [...coordinates]);
}
