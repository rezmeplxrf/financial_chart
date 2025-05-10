import 'package:example/widgets/toggle_buttons.dart';
import 'package:example/widgets/control_label.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../workshop_state.dart';

class ChartControlView extends StatefulWidget {
  const ChartControlView({super.key});

  @override
  State<ChartControlView> createState() => _ChartControlViewState();
}

class _ChartControlViewState extends State<ChartControlView> {
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
          label: "dataSource",
          description: "change the dataSource.",
        ),
        AppToggleButtons(
          items: const ["AAPL", "GOOGL"],
          selected: state.ticker,
          onSelected: (ticker) {
            if (state.ticker == ticker) return;
            state.changeData();
            state.notify();
          },
        ),
        const ControlLabel(
          label: "hitTestEnable",
          description:
              "enable/disable hitTest. \nmouse hover graphs to see the effect",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart?.hitTestEnable,
          onSelected: (enable) {
            state.chart?.hitTestEnable = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "pointerScrollMode",
          description:
              "change the behavior when scrolling mouse wheel on chart.",
        ),
        AppToggleButtons<GPointerScrollMode>(
          items: GPointerScrollMode.values,
          labelResolver: (m) => m.name,
          selected: state.chart?.pointerScrollMode,
          onSelected: (mode) {
            state.chart?.pointerScrollMode = mode;
            state.notify();
          },
        ),
      ],
    );
  }
}
