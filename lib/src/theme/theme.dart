import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/background/background_theme.dart';
import 'package:financial_chart/src/components/crosshair/crosshair_theme.dart';
import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel_theme.dart';
import 'package:financial_chart/src/components/splitter/splitter_theme.dart';
import 'package:financial_chart/src/components/tooltip/tooltip_theme.dart';
import 'package:flutter/foundation.dart';

/// Theme container for all chart components.
class GTheme with Diagnosticable {

  const GTheme({
    required this.name,
    required this.backgroundTheme,
    required this.panelTheme,
    required this.pointAxisTheme,
    required this.valueAxisTheme,
    required this.crosshairTheme,
    required this.tooltipTheme,
    required this.splitterTheme,
    required this.graphThemes,
    required this.axisMarkerTheme,
    required this.overlayMarkerTheme,
  });
  final String name;
  final GBackgroundTheme backgroundTheme;
  final GPanelTheme panelTheme;
  final GAxisTheme pointAxisTheme;
  final GAxisTheme valueAxisTheme;
  final GCrosshairTheme crosshairTheme;
  final GTooltipTheme tooltipTheme;
  final GSplitterTheme splitterTheme;
  final GAxisMarkerTheme axisMarkerTheme;
  final GOverlayMarkerTheme overlayMarkerTheme;
  final Map<String, GGraphTheme> graphThemes;

  GTheme extend({
    String? name,
    GBackgroundTheme? backgroundTheme,
    GPanelTheme? panelTheme,
    GAxisTheme? pointAxisTheme,
    GAxisTheme? valueAxisTheme,
    GCrosshairTheme? crosshairTheme,
    GTooltipTheme? tooltipTheme,
    GSplitterTheme? splitterTheme,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    Map<String, GGraphTheme>? graphThemes,
  }) {
    return GTheme(
      name: name ?? this.name,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      panelTheme: panelTheme ?? this.panelTheme,
      pointAxisTheme: pointAxisTheme ?? this.pointAxisTheme,
      valueAxisTheme: valueAxisTheme ?? this.valueAxisTheme,
      crosshairTheme: crosshairTheme ?? this.crosshairTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
      splitterTheme: splitterTheme ?? this.splitterTheme,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      graphThemes: this.graphThemes..addAll(graphThemes ?? {}),
    );
  }

  GGraphTheme? graphTheme(String graphType) {
    return graphThemes[graphType];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', name));
  }
}
