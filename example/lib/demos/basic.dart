import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../data/sample_data_loader.dart';

class BasicDemoPage extends StatefulWidget {
  const BasicDemoPage({super.key});

  @override
  BasicDemoPageState createState() => BasicDemoPageState();
}

class BasicDemoPageState extends State<BasicDemoPage>
    with TickerProviderStateMixin {
  GChart? chart;
  Offset? pointerDownPosition;

  @override
  void initState() {
    super.initState();
    initializeChart();
  }

  @override
  void dispose() {
    chart?.dispose();
    super.dispose();
  }

  Future<void> initializeChart() async {
    const String ticker = 'AAPL';
    loadYahooFinanceData(ticker).then((response) {
      final dataSource = GDataSource<int, GData<int>>(
        dataList:
            response.candlesData.map((candle) {
              return GData<int>(
                pointValue: candle.date.millisecondsSinceEpoch,
                seriesValues: [
                  candle.open,
                  candle.high,
                  candle.low,
                  candle.close,
                  candle.volume.toDouble(),
                ],
              );
            }).toList(),
        seriesProperties: const [
          GDataSeriesProperty(key: 'open', label: 'Open', precision: 2),
          GDataSeriesProperty(key: 'high', label: 'High', precision: 2),
          GDataSeriesProperty(key: 'low', label: 'Low', precision: 2),
          GDataSeriesProperty(key: 'close', label: 'Close', precision: 2),
          GDataSeriesProperty(key: 'volume', label: 'Volume', precision: 0),
        ],
      );
      setState(() {
        chart = buildChart(dataSource);
      });
    });
  }

  GChart buildChart(GDataSource dataSource) {
    return GChart(
      dataSource: dataSource,
      theme: GThemeDark(),
      panels: [
        GPanel(
          valueViewPorts: [
            GValueViewPort(
              valuePrecision: 2,
              autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                dataKeys: ["high", "low"],
              ),
            ),
          ],
          valueAxes: [GValueAxis()],
          pointAxes: [GPointAxis()],
          graphs: [
            GGraphGrids(),
            GGraphOhlc(ohlcValueKeys: const ["open", "high", "low", "close"]),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Basic demo"), centerTitle: true),
      body: Container(
        child:
            chart == null
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(10),
                  child: GChartWidget(
                    chart: chart!,
                    tickerProvider: this,
                    onPointerDown: (PointerDownEvent details) {
                      pointerDownPosition = details.localPosition;
                    },
                    onPointerUp: (PointerUpEvent details) {
                      final position = details.localPosition;
                      if (pointerDownPosition == null ||
                          (position - pointerDownPosition!).distance > 10) {
                        return;
                      }
                      final hit = chart!.hitTestGraph(position: position);
                      final panel = hit?.$1 ?? chart!.panels[0];
                      if (!panel.graphArea().contains(position)) {
                        return;
                      }
                      final graph = hit?.$2;
                      final valueViewPort = hit?.$2.valueViewPortId ?? "";
                      final point =
                          chart!.pointViewPort
                              .positionToPoint(panel.graphArea(), position.dx)
                              .round();
                      final pointValue = chart!.dataSource.getPointValue(point);
                      var pointValueFormated = "[$point]";
                      if (pointValue != null) {
                        pointValueFormated =
                            "$pointValueFormated ${chart!.dataSource.pointValueFormater.call(point, pointValue)}";
                      }
                      final value = panel
                          .findValueViewPortById(valueViewPort)
                          .positionToValue(panel.graphArea(), position.dy);
                      final props = chart!.dataSource.getSeriesProperty(
                        "close",
                      );
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              "You tapped: \n"
                              "  point: $pointValueFormated\n"
                              "  value: ${value.toStringAsFixed(props.precision)}\n"
                              "${(graph == null) ? "" : "  on graph ${graph.id ?? graph.runtimeType}"}",
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
                    },
                  ),
                ),
      ),
    );
  }
}
