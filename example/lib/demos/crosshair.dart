import '../../data/indicator_providers.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoCrosshairPage extends DemoBasePage {
  const DemoCrosshairPage({super.key}) : super(title: 'Crosshair');

  @override
  DemoBasePageState createState() => DemoCrosshairPageState();
}

class DemoCrosshairPageState extends DemoBasePageState {
  DemoCrosshairPageState();

  Offset? pointerDownPosition;

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
    List<GPanel> panels = [
      GPanel(
        valueViewPorts: [
          GValueViewPort(
            id: "price",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyHigh, keyLow],
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
          ),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            valueViewPortId: "price",
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
            crosshairHighlightValueKeys: [keyOpen, keyClose],
          ),
          GGraphLine(
            id: "line",
            valueViewPortId: "price",
            valueKey: keySMA,
            crosshairHighlightValueKeys: [keySMA],
          ),
        ],
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(),
      panels: panels,
      theme: chartTheme,
    );
  }

  @override
  GChartWidget buildChartWidget(GChart chart, TickerProvider tickerProvider) {
    return GChartWidget(
      chart: chart,
      tickerProvider: tickerProvider,
      onPointerDown: (PointerDownEvent details) {
        pointerDownPosition = details.localPosition;
      },
      onPointerUp: (PointerUpEvent details) {
        final position = details.localPosition;
        if (pointerDownPosition == null ||
            (position - pointerDownPosition!).distance > 10) {
          return;
        }
        for (final panel in chart.panels) {
          final coord = panel.positionToViewPortCoord(
            position: position,
            pointViewPort: chart.pointViewPort,
            valueViewPortId: "price",
          );
          if (coord != null) {
            final point = coord.point.round();
            final pointValue = chart.dataSource.pointValueFormater.call(
              point,
              chart.dataSource.getPointValue(point),
            );
            final value = coord.value;
            final props = chart.dataSource.getSeriesProperty("close");
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                    "You tapped: \n"
                    "  point: $pointValue (#$point)\n"
                    "  value: ${value.toStringAsFixed(props.precision)}\n",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("ok"),
                    ),
                  ],
                );
              },
            );
            break;
          }
        }
      },
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GCrosshair.snapToPoint",
          description:
              "Snap the vertical line to the nearest point on Point axis or not when moving the crosshair.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.snapToPoint = selected;
              repaintChart();
            },
            selected: chart!.crosshair.snapToPoint,
          ),
        ),
        AppLabelWidget(
          label: "GCrosshair.pointLinesVisible",
          description: "Show/hide the vertical line.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.pointLinesVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.pointLinesVisible,
          ),
        ),
        AppLabelWidget(
          label: "GCrosshair.valueLinesVisible",
          description: "Show/hide the horizontal line.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.valueLinesVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.valueLinesVisible,
          ),
        ),
        AppLabelWidget(
          label: "GCrosshair.pointAxisLabelsVisible",
          description: "Show/hide the label on point axis (X axis).",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.pointAxisLabelsVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.pointAxisLabelsVisible,
          ),
        ),
        AppLabelWidget(
          label: "GCrosshair.valueAxisLabelsVisible",
          description: "Show/hide the label on value axis (Y axis).",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.valueAxisLabelsVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.valueAxisLabelsVisible,
          ),
        ),
      ],
    );
  }
}
