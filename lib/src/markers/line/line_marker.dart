import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import 'line_marker_render.dart';

class GLineMarker extends GGraphMarker {
  GLineMarker({
    String? id,
    bool visible = true,
    required List<GCoordinate> coordinates,
    GGraphMarkerTheme? theme,
    super.render = const GLineMarkerRender(),
  }) : super(
         id: id,
         visible: visible,
         keyCoordinates: [...coordinates],
         theme: theme,
       );
}
