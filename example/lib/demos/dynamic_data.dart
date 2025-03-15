import 'graphs.dart';

class DemoDynamicDataPage extends DemoGraphsPage {
  const DemoDynamicDataPage({super.key}) : super(title: 'Dynamic data loading');

  @override
  DemoGraphsPageState createState() => DemoDynamicDataPageState();
}

class DemoDynamicDataPageState extends DemoGraphsPageState {
  @override
  int get simulateDataLatencyMillis => 500;
}
