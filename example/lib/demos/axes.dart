import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoAxesPage extends DemoBasePage {
  const DemoAxesPage({super.key}) : super(title: 'Axes');

  @override
  DemoBasePageState createState() => DemoAxesPageState();
}

class DemoAxesPageState extends DemoBasePageState {
  DemoAxesPageState();

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
          ),
          GGraphLine(id: "line", valueViewPortId: "price", valueKey: keySMA),
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
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GPointAxis.position",
          description: "Change the position of the Point axis (X axis)",
          child: AppPopupMenu<GAxisPosition>(
            items: GAxisPosition.values,
            onSelected: (GAxisPosition selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.position = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].position,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GValueAxis.position",
          description: "Change the position of the Value axis (Y axis)",
          child: AppPopupMenu<GAxisPosition>(
            items: GAxisPosition.values,
            onSelected: (GAxisPosition selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.position = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].position,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GPointAxis.scaleMode",
          description:
              "Change the behavior when dragging the Point axis (X axis). "
              "\ndrag the axis to change the viewport manually. "
              "\ndouble tap the axis to reset to auto scale after changed viewport manually by dragging.",
          child: AppPopupMenu<GAxisScaleMode>(
            items: GAxisScaleMode.values,
            onSelected: (GAxisScaleMode selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.scaleMode = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].scaleMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GValueAxis.scaleMode",
          description:
              "Change the behavior when dragging the Value axis (Y axis). "
              "\ndrag the axis to change the viewport manually. "
              "\ndouble tap the axis to reset to auto scale after changed viewport manually by dragging.",
          child: AppPopupMenu<GAxisScaleMode>(
            items: GAxisScaleMode.values,
            onSelected: (GAxisScaleMode selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.scaleMode = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].scaleMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GPointAxis.size",
          description: "Change the size (height) of the Point axis (X axis)",
          child: AppPopupMenu<double>(
            items: const [30, 40],
            onSelected: (double selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.size = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].size,
            labelResolver: (item) => item.toStringAsFixed(0),
          ),
        ),
        AppLabelWidget(
          label: "GValueAxis.size",
          description: "Change the size (width) of the Value axis (Y axis)",
          child: AppPopupMenu<double>(
            items: const [60, 80],
            onSelected: (double selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.size = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].size,
            labelResolver: (item) => item.toStringAsFixed(0),
          ),
        ),
        AppLabelWidget(
          label: "GPointAxis.resizeMode",
          description:
              "Change the behavior of how to update the Point viewport (X direction) range when resizing the chart. "
              "\nResize the window to see how it works.",
          child: AppPopupMenu<GViewPortResizeMode>(
            items: GViewPortResizeMode.values,
            onSelected: (GViewPortResizeMode selected) {
              chart!.pointViewPort.resizeMode = selected;
              repaintChart();
            },
            selected: chart!.pointViewPort.resizeMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GValueAxis.resizeMode",
          description:
              "Change the behavior of how to update the Value viewport (Y direction) range when resizing the chart. "
              "\nResize the window to see how it works.",
          child: AppPopupMenu<GViewPortResizeMode>(
            items: GViewPortResizeMode.values,
            onSelected: (GViewPortResizeMode selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueViewPort viewPort in panel.valueViewPorts) {
                  viewPort.resizeMode = selected;
                  if (selected != GViewPortResizeMode.keepRange) {
                    viewPort.autoScaleFlg = false;
                  }
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueViewPorts[0].resizeMode,
            labelResolver: (item) => item.name,
          ),
        ),
      ],
    );
  }
}
