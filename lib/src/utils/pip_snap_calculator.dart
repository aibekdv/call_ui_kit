import 'dart:ui';

/// Calculates the snap position for the floating Picture-in-Picture view.
///
/// The PiP view snaps to the nearest corner of the screen when the user
/// releases it after dragging.
class PipSnapCalculator {
  PipSnapCalculator._();

  /// Returns the [Offset] of the nearest corner for the PiP to snap to.
  ///
  /// [current] is the current position of the PiP (top-left corner).
  /// [screenSize] is the total screen size.
  /// [pipSize] is the size of the PiP widget.
  /// [margin] is the margin from screen edges.
  /// [topBarHeight] is the height of the top bar (including safe area).
  /// [controlsHeight] is the height of the controls bar (including safe area).
  static Offset snapToNearestCorner({
    required Offset current,
    required Size screenSize,
    required Size pipSize,
    required double margin,
    required double topBarHeight,
    required double controlsHeight,
  }) {
    final cx = current.dx + pipSize.width / 2;
    final cy = current.dy + pipSize.height / 2;
    final isRight = cx > screenSize.width / 2;
    final isBottom = cy > screenSize.height / 2;

    final dx = isRight
        ? screenSize.width - pipSize.width - margin
        : margin;
    final dy = isBottom
        ? screenSize.height - pipSize.height - controlsHeight - margin
        : topBarHeight + margin;

    return Offset(dx, dy);
  }
}
