import 'package:example/workshop/controls/axis_point.dart';
import 'package:example/workshop/controls/axis_value.dart';
import 'package:flutter/material.dart';

class AxesControlView extends StatefulWidget {
  const AxesControlView({super.key});

  @override
  State<AxesControlView> createState() => _AxesControlViewState();
}

class _AxesControlViewState extends State<AxesControlView> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: const EdgeInsets.all(0),
      children: [
        ExpansionPanelRadio(
          value: 0,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("PointAxis"),
              ),
            );
          },
          body: const PointAxisControlView(),
        ),
        ExpansionPanelRadio(
          value: 1,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("ValueAxis"),
              ),
            );
          },
          body: const ValueAxisControlView(),
        ),
      ],
      expansionCallback: (panelIndex, isExpanded) {},
    );
  }
}
