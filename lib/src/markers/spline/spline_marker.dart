import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/spline/spline_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/value.dart';

class GSplineMarker extends GOverlayMarker {
  GSplineMarker({
    required List<GCoordinate> coordinates,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    bool close = false,
    super.render = const GSplineMarkerRender(),
  }) : _close = GValue<bool>(close),
       super(keyCoordinates: [...coordinates]);
  final GValue<bool> _close;
  bool get close => _close.value;
  set close(bool value) => _close.value = value;

  List<GCoordinate> get coordinates => [...keyCoordinates];
}
