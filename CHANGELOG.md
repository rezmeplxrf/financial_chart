## 0.2.0
2025-04-12
- <span style="color: orange; ">[breaking change]</span> refactor markers  
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
