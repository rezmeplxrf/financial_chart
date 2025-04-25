## 0.2.3
2025-04-25
- use batch drawing when possible to improve performance.
- add `GToolTip`.`tooltipWidgetBuilder` property to allow use custom widget as tooltip.
- add `GChart`.`hitTestEnable` property to allow disable hit testing globally.
- fix issue of highlight markers drawn outside the graph area.
- code refactoring.

## 0.2.2
2025-04-22
- **[breaking change]** code refactoring.
  + remove `GGraphAreaTheme`.`styleValueAboveLine` and `styleValueBelowLine`.
  + rename `GGraphAreaTheme`.`styleAboveArea`, `styleAboveArea` to `styleAboveBase`, `styleBelowBase`.
  + move `GGraph`.`layer`, `hitTestMode`, `highlight` to parent `GComponent` class.
  + remove `GGraphOhlcTheme`.`lineStyleMinus` and `lineStylePlus`.
  + remove `PaintStyle`.`elevation` and `shadowColor`.
- draw point value label (time string) to tooltip.
- fix notifyListeners error after disposed.
- add `autoScaleFlg` to `GPointViewPort` (fix issue [#34](https://github.com/cjjapan/financial_chart/issues/34)).
- update examples.  

## 0.2.1
2025-04-16
- **[breaking change]** code refactoring.
  + rename `HitTestMode` to `GHitTestMode`.
  + rename `GChartController` to `GChartInteractionHandler`.
  + rename `ViewSizeConvertor` to `GViewSizeConvertor`.
  + rename `GPointAxisMarker`.`point` to `labelPoint`.
  + remove `GValue`.`call()`.
- add `resizeMode` to `GPointViewPort` and `GValueViewPort` to allow config the behavior when resizing.
- allow update graph properties (added setters).
- fix notifyListeners error after disposed.
- update examples.
- [0.2.1+1] code format & update examples.
- [0.2.1+2] property name `viewPortResizeMode` -> `resizeMode` and add to constructor.

## 0.2.0
2025-04-12
- **[breaking change]** refactor markers  
  + rename `GGraphMarker` to `GOverlayMarker` so it can be also added to axes.
  + remove `GGraph.axisMarkers` property and rename `GGraph.graphMarkers` property to `GGraph.overlayMarkers`. 
  + add `GAxis.axisMarkers` and `GAxis.overlayMarkers` properties.
  + update `GTheme` marker properties.
- fix rendering label with rotation.
- update Markers and Live examples.

## 0.1.8
2025-04-10
- fix issue `GChartWidget` not working correctly after `chart` object being recreated.
- add `GPanel.graphPanMode` property to allow disable panning graph.
- add `GPointViewPort.startPointMin`, `GPointViewPort.endPointMax` properties to allow range restriction.
- remove dependency `intl` and `path_drawing` to reduce dependency conflict.
- update Panels example.

## 0.1.7
2025-04-07
- fix mouse cursor for splitter
- fix for an issue in example dependency
- add `GPanel.positionToViewPortCoord()`
- update examples

## 0.1.6
2025-04-01  
- add mouse cursor support
- fix basic example
- refactoring

## 0.1.5
2025-03-28  
- expose GChartWidget.onTapXX callbacks
- add `GChart.hitTestGraph()`, `GChart.saveAsImage()`
- change `GChart.preRender()`, `GChart.postRender()` callbacks
- allow default valueViewPortId
- update examples
- [0.1.5+1] expose `GChartWidget`.`onPointerDown`, `onPointerUp`

## 0.1.4
2025-03-23
- bug fix
- update examples

## 0.1.3
2025-03-22
- bug fix
- Add live update demo 

## 0.1.2
2025-03-20
- Add feature for issue #2: add momentum scrolling
- Add feature for issue #3: allow zooming in/out with mouse wheel
- [0.1.2+1] Update for issue #3: fix zoom center point
- [0.1.2+2] Change src files layout 

2025-03-21
- [0.1.2+3] Fix for issue #3: fix zoom center point
- [0.1.2+4] Fix for issue #2: Add GPanel.momentumScrollSpeed option

## 0.1.1
2025-03-15
- Minor changes
- [0.1.1+1] Fix for linting
- [0.1.1+2] Fix for linting

## 0.1.0
2025-03-15
- First release
