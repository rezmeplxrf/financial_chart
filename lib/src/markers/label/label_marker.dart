import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/markers/label/label_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/painting.dart';

class GLabelMarker extends GOverlayMarker {
  GLabelMarker({
    required String text,
    required GCoordinate anchorCoord,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    Alignment alignment = Alignment.center,
    super.render = const GLabelMarkerRender(),
  }) : _text = GValue<String>(text),
       _alignment = GValue<Alignment>(alignment),
       super(keyCoordinates: [anchorCoord]);
  final GValue<String> _text;
  String get text => _text.value;
  set text(String value) => _text.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final double rotationTheta = 45;
  final GCoordinate rotationCenter = GPositionCoord.rational(x: 0.5, y: 0.5);
}
