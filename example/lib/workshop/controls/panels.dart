import 'package:example/data/sample_data.dart';
import 'package:example/widgets/toggle_buttons.dart';
import 'package:example/widgets/control_label.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../workshop_state.dart';

class PanelControlView extends StatefulWidget {
  const PanelControlView({super.key});

  @override
  State<PanelControlView> createState() => _PanelControlViewState();
}

class _PanelControlViewState extends State<PanelControlView> {
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
          label: "visible",
          description:
              "change the visibility of the panel."
              "\nhere it apply to second panel only.",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[1].visible,
          onSelected: (enable) {
            state.chart?.panels[1].visible = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "resizable",
          description:
              "allow resizing the panel by dragging the splitter between two panels or not."
              "\nonly when two adjacent panels are both resizable (and visible), the splitter can be dragged.",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[0].resizable,
          onSelected: (enable) {
            state.chart?.panels[0].resizable = enable;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "height",
          description:
              "change the heightWeight."
              "\nhere we set both panels to 1, so they will be equal height.",
        ),
        AppToggleButtons<String>(
          items: const ["Set Equal Height"],
          minWidth: 160,
          onSelected: (btn) {
            state.chart!.panels[0].heightWeight = 1;
            state.chart!.panels[1].heightWeight = 1;
            state.chart!.layout(state.chart!.area);
            state.notify();
          },
        ),
        const ControlLabel(
          label: "graphPanMode",
          description:
              "change the behavior when panning the graph area."
              "\nwhen set 'none' no panning allowed, "
              "\nwhen set 'auto' panning is allowed in both x and y direction, but y direction will be locked when value viewport's autoScaleFlg is true."
              "\nunlock the autoScaleFlg by scaling the y axis manually to turn on panning in y direction.",
        ),
        AppToggleButtons<GGraphPanMode>(
          items: GGraphPanMode.values,
          labelResolver: (m) => m.name,
          selected: state.chart?.panels[0].graphPanMode,
          onSelected: (mode) {
            state.chart?.panels.forEach((panel) {
              panel.graphPanMode = mode;
            });
            state.notify();
          },
        ),
        const ControlLabel(
          label: "momentumScrollSpeed",
          description:
              "change the speed of the momentum scroll (along X direction) after dragging and releasing the graph area."
              "\nit should be a value between 0 and 1, when set to 0 it will be disabled.",
        ),
        Slider(
          value: state.chart!.panels[0].momentumScrollSpeed,
          onChanged: (value) {
            state.chart?.panels.forEach((panel) {
              panel.momentumScrollSpeed = value;
            });
            state.notify();
          },
          onChangeEnd: (value) {},
          min: 0,
          max: 1.0,
          divisions: 10,
          label: "${state.chart!.panels[0].momentumScrollSpeed}",
        ),
        const ControlLabel(
          label: "onTapGraphArea",
          description:
              "trigger a callback when tap the graph area. "
              "\nhere it apply to the top panel."
              "\nNOTICE that when onDoubleTapGraphArea also being set there is a delay cause by distinguishing single from double taps.",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[0].onTapGraphArea != null,
          onSelected: (enable) {
            if (enable) {
              state.chart?.panels[0].onTapGraphArea = (position) {
                _notifyTap("Tap", context, state.chart, position);
              };
            } else {
              state.chart?.panels[0].onTapGraphArea = null;
            }
            state.notify();
          },
        ),
        const ControlLabel(
          label: "onDoubleTapGraphArea",
          description:
              "trigger a callback when double tap the graph area. "
              "\nhere it apply to the top panel.",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[0].onDoubleTapGraphArea != null,
          onSelected: (enable) {
            if (enable) {
              state.chart?.panels[0].onDoubleTapGraphArea = (position) {
                _notifyTap("DoubleTap", context, state.chart, position);
              };
            } else {
              state.chart?.panels[0].onDoubleTapGraphArea = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  void _notifyTap(
    String prefix,
    BuildContext context,
    GChart? chart,
    Offset position,
  ) {
    if (chart == null) return;
    final panel = chart.panels[0];
    final coord = panel.positionToViewPortCoord(
      position: position,
      pointViewPort: chart.pointViewPort,
      valueViewPortId: kVpPrice,
    );
    if (coord != null) {
      final point = coord.point.round();
      final pointValue = chart.dataSource.pointValueFormater.call(
        point,
        chart.dataSource.getPointValue(point),
      );
      final value = coord.value;
      final props = chart.dataSource.getSeriesProperty(keyClose);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(prefix),
            content: Text(
              "point: $pointValue (#$point)\n"
              "value: ${value.toStringAsFixed(props.precision)}\n",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
