import 'package:flutter/material.dart';

import 'viewport_point.dart';
import 'viewport_value.dart';

class ViewPortsControlView extends StatefulWidget {
  const ViewPortsControlView({super.key});

  @override
  State<ViewPortsControlView> createState() => _ViewPortsControlViewState();
}

class _ViewPortsControlViewState extends State<ViewPortsControlView> {
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
                child: Text("PointViewPort"),
              ),
            );
          },
          body: const PointViewPortControlView(),
        ),
        ExpansionPanelRadio(
          value: 1,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("ValueViewPort"),
              ),
            );
          },
          body: const ValueViewPortControlView(),
        ),
      ],
      expansionCallback: (panelIndex, isExpanded) {},
    );
  }
}
