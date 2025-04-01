import '../../components/component.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import 'group_render.dart';

/// A Group of graphs.
class GGraphGroup extends GGraph<GGraphTheme> {
  static const String typeName = "group";

  final List<GGraph> graphs;

  @override
  set highlight(bool value) {
    super.highlight = value;
    for (final graph in graphs) {
      graph.highlight = value;
    }
  }

  GGraphGroup({
    super.id,
    required this.graphs,
    super.valueViewPortId,
    super.layer,
    super.visible,
    super.axisMarkers,
    super.graphMarkers,
    super.render,
  }) : super(
         hitTestMode: HitTestMode.none, // unused
         theme: const GGraphTheme(), // unused
       ) {
    assert(
      graphs.any((graph) => graph.valueViewPortId != valueViewPortId) == false,
    );
    super.render = render ?? GGraphGroupRender();
    graphs.sort((a, b) => a.layer.compareTo(b.layer));
  }

  @override
  String get type => typeName;
}
