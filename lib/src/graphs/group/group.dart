import 'package:financial_chart/src/components/graph/graph.dart';
import 'package:financial_chart/src/components/graph/graph_theme.dart';
import 'package:financial_chart/src/graphs/group/group_render.dart';
import 'package:flutter/foundation.dart';

/// A Group of graphs.
class GGraphGroup extends GGraph<GGraphTheme> {
  GGraphGroup({
    required this.graphs,
    super.id,
    super.valueViewPortId,
    super.layer,
    super.visible,
    super.overlayMarkers,
    super.render,
  }) : super(
         theme: const GGraphTheme(), // unused
       ) {
    assert(
      graphs.any((graph) => graph.valueViewPortId != valueViewPortId) == false,
    );
    super.render = render ?? GGraphGroupRender();
    graphs.sort((a, b) => a.layer.compareTo(b.layer));
  }
  static const String typeName = 'group';

  final List<GGraph> graphs;

  @override
  set highlight(bool value) {
    super.highlight = value;
    for (final graph in graphs) {
      graph.highlight = value;
    }
  }

  GGraph? findGraphById(String id) {
    for (final graph in graphs) {
      if (graph.id == id) {
        return graph;
      }
    }
    return null;
  }

  @override
  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<GGraph>('graphs', graphs));
  }
}
