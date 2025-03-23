import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../data/sample_data.dart';
import '../widgets/label_widget.dart';
import '../widgets/popup_menu.dart';
import 'demo.dart';

class DemoLiveUpdatePage extends DemoBasePage {
  const DemoLiveUpdatePage({super.key}) : super(title: 'Live update');

  @override
  DemoLiveUpdatePageState createState() => DemoLiveUpdatePageState();
}

class DemoLiveUpdatePageState extends DemoBasePageState {
  int updateIntervalMillis = 200;
  Timer? timer;
  GDataSource? dataSource;
  GAxisMarker? axisMarker;
  GLineMarker? lineMarker;

  DemoLiveUpdatePageState();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(milliseconds: updateIntervalMillis),
      timerHandler,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void timerHandler(Timer t) {
    if (chart == null) {
      return;
    }
    final dataSource = chart!.dataSource as GDataSource<int, GData<int>>;
    if (dataSource.length == 0) {
      return;
    }
    var lastData = dataSource.dataList.last;
    final latestPrice =
        lastData.seriesValues[3] +
        (Random().nextInt(100) - 50) * 0.02; // random price change
    if (t.tick % 10 == 0) {
      // append new data every 10 ticks
      dataSource.dataList.add(
        GData<int>(
          pointValue: lastData.pointValue + 86400000,
          seriesValues: [
            ...[latestPrice, latestPrice, latestPrice, latestPrice], // ohlc
            ...lastData.seriesValues.sublist(
              4,
            ), // here we just copy the rest, in real case we need to set correct volume and indicator values
          ],
        ),
      );
    }
    // update last data high, low, close
    lastData = dataSource.dataList.last;
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyClose)] =
        latestPrice; // close
    final ohlcValues = [
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyOpen)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyHigh)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyLow)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyClose)],
    ];
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyHigh)] = ohlcValues
        .reduce(max); // high
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyLow)] = ohlcValues
        .reduce(min); // low
    // update axis marker and line marker
    lineMarker!.keyCoordinates[0] = (lineMarker!.keyCoordinates[0]
            as GCustomCoord)
        .copyWith(y: latestPrice);
    lineMarker!.keyCoordinates[1] = (lineMarker!.keyCoordinates[1]
            as GCustomCoord)
        .copyWith(y: latestPrice);
    axisMarker!.values[0] = latestPrice;
    axisMarker!.points[0] = dataSource.lastPoint;
    // redraw chart
    final autoScalePointViewPort =
        (chart!.pointViewPort.endPoint - dataSource.lastPoint - 10)
            .round()
            .abs() <
        2;
    chart?.autoScaleViewports(
      resetPointViewPort: autoScalePointViewPort,
      resetValueViewPort: true,
    );
    repaintChart();
  }

  @override
  int get simulateDataLatencyMillis => 0;

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
    axisMarker = GAxisMarker(
      id: "axis-marker-latest",
      points: [dataSource.lastPoint],
      values: [
        dataSource.getSeriesValue(point: dataSource.lastPoint, key: keyClose)!,
      ],
    );
    if (dataSource.isNotEmpty) {
      lineMarker = GLineMarker(
        id: "line-marker-latest",
        coordinates: [
          GCustomCoord(
            x: 0.0,
            y:
                dataSource.getSeriesValue(
                  point: dataSource.lastPoint,
                  key: keyClose,
                )!,
            coordinateConvertor: kCoordinateConvertorXPositionYValue,
          ),
          GCustomCoord(
            x: 1.0,
            y:
                dataSource.getSeriesValue(
                  point: dataSource.lastPoint,
                  key: keyClose,
                )!,
            coordinateConvertor: kCoordinateConvertorXPositionYValue,
          ),
        ],
        theme: GGraphMarkerTheme(
          markerStyle: PaintStyle(strokeColor: Colors.orange),
        ),
      );
    }
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
            visible: true,
            valueViewPortId: "price",
            drawAsCandle: true,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
            graphMarkers: [if (lineMarker != null) lineMarker!],
            axisMarkers: [axisMarker!],
          ),
          GGraphLine(
            id: "line",
            visible: false, // live update not implemented yet so just hide
            valueViewPortId: "price",
            valueKey: keySMA,
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.none,
          dataKeys: const [
            keyOpen,
            keyHigh,
            keyLow,
            keyClose,
            keyVolume,
            keySMA,
            keyIchimokuSpanA,
            keyIchimokuSpanB,
          ],
          followValueKey: keyClose,
          followValueViewPortId: "price",
          pointLineHighlightVisible: false,
          valueLineHighlightVisible: false,
        ),
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(
        autoScaleStrategy: const GPointViewPortAutoScaleStrategyLatest(
          endSpacingPoints: 10,
        ),
      ),
      panels: panels,
      theme: chartTheme,
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "Markers visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (var marker
                  in chart!.panels[0].findGraphById("ohlc")!.graphMarkers) {
                marker.visible = selected;
              }
              for (var marker
                  in chart!.panels[0].findGraphById("ohlc")!.axisMarkers) {
                marker.visible = selected;
              }
              repaintChart();
            },
            selected:
                chart!.panels[0].findGraphById("ohlc")!.graphMarkers[0].visible,
          ),
        ),
        AppLabelWidget(
          label: "Live update interval",
          child: AppPopupMenu<int>(
            items: const [0, 100, 200, 500, 1000],
            onSelected: (int selected) {
              setState(() {
                updateIntervalMillis = selected;
              });
              if (selected > 0) {
                timer?.cancel();
                timer = Timer.periodic(
                  Duration(milliseconds: selected),
                  timerHandler,
                );
              } else {
                timer?.cancel();
              }
            },
            selected: updateIntervalMillis,
            labelResolver: (item) => item == 0 ? "Off" : "$item ms",
          ),
        ),
      ],
    );
  }
}
