import '../../values/value.dart';
import '../component.dart';
import 'splitter_render.dart';
import 'splitter_theme.dart';

/// Splitter (resize handle) component.
class GSplitter extends GComponent {
  final GValue<int?> _resizingPanelIndex = GValue(null);
  int? get resizingPanelIndex => _resizingPanelIndex.value;
  set resizingPanelIndex(int? value) => _resizingPanelIndex.value = value;

  GSplitter({GSplitterTheme? theme, GSplitterRender? render})
    : super(render: render ?? const GSplitterRender(), theme: theme);
}
