import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/line/line_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';

class GLineMarker extends GOverlayMarker {
  GLineMarker({
    required List<GCoordinate> coordinates,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    super.render = const GLineMarkerRender(),
  }) : super(keyCoordinates: [...coordinates]);
  List<GCoordinate> get coordinates => [...keyCoordinates];
}
