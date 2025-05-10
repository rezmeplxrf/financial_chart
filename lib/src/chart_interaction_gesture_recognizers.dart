part of 'chart_interaction.dart';

/// Custom gesture recognizers for handling events on the chart.
class GChartScaleGestureRecognizer extends ScaleGestureRecognizer {
  GChart? chart;
  GChartScaleGestureRecognizer({
    super.supportedDevices,
    this.chart,
    super.dragStartBehavior = DragStartBehavior.down,
  });

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (team?.captain != this) {
      // get back as captain
      team?.captain = this;
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        super.addAllowedPointer(event);
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // point axes which can not scale do not allow scale
      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition)) {
          return;
        }
      }
      // value axes which can not scale do not allow scale
      for (final axis in panel.valueAxes) {
        if (axis.scaleMode == GAxisScaleMode.none &&
            panel.valueAxisAreaOf(axis).contains(event.localPosition)) {
          return;
        }
      }
      if (panel.graphPanMode == GGraphPanMode.none &&
          panel.graphArea().contains(event.localPosition)) {
        //  do not allow scale when graphPanMode is none
        return;
      }
    }
    super.addAllowedPointer(event);
  }
}

/// Custom gesture recognizer for handling vertical drag events on the chart.
class GChartVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  GChart? chart;
  GChartVerticalDragGestureRecognizer({super.supportedDevices, this.chart});

  GestureArenaMember? _hijackedCaptain;
  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  void _hijackCaptain() {
    _hijackedCaptain = team?.captain;
    team?.captain = this;
  }

  void _restoreCaptainIfNecessary() {
    if (_hijackedCaptain != null) {
      team?.captain = _hijackedCaptain;
      _hijackedCaptain = null;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // splitters allows vertical drag
      if (panel.splitterArea().contains(event.localPosition)) {
        if (panel.resizable) {
          _hijackCaptain();
          super.addAllowedPointer(event);
        }
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // point axes do not allow vertical drag
      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition)) {
          return;
        }
      }
      // value axes which can not scale do not allow vertical drag
      for (final axis in panel.valueAxes) {
        if (axis.scaleMode == GAxisScaleMode.none &&
            panel.valueAxisAreaOf(axis).contains(event.localPosition)) {
          return;
        }
      }
      if (panel.graphArea().contains(event.localPosition)) {
        if (panel.graphPanMode == GGraphPanMode.none) {
          //  do not allow scale when graphPanMode is none
          return;
        }
        // graph with autoScale value viewport do not allow vertical drag
        GGraph? graph =
            chart?.hitTestPanelGraphs(
              panel: panel,
              position: event.localPosition,
            ) ??
            panel.graphs.lastOrNull;
        if (graph != null &&
            panel.findValueViewPortById(graph.valueViewPortId).autoScaleFlg) {
          return;
        }
      }
    }
    super.addAllowedPointer(event);
  }
}

/// Custom gesture recognizer for handling horizontal drag events on the chart.
class GChartHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  GChart? chart;
  GChartHorizontalDragGestureRecognizer({super.supportedDevices, this.chart});
  GestureArenaMember? _hijackedCaptain;

  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  void _hijackCaptain() {
    _hijackedCaptain = team?.captain;
    team?.captain = this;
  }

  void _restoreCaptainIfNecessary() {
    if (_hijackedCaptain != null) {
      team?.captain = _hijackedCaptain;
      _hijackedCaptain = null;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? [])) {
      // splitters do not allow horizontal drag
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // value axes do not allow horizontal drag
      for (final axis in panel.valueAxes) {
        if (panel.valueAxisAreaOf(axis).contains(event.localPosition)) {
          return;
        }
      }
      // point axes which can not scale do not allow horizontal drag
      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition)) {
          if (axis.scaleMode == GAxisScaleMode.none) {
            return;
          } else {
            _hijackCaptain();
            super.addAllowedPointer(event);
            return;
          }
        }
      }
      if (panel.graphPanMode == GGraphPanMode.none &&
          panel.graphArea().contains(event.localPosition)) {
        //  do not allow scale when graphPanMode is none
        return;
      }
    }
    super.addAllowedPointer(event);
  }
}

class GChartLongPressGestureRecognizer extends LongPressGestureRecognizer {
  GChart? chart;

  GChartLongPressGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        // splitters do not allow long press
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // only allow long press on the graph area
      if (panel.graphArea().contains(event.localPosition)) {
        super.addAllowedPointer(event);
        return;
      }
    }
  }
}

class GChartTapGestureRecognizer extends TapGestureRecognizer {
  GChart? chart;

  GChartTapGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        // splitters do not allow tap
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if ((panel.onTapGraphArea != null ||
              panel.onDoubleTapGraphArea != null) &&
          panel.graphArea().contains(event.localPosition)) {
        // only allow tap on the graph area when there is any callback
        super.addAllowedPointer(event);
        return;
      }
    }
    // super.addAllowedPointer(event);
  }
}

class GChartDoubleTapGestureRecognizer extends DoubleTapGestureRecognizer {
  GChart? chart;

  GChartDoubleTapGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        // splitters do not allow double tap
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.graphArea().contains(event.localPosition) &&
          panel.onDoubleTapGraphArea == null) {
        // double tap graph area is only allowed when onDoubleTapGraphArea is not null
        return;
      }
    }
    super.addAllowedPointer(event);
  }
}
