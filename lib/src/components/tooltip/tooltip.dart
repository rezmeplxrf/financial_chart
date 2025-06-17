import 'package:equatable/equatable.dart';
import 'package:financial_chart/src/components/components.dart';
import 'package:financial_chart/src/values/value.dart';
import 'package:flutter/widgets.dart';

/// Position of the tooltip.
enum GTooltipPosition {
  /// No tooltip
  none,

  /// Tooltip will be displayed at the top left corner of the graph area.
  topLeft,

  /// Tooltip will be displayed at the bottom left corner of the graph area.
  bottomLeft,

  /// Tooltip will be displayed at the top right corner of the graph area.
  topRight,

  /// Tooltip will be displayed at the bottom right corner of the graph area.
  bottomRight,

  /// Tooltip will be displayed follow the position of the pointer.
  followPointer,
}

/// The builder function to create the tooltip widget.
typedef GToolTipWidgetBuilder =
    Widget Function(
      BuildContext context,
      Size maxSize,
      GTooltip tooltip,
      int point,
    );

class GToolTipWidgetContext extends Equatable {

  const GToolTipWidgetContext({
    required this.panel,
    required this.area,
    required this.tooltip,
    required this.point,
    required this.anchorPosition,
  });
  final GPanel panel;
  final Rect area;
  final GTooltip tooltip;
  final int point;
  final Offset anchorPosition;

  @override
  List<Object?> get props => [
    area,
    point,
    Offset(
      anchorPosition.dx.round().toDouble(),
      anchorPosition.dy.round().toDouble(),
    ),
  ];
}

/// Tooltip component.
class GTooltip extends GComponent {

  GTooltip({
    GTooltipPosition position = GTooltipPosition.followPointer,
    bool showPointValue = true,
    this.dataKeys = const [],
    String? followValueKey,
    String? followValueViewPortId,
    bool pointLineHighlightVisible = true,
    bool valueLineHighlightVisible = true,
    super.render = const GTooltipRender(),
    super.theme,
    GToolTipWidgetBuilder? tooltipWidgetBuilder,
  }) : _position = GValue<GTooltipPosition>(position),
       _showPointValue = GValue<bool>(showPointValue),
       _followValueKey = GValue<String?>(followValueKey),
       _followValueViewPortId = GValue<String?>(followValueViewPortId),
       _pointLineHighlightVisible = GValue<bool>(pointLineHighlightVisible),
       _valueLineHighlightVisible = GValue<bool>(valueLineHighlightVisible),
       _tooltipWidgetBuilder = GValue<GToolTipWidgetBuilder?>(
         tooltipWidgetBuilder,
       ) {
    if (tooltipWidgetBuilder != null) {
      _tooltipNotifier = ValueNotifier<GToolTipWidgetContext?>(null);
    } else {
      _tooltipNotifier = null;
    }
  }
  /// Position of the tooltip. default is [GTooltipPosition.followPointer].
  ///
  /// See [GTooltipPosition] for more details.
  final GValue<GTooltipPosition> _position;
  GTooltipPosition get position => _position.value;
  set position(GTooltipPosition value) => _position.value = value;

  /// the data keys which will be displayed in the tooltip.
  final List<String> dataKeys;

  /// Whether to show the point value in the tooltip.
  final GValue<bool> _showPointValue;
  bool get showPointValue => _showPointValue.value;
  set showPointValue(bool value) => _showPointValue.value = value;

  /// when [position] is [GTooltipPosition.followPointer], the tooltip will follow to the value position of this key.
  /// [followValueViewPortId] must be set also
  final GValue<String?> _followValueKey;
  String? get followValueKey => _followValueKey.value;
  set followValueKey(String? value) => _followValueKey.value = value;

  /// when [position] is [GTooltipPosition.followPointer], the tooltip will follow to the value position of this viewPort.
  /// [followValueKey] must be set also.
  final GValue<String?> _followValueViewPortId;
  String? get followValueViewPortId => _followValueViewPortId.value;
  set followValueViewPortId(String? value) =>
      _followValueViewPortId.value = value;

  /// Whether to display the point line highlight.
  final GValue<bool> _pointLineHighlightVisible;
  bool get pointLineHighlightVisible => _pointLineHighlightVisible.value;
  set pointLineHighlightVisible(bool value) =>
      _pointLineHighlightVisible.value = value;

  /// Whether to display the value line highlight.
  ///
  /// The value line highlight will be displayed when [followValueKey] and [followValueViewPortId] are set.
  final GValue<bool> _valueLineHighlightVisible;
  bool get valueLineHighlightVisible => _valueLineHighlightVisible.value;
  set valueLineHighlightVisible(bool value) =>
      _valueLineHighlightVisible.value = value;

  /// The notifier to notify the tooltip widget to rebuild when the tooltip data changes.
  ValueNotifier<GToolTipWidgetContext?>? _tooltipNotifier;
  ValueNotifier<GToolTipWidgetContext?>? get tooltipNotifier =>
      _tooltipNotifier;

  /// The builder function to create the tooltip widget.
  final GValue<GToolTipWidgetBuilder?> _tooltipWidgetBuilder;
  GToolTipWidgetBuilder? get tooltipWidgetBuilder =>
      _tooltipWidgetBuilder.value;
  set tooltipWidgetBuilder(GToolTipWidgetBuilder? value) {
    _tooltipWidgetBuilder.value = value;
    if (value != null) {
      _tooltipNotifier ??= ValueNotifier<GToolTipWidgetContext?>(null);
    } else {
      _tooltipNotifier?.dispose();
      _tooltipNotifier = null;
    }
  }

  void dispose() {
    _tooltipNotifier?.dispose();
  }
}
