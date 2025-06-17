import 'package:financial_chart/src/components/marker/overlay_marker.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/markers/callout/callout_marker_render.dart';
import 'package:financial_chart/src/values/coord.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/painting.dart';

class GCalloutMarker extends GOverlayMarker {
  GCalloutMarker({
    required String text,
    required GCoordinate anchorCoord,
    super.id,
    super.visible,
    super.layer,
    super.theme,
    Alignment alignment = Alignment.center,
    double pointerSize = 10,
    double pointerMargin = 10,
    GOverlayMarkerRender render = const GCalloutMarkerRender(),
  }) : _text = GValue<String>(text),
       _alignment = GValue<Alignment>(alignment),
       _pointerSize = GValue<double>(pointerSize),
       _pointerMargin = GValue<double>(pointerMargin),
       super(keyCoordinates: [anchorCoord], render: render);
  final GValue<String> _text;
  String get text => _text.value;
  set text(String value) => _text.value = value;

  GCoordinate get anchorCoord => keyCoordinates[0];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _pointerSize;
  double get pointerSize => _pointerSize.value;
  set pointerSize(double value) => _pointerSize.value = value;

  final GValue<double> _pointerMargin;
  double get pointerMargin => _pointerMargin.value;
  set pointerMargin(double value) => _pointerMargin.value = value;
}
