import 'package:financial_chart/src/components/axis/axis_theme.dart';
import 'package:financial_chart/src/components/background/background_theme.dart';
import 'package:financial_chart/src/components/crosshair/crosshair_theme.dart';
import 'package:financial_chart/src/components/graph/graph.dart';
import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/components/marker/axis_marker_theme.dart';
import 'package:financial_chart/src/components/marker/overlay_marker_theme.dart';
import 'package:financial_chart/src/components/panel/panel_theme.dart';
import 'package:financial_chart/src/components/splitter/splitter_theme.dart';
import 'package:financial_chart/src/components/tooltip/tooltip_theme.dart';
import 'package:financial_chart/src/graphs/area/area.dart';
import 'package:financial_chart/src/graphs/area/area_theme.dart';
import 'package:financial_chart/src/graphs/bar/bar.dart';
import 'package:financial_chart/src/graphs/bar/bar_theme.dart';
import 'package:financial_chart/src/graphs/grids/grids.dart';
import 'package:financial_chart/src/graphs/grids/grids_theme.dart';
import 'package:financial_chart/src/graphs/line/line.dart';
import 'package:financial_chart/src/graphs/line/line_theme.dart';
import 'package:financial_chart/src/graphs/ohlc/ohlc.dart';
import 'package:financial_chart/src/graphs/ohlc/ohlc_theme.dart';
import 'package:financial_chart/src/style/label_style.dart';
import 'package:financial_chart/src/style/paint_style.dart';
import 'package:financial_chart/src/theme/theme.dart';
import 'package:flutter/material.dart';

/// Preset dark theme.
class GThemeDark extends GTheme {
  GThemeDark()
    : super(
        name: themeName,
        backgroundTheme: backgroundThemeDefault,
        panelTheme: panelThemeDefault,
        pointAxisTheme: pointAxisThemeDefault,
        valueAxisTheme: valueAxisThemeDefault,
        crosshairTheme: crosshairThemeDefault,
        tooltipTheme: tooltipThemeDefault,
        splitterTheme: splitterThemeDefault,
        graphThemes: {
          GGraph.typeName: GGraphTheme(
            axisMarkerTheme: axisMarkerThemeDefault,
            overlayMarkerTheme: overlayMarkerThemeDefault,
          ),
          GGraphGrids.typeName: gridsGraphTheme,
          GGraphOhlc.typeName: ohlcGraphTheme,
          GGraphLine.typeName: lineGraphTheme,
          GGraphBar.typeName: barGraphTheme,
          GGraphArea.typeName: areaGraphTheme,
        },
        axisMarkerTheme: axisMarkerThemeDefault,
        overlayMarkerTheme: overlayMarkerThemeDefault,
      );
  static const String themeName = 'dark';

  static final GBackgroundTheme backgroundThemeDefault = GBackgroundTheme(
    style: PaintStyle(),
  );

  static final GPanelTheme panelThemeDefault = GPanelTheme(
    style: PaintStyle(
      fillColor: const Color(0xFF0F0F0F),
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 0.5,
    ),
  );

