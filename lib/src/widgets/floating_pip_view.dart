/// A draggable Picture-in-Picture overlay for local video.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/call_strings.dart';
import '../models/call_theme.dart';
import '../utils/pip_snap_calculator.dart';

/// A floating, draggable mini-view that displays the local participant's
/// video stream during a call.
///
/// When [child] is non-null it fills the PiP area; otherwise a dark background
/// with initials is rendered as a fallback.
///
/// The view snaps to the nearest screen corner on drag release using
/// [PipSnapCalculator.snapToNearestCorner].
class FloatingPipView extends StatefulWidget {
  /// The local video widget rendered inside the PiP frame.
  final Widget? child;

  /// The display name used for the avatar fallback.
  final String displayName;

  /// The visual theme providing colours and sizing.
  final CallTheme theme;

  /// Localised strings.
  final CallStrings strings;

  /// The total screen size used for clamping and corner calculations.
  final Size screenSize;

  /// The height of the top bar area (safe area inset + top bar).
  final double topBarHeight;

  /// The height of the controls area (controls bar + safe area inset).
  final double controlsHeight;

  /// Safe area inset on the left edge.
  final double safeAreaLeft;

  /// Safe area inset on the right edge.
  final double safeAreaRight;

  /// Safe area inset at the top (notch / status bar).
  final double safeAreaTop;

  /// Safe area inset at the bottom (home indicator).
  final double safeAreaBottom;

  /// Listenable that indicates whether call controls are currently visible.
  /// When controls hide, the PiP resnaps to use the full screen area.
  final ValueListenable<bool>? controlsVisible;

  /// Called when the PiP view is tapped (e.g. to swap local/remote video).
  final VoidCallback? onTap;

  /// Creates a [FloatingPipView].
  const FloatingPipView({
    super.key,
    this.child,
    required this.displayName,
    required this.theme,
    required this.strings,
    required this.screenSize,
    required this.topBarHeight,
    required this.controlsHeight,
    this.safeAreaLeft = 0,
    this.safeAreaRight = 0,
    this.safeAreaTop = 0,
    this.safeAreaBottom = 0,
    this.controlsVisible,
    this.onTap,
  });

  @override
  State<FloatingPipView> createState() => _FloatingPipViewState();
}

class _FloatingPipViewState extends State<FloatingPipView> {
  static const _pipSize = Size(90, 120);
  static const _margin = 16.0;
  static const _borderRadius = 12.0;
  static const _borderWidth = 1.5;
  static const _snapDuration = Duration(milliseconds: 220);
  static const _snapCurve = Curves.easeOutCubic;

  late final ValueNotifier<Offset> _position;
  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _position = ValueNotifier(_defaultPosition);
    widget.controlsVisible?.addListener(_onControlsVisibilityChanged);
  }

  @override
  void didUpdateWidget(FloatingPipView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controlsVisible != widget.controlsVisible) {
      oldWidget.controlsVisible
          ?.removeListener(_onControlsVisibilityChanged);
      widget.controlsVisible?.addListener(_onControlsVisibilityChanged);
    }
    if (oldWidget.screenSize != widget.screenSize) {
      _position.value = _clampPosition(_position.value);
    }
  }

  @override
  void dispose() {
    widget.controlsVisible?.removeListener(_onControlsVisibilityChanged);
    _position.dispose();
    _isDragging.dispose();
    super.dispose();
  }

  void _onControlsVisibilityChanged() {
    // Resnap to nearest corner with updated insets.
    _position.value = PipSnapCalculator.snapToNearestCorner(
      current: _position.value,
      screenSize: widget.screenSize,
      pipSize: _pipSize,
      margin: _margin,
      topBarHeight: _effectiveTopBarHeight,
      controlsHeight: _effectiveControlsHeight,
    );
  }

  bool get _controlsShown =>
      widget.controlsVisible?.value ?? true;

  double get _effectiveTopBarHeight =>
      _controlsShown ? widget.topBarHeight : widget.safeAreaTop;

  double get _effectiveControlsHeight =>
      _controlsShown ? widget.controlsHeight : widget.safeAreaBottom;

  Offset get _defaultPosition => Offset(
        widget.screenSize.width -
            _pipSize.width -
            _margin -
            widget.safeAreaRight,
        _effectiveTopBarHeight + _margin,
      );

  Offset _clampPosition(Offset offset) {
    final dx = offset.dx.clamp(
      _margin + widget.safeAreaLeft,
      widget.screenSize.width -
          _pipSize.width -
          _margin -
          widget.safeAreaRight,
    );
    final dy = offset.dy.clamp(
      _effectiveTopBarHeight + _margin,
      widget.screenSize.height -
          _pipSize.height -
          _effectiveControlsHeight -
          _margin,
    );
    return Offset(dx.toDouble(), dy.toDouble());
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _isDragging.value = true;
    _position.value = _clampPosition(
      Offset(
        _position.value.dx + details.delta.dx,
        _position.value.dy + details.delta.dy,
      ),
    );
  }

  void _onPanEnd(DragEndDetails details) {
    final target = PipSnapCalculator.snapToNearestCorner(
      current: _position.value,
      screenSize: widget.screenSize,
      pipSize: _pipSize,
      margin: _margin,
      topBarHeight: _effectiveTopBarHeight,
      controlsHeight: _effectiveControlsHeight,
    );
    _isDragging.value = false;
    _position.value = target;
  }

  Widget _buildFallbackContent() {
    final initial = widget.displayName.isNotEmpty
        ? widget.displayName[0].toUpperCase()
        : '?';
    return ColoredBox(
      color: widget.theme.buttonBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  widget.theme.barBackground,
              child: Text(
                initial,
                style: TextStyle(
                  color: widget.theme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.strings.you,
              style: TextStyle(
                color: widget.theme.textPrimary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pipChild = GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: Container(
        width: _pipSize.width,
        height: _pipSize.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: widget.theme.textPrimary,
            width: _borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(_borderRadius - _borderWidth),
          child: widget.child ?? _buildFallbackContent(),
        ),
      ),
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _isDragging,
      builder: (context, dragging, _) => ValueListenableBuilder<Offset>(
        valueListenable: _position,
        builder: (context, pos, child) => AnimatedPositioned(
          duration: dragging ? Duration.zero : _snapDuration,
          curve: _snapCurve,
          left: pos.dx,
          top: pos.dy,
          child: child!,
        ),
        child: RepaintBoundary(child: pipChild),
      ),
    );
  }
}
