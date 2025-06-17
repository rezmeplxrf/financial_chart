import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/components/panel/panel.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for [GPanel]
class GPanelTheme extends GComponentTheme {

  const GPanelTheme({required this.style});
  final PaintStyle style;

  GPanelTheme copyWith({PaintStyle? style}) {
    return GPanelTheme(style: style ?? this.style);
  }
}
