
/// Defines the behavior of how to update the viewport range when view size changed.
enum GViewPortResizeMode {
  /// no update to the range
  keepRange,

  /// keep the range start of the viewport and extend / shrink the range end
  keepStart,

  /// keep the range end of the viewport and extend / shrink the range start
  keepEnd,

  /// keep the range center of the viewport and extend / shrink the range start and end
  keepCenter,
}
