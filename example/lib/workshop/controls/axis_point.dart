import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class PointAxisControlView extends StatefulWidget {
  const PointAxisControlView({super.key});

  @override
  State<PointAxisControlView> createState() => _PointAxisControlViewState();
}

class _PointAxisControlViewState extends State<PointAxisControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "size",
          description:
              "change the size of the axis."
              "\nfor Point axis the size is height of the visible area, for Value axis it is width.",
        ),
        Slider(
          value: chart.panels[0].pointAxes[0].size,
          onChanged: (value) {
            for (var panel in chart.panels) {
              for (var axis in panel.pointAxes) {
                axis.size = value.round().toDouble();
              }
            }
            state.notify();
          },
          onChangeEnd: (value) {},
          min: 0,
          max: 100,
          divisions: 10,
          label: "${chart.panels[0].pointAxes[0].size.round()}",
        ),
        const ControlLabel(
          label: "position",
          description:
              "change the position of the axis. "
              "\nhere it apply to the Point axis on the second panel.",
        ),
        AppToggleButtons<GAxisPosition>(
          items: GAxisPosition.values,
          labelResolver: (m) => m.name,
          selected: chart.panels[1].pointAxes[0].position,
          onSelected: (mode) {
            chart.panels[1].pointAxes[0].position = mode;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "scaleMode",
          description:
              "change the behavior of how to update the bound viewport when scaling the axis area."
              "\ndrag the axis area to see the effect.",
        ),
        AppToggleButtons<GAxisScaleMode>(
          items: GAxisScaleMode.values,
          labelResolver: (m) => m.name,
          selected: chart.panels[0].pointAxes[0].scaleMode,
          onSelected: (mode) {
            for (var panel in chart.panels) {
              for (var axis in panel.pointAxes) {
                axis.scaleMode = mode;
              }
            }
            state.notify();
          },
        ),
      ],
    );
  }
}
