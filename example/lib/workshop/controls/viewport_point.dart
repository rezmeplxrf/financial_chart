import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class PointViewPortControlView extends StatefulWidget {
  const PointViewPortControlView({super.key});

  @override
  State<PointViewPortControlView> createState() =>
      _PointViewPortControlViewState();
}

class _PointViewPortControlViewState extends State<PointViewPortControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    final pointViewPort = chart.pointViewPort;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "range",
          description:
              "update or reset the visible range of Point viewport (on x direction)",
        ),
        AppToggleButtons<String>(
          items: const ["Zoom in"],
          minWidth: 160,
          onSelected: (btn) {
            pointViewPort.zoom(chart.panels[0].graphArea(), 0.7);
          },
        ),
        AppToggleButtons<String>(
          items: const ["Zoom out"],
          minWidth: 160,
          onSelected: (btn) {
            pointViewPort.zoom(chart.panels[0].graphArea(), 1.5);
          },
        ),
        AppToggleButtons<String>(
          items: const ["Reset"],
          minWidth: 160,
          onSelected: (btn) {
            pointViewPort.autoScaleFlg = true;
            chart.autoScaleViewports(resetPointViewPort: true);
            state.notify();
          },
        ),
        const ControlLabel(
          label: "animationMilliseconds",
          description:
              "change scaling animation duration (in milliseconds)"
              "\nclick the 'Zoom in' / 'Zoom out' button to see the animation effect.",
        ),
        Slider(
          value: pointViewPort.animationMilliseconds.toDouble(),
          onChanged: (value) {
            pointViewPort.animationMilliseconds = value.toInt();
            state.notify();
          },
          onChangeEnd: (value) {},
          min: 0,
          max: 1000,
          divisions: 10,
          label: "${pointViewPort.animationMilliseconds} ms",
        ),
        const ControlLabel(
          label: "resizeMode",
          description:
              "change the behavior how to update the point view port range when resizing the view size."
              "\nresize the window width to see the effect (on x direction).",
        ),
        AppToggleButtons<GViewPortResizeMode>(
          items: GViewPortResizeMode.values,
          labelResolver: (m) => m.name,
          selected: pointViewPort.resizeMode,
          onSelected: (mode) {
            pointViewPort.resizeMode = mode;
            state.notify();
          },
        ),
      ],
    );
  }
}