  static final GAxisTheme pointAxisThemeDefault = GAxisTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFCCCCCC),
      strokeWidth: 1,
    ),
    tickerStyle: PaintStyle(
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 1,
    ),
    selectionStyle: PaintStyle(
      fillColor: const Color(0x55BBBBFF),
      strokeColor: const Color(0xAABBBBFF),
      strokeWidth: 1,
    ),
    labelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10),
        backgroundStyle: PaintStyle(),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GAxisTheme valueAxisThemeDefault = GAxisTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFCCCCCC),
      strokeWidth: 1,
    ),
    tickerStyle: PaintStyle(
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 1,
    ),
    selectionStyle: PaintStyle(
      fillColor: const Color(0x55BBBBFF),
      strokeColor: const Color(0xAABBBBFF),
    ),
    labelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10),
        backgroundStyle: PaintStyle(),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GCrosshairTheme crosshairThemeDefault = GCrosshairTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFA0A0A0),
      strokeWidth: 1,
      dash: const [5, 5],
    ),
    pointLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFF222222), fontSize: 10),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFFDDDDDD)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
    valueLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFF222222), fontSize: 10),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFFDDDDDD)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GTooltipTheme tooltipThemeDefault = GTooltipTheme(
    frameStyle: PaintStyle(
      fillColor: Colors.white.withAlpha(180),
      strokeColor: Colors.grey,
      strokeWidth: 1,
    ),
    pointStyle: LabelStyle(
      textStyle: const TextStyle(color: Colors.black, fontSize: 12),
    ),
    labelStyle: LabelStyle(
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    valueStyle: LabelStyle(
      textStyle: const TextStyle(color: Colors.black, fontSize: 12),
    ),
    pointHighlightStyle: PaintStyle(fillColor: Colors.blue.withAlpha(120)),
    valueHighlightStyle: PaintStyle(strokeColor: Colors.blue, strokeWidth: 0.5),
  );

  static final GSplitterTheme splitterThemeDefault = GSplitterTheme(
    lineStyle: PaintStyle(
      strokeColor: Colors.grey.withAlpha(100),
      strokeWidth: 4,
    ),
    handleStyle: PaintStyle(fillColor: Colors.white, strokeColor: Colors.grey),
    handleLineStyle: PaintStyle(strokeColor: Colors.black, strokeWidth: 0.5),
    handleWidth: 80,
  );

  static final GGraphOhlcTheme ohlcGraphTheme = GGraphOhlcTheme(
    barStylePlus: PaintStyle(
      fillColor: Colors.teal,
      strokeWidth: 1,
      strokeColor: Colors.teal,
    ),
    barStyleMinus: PaintStyle(
      fillColor: Colors.redAccent,
      strokeWidth: 1,
      strokeColor: Colors.redAccent,
    ),
    axisMarkerTheme: axisMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphLineTheme lineGraphTheme = GGraphLineTheme(
    lineStyle: PaintStyle(strokeColor: Colors.blue, strokeWidth: 1),
    pointStyle: PaintStyle(fillColor: Colors.blue),
    axisMarkerTheme: axisMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphGridsTheme gridsGraphTheme = GGraphGridsTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFF333333),
      strokeWidth: 0.5,
    ),
    selectionStyle: PaintStyle(
      fillColor: const Color(0x33BBBBFF),
      strokeColor: const Color(0xAABBBBFF),
    ),
    axisMarkerTheme: axisMarkerThemeDefault,
    overlayMarkerTheme: overlayMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphBarTheme barGraphTheme = GGraphBarTheme(
    barStyleAboveBase: PaintStyle(fillColor: Colors.teal.withAlpha(150)),
    barStyleBelowBase: PaintStyle(fillColor: Colors.red.withAlpha(150)),
    axisMarkerTheme: axisMarkerThemeDefault,
    overlayMarkerTheme: overlayMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphAreaTheme areaGraphTheme = GGraphAreaTheme(
    styleAboveBase: PaintStyle(
      strokeColor: Colors.blue,
      strokeWidth: 1,
      fillColor: Colors.blue.withAlpha(100),
    ),
    styleBelowBase: PaintStyle(
      strokeColor: Colors.red,
      strokeWidth: 1,
      fillColor: Colors.red.withAlpha(100),
    ),
    axisMarkerTheme: axisMarkerThemeDefault,
    overlayMarkerTheme: overlayMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GAxisMarkerTheme axisMarkerThemeDefault = GAxisMarkerTheme(
    labelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFEEEEEE), fontSize: 10),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFF0000EE)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
    rangeStyle: PaintStyle(fillColor: Colors.blue.withAlpha(150)),
  );

  static final GOverlayMarkerTheme overlayMarkerThemeDefault =
      GOverlayMarkerTheme(
        markerStyle: PaintStyle(
          fillColor: Colors.blueAccent.withAlpha(120),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
        controlPointsStyle: PaintStyle(
          fillColor: Colors.white,
          strokeColor: Colors.blueAccent,
          strokeWidth: 2,
        ),
        labelStyle: LabelStyle(
          textStyle: const TextStyle(color: Colors.black, fontSize: 10),
          backgroundStyle: PaintStyle(
            fillColor: Colors.white,
            strokeColor: Colors.black,
            strokeWidth: 1,
          ),
          backgroundPadding: const EdgeInsets.all(5),
          backgroundCornerRadius: 5,
        ),
      );

  static final GGraphHighlightMarkerTheme graphHighlightMarkThemeDefault =
      GGraphHighlightMarkerTheme(
        style: PaintStyle(
          strokeColor: Colors.black54,
          strokeWidth: 1,
          fillColor: Colors.white,
        ),
      );
}
