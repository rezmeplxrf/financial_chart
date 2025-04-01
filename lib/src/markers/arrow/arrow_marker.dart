import '../../components/marker/marker.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'arrow_marker_render.dart';

class GArrowMarker extends GGraphMarker {
  final GValue<double> _headWidth;
  double get headWidth => _headWidth.value;
  set headWidth(double value) => _headWidth.value = value;

  final GValue<double> _headLength;
  double get headLength => _headLength.value;
  set headLength(double value) => _headLength.value = value;

  GArrowMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    double headWidth = 4,
    double headLength = 10,
    super.render = const GArrowMarkerRender(),
  }) : _headWidth = GValue<double>(headWidth),
       _headLength = GValue<double>(headLength),
       super(keyCoordinates: [startCoord, endCoord]);
}
