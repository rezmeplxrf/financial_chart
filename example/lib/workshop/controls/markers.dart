import 'dart:math';

import 'package:example/widgets/toggle_buttons.dart';
import 'package:example/widgets/control_label.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/indicator_providers.dart';
import '../workshop_state.dart';

class MarkersControlView extends StatefulWidget {
  const MarkersControlView({super.key});

  @override
  State<MarkersControlView> createState() => _MarkersControlViewState();
}

class _MarkersControlViewState extends State<MarkersControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    final graph = chart.panels[0].graphs.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(label: "arc"),
        AppToggleButtonSingle(
          label: "Arc 1",
          selected: (graph.findMarker("arc1") != null),
          onSelected: () {
            if (graph.findMarker("arc1") != null) {
              graph.removeMarkerById("arc1");
            } else {
              graph.addMarker(
                GArcMarker(
                  id: "arc1",
                  centerCoord: GPositionCoord(x: 100, y: 100),
                  borderCoord: GPositionCoord(x: 100, y: 150),
                  startTheta: pi / 2,
                  endTheta: pi * 3 / 2,
                  close: true,
                ),
              );
            }
            state.notify();
          },
        ),
        AppToggleButtonSingle(
          label: "Arc 2",
          selected: (graph.findMarker("arc2") != null),
          onSelected: () {
            final point1 = chart.dataSource.lastPoint - 10;
            final value1 = chart.dataSource.getSeriesValue(
              point: point1,
              key: keyClose,
            );
            if (graph.findMarker("arc2") != null) {
              graph.removeMarkerById("arc2");
            } else {
              graph.addMarker(
                GArcMarker.anchorAndRadius(
                  id: "arc2",
                  anchorCoord: GViewPortCoord(
                    point: point1.toDouble(),
                    value: value1!,
                  ),
                  radiusSize: GSize.valueSize(10),
                  startTheta: -pi * 3 / 4,
                  endTheta: pi * 3 / 4,
                  close: true,
                ),
              );
            }
            state.notify();
          },
        ),
      ],
    );
  }
}
