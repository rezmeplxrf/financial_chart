import 'dart:math';
import 'dart:ui';

import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'chart.dart';
import 'chart_interaction.dart';

Widget _defaultLoadingWidgetBuilder(BuildContext context, GChart chart) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    alignment: Alignment.center,
    color: Colors.black.withAlpha(100),
    child: const CircularProgressIndicator(),
  );
}

Widget _defaultNoDataWidgetBuilder(BuildContext context, GChart chart) {
  return Center(
    child: Text(
      "No data",
      style: TextStyle(
        color:
            chart.theme.pointAxisTheme.labelTheme.labelStyle.textStyle?.color,
        fontSize: 24,
      ),
    ),
  );
}

// ignore_for_file: avoid_print
class GChartWidget extends StatefulWidget {
  final GChart chart;
  final TickerProvider tickerProvider;
  final Widget Function(BuildContext context, GChart chart)
  loadingWidgetBuilder;
  final Widget Function(BuildContext context, GChart chart) noDataWidgetBuilder;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapDownCallback? onDoubleTapDown;
  final PointerDownEventListener? onPointerDown;
  final PointerUpEventListener? onPointerUp;
  const GChartWidget({
    super.key,
    required this.chart,
    required this.tickerProvider,
    this.noDataWidgetBuilder = _defaultNoDataWidgetBuilder,
    this.loadingWidgetBuilder = _defaultLoadingWidgetBuilder,
    this.onTapDown,
    this.onTapUp,
    this.onDoubleTapDown,
    this.onPointerDown,
    this.onPointerUp,
  });

  @override
  GChartWidgetState createState() => GChartWidgetState();
}

class GChartWidgetState extends State<GChartWidget> {
  GChartWidgetState();
  bool printEvents = false;
  MouseCursor cursor = SystemMouseCursors.basic;
  late GChartInteractionHandler _interactionHandler;

  void initializeChart() {
    _interactionHandler = GChartInteractionHandler();
    _interactionHandler.attach(widget.chart);
    widget.chart.initialize(vsync: widget.tickerProvider);
    widget.chart.mouseCursor.addListener(cursorChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.chart.ensureInitialData();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeChart();
  }

  @override
  void dispose() {
    widget.chart.mouseCursor.removeListener(cursorChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.chart, widget.chart)) {
      // if the chart instance is changed, we need to reinitialize it
      initializeChart();
    }
  }

