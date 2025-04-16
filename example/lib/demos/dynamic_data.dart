import 'package:flutter/material.dart';

import 'graphs/graphs_all.dart';

class DemoDynamicDataPage extends DemoGraphsPage {
  const DemoDynamicDataPage({super.key}) : super(title: 'Dynamic data loading');

  @override
  DemoGraphsPageState createState() => DemoDynamicDataPageState();
}

class DemoDynamicDataPageState extends DemoGraphsPageState {
  @override
  int get simulateDataLatencyMillis => 500;

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [buildThemeSelectWidget(context)],
    );
  }
}
