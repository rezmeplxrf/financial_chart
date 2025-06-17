import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/arrow/arrow_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/value.dart';

class GArrowMarker extends GOverlayMarker {
  GArrowMarker({
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    double headWidth = 4,
    double headLength = 10,
    super.render = const GArrowMarkerRender(),
  }) : _headWidth = GValue<double>(headWidth),
       _headLength = GValue<double>(headLength),
       super(keyCoordinates: [startCoord, endCoord]);
  final GValue<double> _headWidth;
  double get headWidth => _headWidth.value;
  set headWidth(double value) => _headWidth.value = value;

  final GValue<double> _headLength;
  double get headLength => _headLength.value;
  set headLength(double value) => _headLength.value = value;

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];
}
