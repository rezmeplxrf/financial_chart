import '../../values/coord.dart';
import '../component_theme.dart';
import 'marker.dart';
import 'overlay_marker_render.dart';
import 'overlay_marker_theme.dart';

/// Base class for Markers overlay on anther component (usually a axis or a graph).
abstract class GOverlayMarker extends GMarker {
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

  GOverlayMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    GOverlayMarkerTheme? theme,
    GOverlayMarkerRender? render,
    this.keyCoordinates = const [],
  }) : super(theme: theme, render: render);

  @override
  GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme> getRender() {
    return super.getRender()
        as GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme>;
  }
}
