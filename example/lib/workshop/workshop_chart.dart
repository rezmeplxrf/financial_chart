import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import 'workshop_state.dart';

class WorkshopChartView extends StatefulWidget {
  final WorkshopState workshopState;
  const WorkshopChartView({super.key, required this.workshopState});

  @override
  WorkshopChartViewState createState() => WorkshopChartViewState();
}

class WorkshopChartViewState extends State<WorkshopChartView>
    with TickerProviderStateMixin {
  WorkshopChartViewState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.workshopState,
      builder: (context, child) {
        final workshop = widget.workshopState;
        if (workshop.chart == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          color: Colors.blueGrey,
          child: GChartWidget(chart: workshop.chart!, tickerProvider: this),
        );
      },
    );
  }
}
