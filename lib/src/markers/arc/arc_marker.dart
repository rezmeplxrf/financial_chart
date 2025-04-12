import 'package:flutter/painting.dart';

import '../../components/marker/overlay_marker.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'arc_marker_render.dart';

class GArcMarker extends GOverlayMarker {
  final GValue<GSize?> _radiusSize;
  GSize? get radiusSize => _radiusSize.value;
  set radiusSize(GSize? value) => _radiusSize.value = value;

  GCoordinate? get anchorCoord =>
      _radiusSize.value == null ? null : keyCoordinates[0];
  GCoordinate? get centerCoord =>
      _radiusSize.value != null ? null : keyCoordinates[0];
  GCoordinate? get borderCoord =>
      _radiusSize.value != null ? null : keyCoordinates[1];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _startTheta;
  double get startTheta => _startTheta.value;
  set startTheta(double value) => _startTheta.value = value;

  final GValue<double> _endTheta;
  double get endTheta => _endTheta.value;
  set endTheta(double value) => _endTheta.value = value;

  final GValue<bool> _close;
  bool get close => _close.value;
  set close(bool value) => _close.value = value;

  GArcMarker({
    super.id,
    super.visible,
    super.theme,
    super.layer,
    super.hitTestMode,
    required GCoordinate centerCoord,
    required GCoordinate borderCoord,
    required double startTheta,
    required double endTheta,
    bool close = false,
  }) : _radiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _close = GValue<bool>(close),
       super(
         keyCoordinates: [
           centerCoord,
           borderCoord,
         ], // the distance between "center" and "border" decides the render radius
       ) {
    super.render = GArcMarkerRender();
  }

  GArcMarker.anchorAndRadius({
    super.id,
    super.visible,
    super.theme,
    super.layer,
    super.hitTestMode,
    required GCoordinate anchorCoord,
    required GSize radiusSize,
    required double startTheta,
    required double endTheta,
    bool close = false,
    Alignment alignment =
        Alignment
            .center, // where anchor point located on the bound rect of the circle
  }) : _radiusSize = GValue<GSize?>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _close = GValue<bool>(close),
       super(keyCoordinates: [anchorCoord]) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
    super.render = GArcMarkerRender();
  }
}
