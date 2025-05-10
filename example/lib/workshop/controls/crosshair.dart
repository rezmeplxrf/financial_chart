import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class CrosshairControlView extends StatefulWidget {
  const CrosshairControlView({super.key});

  @override
  State<CrosshairControlView> createState() => _CrosshairControlViewState();
}

class _CrosshairControlViewState extends State<CrosshairControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "snapToPoint",
          description:
              "whether to snap the vertical crosshair line to the nearest point or not.",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.crosshair.snapToPoint,
          onSelected: (enable) {
            state.chart?.crosshair.snapToPoint = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "pointLinesVisible",
          description: "show/hide the vertical crosshair line",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.crosshair.pointLinesVisible,
          onSelected: (enable) {
            state.chart?.crosshair.pointLinesVisible = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "valueLinesVisible",
          description: "show/hide the horizontal crosshair line",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.crosshair.valueLinesVisible,
          onSelected: (enable) {
            state.chart?.crosshair.valueLinesVisible = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "pointAxisLabelsVisible",
          description:
              "show/hide the axis labels for the vertical crosshair line",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.crosshair.pointAxisLabelsVisible,
          onSelected: (enable) {
            state.chart?.crosshair.pointAxisLabelsVisible = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "valueAxisLabelsVisible",
          description:
              "show/hide the axis labels for the horizontal crosshair line",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.crosshair.valueAxisLabelsVisible,
          onSelected: (enable) {
            state.chart?.crosshair.valueAxisLabelsVisible = enable;
            state.notify();
          },
        ),
      ],
    );
  }
}
