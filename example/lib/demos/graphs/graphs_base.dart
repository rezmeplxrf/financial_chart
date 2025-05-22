import '../../data/indicator_providers.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../widgets/label_widget.dart';
import '../demo.dart';

class DemoGraphBasePage extends DemoBasePage {
  const DemoGraphBasePage({super.key, required super.title});

  @override
  DemoGraphBasePageState createState() => DemoGraphBasePageState();
}

class DemoGraphBasePageState extends DemoBasePageState {
  final Stopwatch _stopwatch = Stopwatch();
  final ValueNotifier<double> _renderTime = ValueNotifier(0);

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
              dataKeys: [
                keyHigh,
                keyLow,
                keySMA,
                keyIchimokuSpanA,
                keyIchimokuSpanB,
              ],
            ),
          ),
          GValueViewPort(
            id: "volume",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ['volume'],
              marginStart: GSize.viewSize(0),
              marginEnd: GSize.viewHeightRatio(0.1),
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(
            viewPortId: 'volume',
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.none,
          ),
          GValueAxis(
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
          ),
        ],
        pointAxes: [
          GPointAxis(position: GAxisPosition.start),
          GPointAxis(position: GAxisPosition.end),
        ],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          getGraph(),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          dataKeys: tooltipDataKeys(),
          followValueKey: tooltipFollowValueKey(),
          followValueViewPortId: tooltipFollowValueViewPortId(),
        ),
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(),
      panels: panels,
      theme: chartTheme,
      preRender: (_, _, _) {
        _stopwatch
          ..reset()
          ..start();
      },
      postRender: (_, _, _) {
        _stopwatch.stop();
        WidgetsBinding.instance.addPostFrameCallback((f) {
          _renderTime.value = _stopwatch.elapsedMicroseconds / 1000.0;
        });
      },
    );
  }

  GGraph getGraph() => GGraph();
  GGraphTheme getGraphTheme() => const GGraphTheme();
  List<String> tooltipDataKeys() => [];
  String tooltipFollowValueKey() => tooltipDataKeys().first;
  String tooltipFollowValueViewPortId() => "price";
  List<Widget> buildControlActions(BuildContext context) => [];

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLabelWidget(
          label: "Render time",
          child: ValueListenableBuilder<double>(
            valueListenable: _renderTime,
            builder: (context, value, child) {
              return Text(
                "${value.toStringAsFixed(2)} ms",
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GGraph.visible",
          description: "Show/hide the graph.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].graphs.last.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].graphs.last.visible,
          ),
        ),
        AppLabelWidget(
          label: "GGraph.theme",
          description: "Change theme of the graph.",
          child: AppPopupMenu<String>(
            items: const ["default", "custom"],
            onSelected: (String selected) {
              if (selected == "default") {
                getGraph().theme = null;
              } else {
                getGraph().theme = getGraphTheme();
              }
              repaintChart();
            },
            selected: getGraph().theme == null ? "default" : "custom",
            labelResolver: (item) => item,
          ),
        ),
        ...buildControlActions(context),
      ],
    );
  }
}
