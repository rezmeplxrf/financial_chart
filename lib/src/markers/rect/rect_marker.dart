import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/rect/rect_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/size.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/painting.dart';

class GRectMarker extends GOverlayMarker {
  GRectMarker({
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    GSize? cornerRadiusSize,
    super.render = const GRectMarkerRender(),
  }) : _pointRadiusSize = GValue<GSize?>(null),
       _valueRadiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       super(keyCoordinates: [startCoord, endCoord]);

  GRectMarker.anchorAndRadius({
    required GCoordinate anchorCoord,
    required GSize pointRadiusSize,
    required GSize valueRadiusSize,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    GSize? cornerRadiusSize,
    Alignment alignment = Alignment.center,
    super.render = const GRectMarkerRender(),
  }) : _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       _pointRadiusSize = GValue<GSize?>(pointRadiusSize),
       _valueRadiusSize = GValue<GSize?>(valueRadiusSize),
       _alignment = GValue<Alignment>(alignment),
       super(keyCoordinates: [anchorCoord]);
  final GValue<GSize?> _cornerRadiusSize;
  GSize? get cornerRadiusSize => _cornerRadiusSize.value;
  set cornerRadiusSize(GSize? value) => _cornerRadiusSize.value = value;

  final GValue<GSize?> _pointRadiusSize;
  GSize? get pointRadiusSize => _pointRadiusSize.value;
  set pointRadiusSize(GSize? value) => _pointRadiusSize.value = value;

  final GValue<GSize?> _valueRadiusSize;
  GSize? get valueRadiusSize => _valueRadiusSize.value;
  set valueRadiusSize(GSize? value) => _valueRadiusSize.value = value;

  GCoordinate? get anchorCoord =>
      _pointRadiusSize.value == null ? null : keyCoordinates[0];
  GCoordinate? get startCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[0];
  GCoordinate? get endCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[1];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;
}
