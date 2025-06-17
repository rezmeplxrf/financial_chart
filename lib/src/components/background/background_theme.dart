import 'package:financial_chart/src/components/background/background.dart';
import 'package:financial_chart/src/components/component_theme.dart';
import 'package:financial_chart/src/style/paint_style.dart';

/// Theme for the [GBackground] component.
class GBackgroundTheme extends GComponentTheme {

  const GBackgroundTheme({required this.style});
  final PaintStyle style;

  GBackgroundTheme copyWith({PaintStyle? style}) {
    return GBackgroundTheme(style: style ?? this.style);
  }
}
