import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/shapes/shape_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/size.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/painting.dart';

class GShapeMarker extends GOverlayMarker {
  GShapeMarker({
    required GCoordinate anchorCoord,
    required GSize radiusSize,
    required this.pathGenerator,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    double rotation = 0,
    Alignment alignment =
        Alignment
            .center, // where anchor point located on the bound rect of the circle
    super.render = const GShapeMarkerRender(),
  }) : _radiusSize = GValue<GSize>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _rotation = GValue<double>(rotation),
       super(keyCoordinates: [anchorCoord]) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
  }
  final GValue<GSize> _radiusSize;
  GSize get radiusSize => _radiusSize.value;
  set radiusSize(GSize value) => _radiusSize.value = value;

  GCoordinate get anchorCoord => keyCoordinates[0];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _rotation;
  double get rotation => _rotation.value;
  set rotation(double value) => _rotation.value = value;

  final Path Function(double radius) pathGenerator;
}
