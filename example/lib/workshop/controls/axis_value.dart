import 'package:example/widgets/toggle_buttons.dart';
import 'package:example/widgets/control_label.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../workshop_state.dart';

class ValueAxisControlView extends StatefulWidget {
  const ValueAxisControlView({super.key});

  @override
  State<ValueAxisControlView> createState() => _ValueAxisControlViewState();
}

class _ValueAxisControlViewState extends State<ValueAxisControlView> {
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
          value: chart.panels[0].valueAxes[0].size,
          onChanged: (value) {
            for (var panel in chart.panels) {
              for (var axis in panel.valueAxes) {
                axis.size = value.round().toDouble();
              }
            }
            state.notify();
          },
          onChangeEnd: (value) {},
          min: 0,
          max: 100,
          divisions: 10,
          label: "${chart.panels[0].valueAxes[0].size.round()}",
        ),
        const ControlLabel(
          label: "position",
          description:
              "change the position of the axis. "
              "\nhere it apply to the secondary Value axes.",
        ),
        AppToggleButtons<GAxisPosition>(
          items: GAxisPosition.values,
          labelResolver: (m) => m.name,
          selected: chart.panels[0].valueAxes[1].position,
          onSelected: (mode) {
            for (var panel in chart.panels) {
              panel.valueAxes[1].position = mode;
            }
            state.notify();
          },
        ),
        const ControlLabel(
          label: "scaleMode",
          description:
              "change the behavior of how to update the bound viewport when scaling the axis area."
              "\nhere it apply to the secondary Value axes."
              "\ndrag the axis area to see the effect.",
        ),
        AppToggleButtons<GAxisScaleMode>(
          items: GAxisScaleMode.values,
          labelResolver: (m) => m.name,
          selected: chart.panels[0].valueAxes[1].scaleMode,
          onSelected: (mode) {
            for (var panel in chart.panels) {
              panel.valueAxes[1].scaleMode = mode;
            }
            state.notify();
          },
        ),
      ],
    );
  }
}
