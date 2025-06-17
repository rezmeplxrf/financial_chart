import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/marker/marker.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/values/coord.dart';

/// Base class for Markers overlay on anther component (usually a axis or a graph).
abstract class GOverlayMarker extends GMarker {
  GOverlayMarker({
    super.id,
    super.visible,
    super.layer,
    GOverlayMarkerTheme? theme,
    GOverlayMarkerRender? render,
    this.keyCoordinates = const [],
  }) : super(theme: theme, render: render);

  /// Key points decides the shape of the marker.
  final List<GCoordinate> keyCoordinates;

  /// Control points allow to adjust the shape of the marker interactively. (not implemented yet)
  List<GCoordinate> controlCoordinates = [];

  @override
  GOverlayMarkerTheme? get theme => super.theme as GOverlayMarkerTheme?;

  @override
  set theme(GComponentTheme? value) {
    if (value != null && value is! GOverlayMarkerTheme) {
      throw ArgumentError('theme must be a GOverlayMarkerTheme');
    }
    super.theme = value;
  }

  @override
  GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme> getRender() {
    return super.getRender()
        as GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme>;
  }
}
