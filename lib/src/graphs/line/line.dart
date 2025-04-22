import '../../components/components.dart';
import 'line_render.dart';

/// Line graph
class GGraphLine<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "line";

  /// The key of the series value in the data source.
  final String valueKey;
  GGraphLine({
    super.id,
    super.layer,
    super.visible,
    super.valueViewPortId,
    required this.valueKey,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = render ?? GGraphLineRender();
  }

  @override
  String get type => typeName;
}
