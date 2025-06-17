import 'package:financial_chart/src/components/component.dart';
import 'package:financial_chart/src/components/splitter/splitter_render.dart';
import 'package:financial_chart/src/components/splitter/splitter_theme.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/foundation.dart';

/// Splitter (resize handle) component.
class GSplitter extends GComponent {

  GSplitter({GSplitterTheme? theme, GSplitterRender? render})
    : super(render: render ?? const GSplitterRender(), theme: theme);
  final GValue<int?> _resizingPanelIndex = GValue(null);
  int? get resizingPanelIndex => _resizingPanelIndex.value;
  set resizingPanelIndex(int? value) => _resizingPanelIndex.value = value;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<int?>('resizingPanelIndex', resizingPanelIndex),
    );
  }
}