  void cursorChanged() {
    final newCursor = widget.chart.mouseCursor.value;
    if (newCursor != cursor) {
      cursor = newCursor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chart = widget.chart;
    final controller = _interactionHandler;
    return LayoutBuilder(
      builder: (context, constraints) {
        Size viewSize = MediaQuery.of(context).size;
        Rect rect = Rect.fromLTRB(
          0,
          0,
          (constraints.maxWidth == double.infinity)
              ? (viewSize.width - 10)
              : constraints.maxWidth,
          (constraints.maxHeight == double.infinity)
              ? (viewSize.height - 10)
              : constraints.maxHeight,
        );
        chart.resize(newArea: rect);
        return Stack(
          children: [
            GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.deferToChild,
              child: Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    if (kDebugMode && printEvents) {
                      print(
                        "PointerScrollEvent: ${event.position} delta= ${event.scrollDelta} ",
                      );
                    }
                    controller.pointerScroll(
                      position: event.localPosition,
                      scrollDelta: event.scrollDelta,
                    );
                  }
                },
                child: MouseRegion(
                  cursor: chart.mouseCursor.value,
                  child: Listener(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: chart.size,
                        painter: GChartPainter(chart: chart),
                      ),
                    ),
                    onPointerDown: (PointerDownEvent details) {
                      if (kDebugMode && printEvents) {
                        print("onPointerDown: ${details.localPosition}");
                      }
                      widget.onPointerDown?.call(details);
                    },
                    onPointerUp: (PointerUpEvent details) {
                      if (kDebugMode && printEvents) {
                        print("onPointerUp: ${details.localPosition}");
                      }
                      widget.onPointerUp?.call(details);
                    },
                  ),
                  onEnter: (PointerEvent details) {
                    controller.mouseEnter(position: details.localPosition);
                  },
                  onExit: (PointerEvent details) {
                    controller.mouseExit();
                  },
                  onHover: (PointerEvent details) {
                    controller.mouseHover(position: details.localPosition);
                  },
                ),
              ),
              onScaleStart: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleStart offset: ${details.localFocalPoint}");
                }
                controller.scaleStart(
                  start: details.localFocalPoint,
                  pointerCount: details.pointerCount,
                );
              },
              onScaleUpdate: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleUpdate offset: ${details.localFocalPoint}");
                }
                controller.scaleUpdate(
                  position: details.localFocalPoint,
                  scale: details.scale,
                  verticalScale: details.verticalScale,
                );
              },
              onScaleEnd: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleEnd offset: ${details.velocity}");
                }
                controller.scaleEnd(details.velocity);
              },
              onTapDown: (TapDownDetails details) {
                if (kDebugMode && printEvents) {
                  print("onTapDown kind: ${details.kind}");
                }
                controller.tapDown(
                  position: details.localPosition,
                  isTouch: details.kind == PointerDeviceKind.touch,
                );
                widget.onTapDown?.call(details);
              },
              onTapUp: (TapUpDetails details) {
                if (kDebugMode && printEvents) {
                  print("onTapUp kind: ${details.kind}");
                }
                controller.tapUp(
                  position: details.localPosition,
                  isTouch: details.kind == PointerDeviceKind.touch,
                );
                widget.onTapUp?.call(details);
              },
              onDoubleTapDown: (TapDownDetails details) {
                if (kDebugMode && printEvents) {
                  print("onDoubleTapDown kind: ${details.kind}");
                }
                controller.doubleTap(position: details.localPosition);
                widget.onDoubleTapDown?.call(details);
              },
              onVerticalDragStart: (DragStartDetails details) {
                controller.scaleStart(
                  start: details.localPosition,
                  pointerCount: 1,
                );
              },
              onLongPressStart: (LongPressStartDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressStart: ${details.localPosition}");
                }
                controller.longPressStart(position: details.localPosition);
              },
              onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressMoveUpdate: ${details.localPosition}");
                }
                controller.longPressMove(position: details.localPosition);
              },
              onLongPressEnd: (LongPressEndDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressEnd kind: ${details.localPosition}");
                }
                controller.longPressEnd(position: details.localPosition);
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                if (kDebugMode && printEvents) {
                  print("onVerticalDragUpdate kind: ${details.localPosition}");
                }
                controller.scaleUpdate(
                  position: details.localPosition,
                  scale: 1,
                  verticalScale: 1,
                );
              },
              onVerticalDragEnd: (DragEndDetails details) {
                controller.scaleEnd(details.velocity);
              },
            ),
            // loading indicator & no data indicator widget
            ListenableBuilder(
              listenable: widget.chart.dataSource,
              builder: (context, child) {
                if (widget.chart.dataSource.isLoading) {
                  return widget.loadingWidgetBuilder(context, widget.chart);
                }
                if (widget.chart.dataSource.dataList.isEmpty) {
                  return widget.noDataWidgetBuilder(context, widget.chart);
                }
                return const SizedBox.shrink();
              },
            ),
            // tooltip widgets
            ...widget.chart.panels.asMap().entries.map(
              (panelEntry) =>
                  panelEntry.value.tooltip?.tooltipNotifier != null
                      ? RepaintBoundary(
                        child: ListenableBuilder(
                          listenable:
                              (panelEntry.value.tooltip?.tooltipNotifier)!,
                          builder: (context, child) {
                            final ctx =
                                panelEntry
                                    .value
                                    .tooltip
                                    ?.tooltipNotifier
                                    ?.value;
                            if (ctx == null) {
                              return const SizedBox.shrink();
                            }
                            final tooltipWidget = panelEntry
                                .value
                                .tooltip
                                ?.tooltipWidgetBuilder
                                ?.call(
                                  context,
                                  ctx.area.size,
                                  ctx.tooltip,
                                  ctx.point,
                                );
                            if (tooltipWidget == null) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              width: ctx.area.width,
                              height: ctx.area.height,
                              child: CustomSingleChildLayout(
                                delegate: _TooltipSingleChildLayoutDelegate(
                                  offset: ctx.anchorPosition,
                                  area: ctx.area,
                                ),
                                child: IgnorePointer(child: tooltipWidget),
                              ),
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _TooltipSingleChildLayoutDelegate extends SingleChildLayoutDelegate {
  _TooltipSingleChildLayoutDelegate({required this.offset, required this.area});

  final Offset? offset;
  final Rect? area;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (offset == null) {
      return Offset(
        size.width / 2 - childSize.width / 2,
        size.height / 2 - childSize.height / 2,
      );
    }

    final offsetX = clampDouble(
      offset!.dx,
      area?.left ?? 0,
      max(
        area?.left ?? 0,
        (area?.left ?? 0) + (area?.width ?? size.width) - childSize.width,
      ),
    );
    final offsetY = clampDouble(
      offset!.dy,
      area?.top ?? 0,
      max(
        area?.top ?? 0,
        (area?.top ?? 0) + (area?.height ?? size.height) - childSize.height,
      ),
    );
    return Offset(offsetX, offsetY);
  }

  @override
  bool shouldRelayout(
    covariant _TooltipSingleChildLayoutDelegate oldDelegate,
  ) => oldDelegate.offset != offset;
}

class GChartPainter extends CustomPainter {
  final GChart chart;
  GChartPainter({required this.chart}) : super(repaint: chart);

  @override
  void paint(Canvas canvas, Size size) {
    chart.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
