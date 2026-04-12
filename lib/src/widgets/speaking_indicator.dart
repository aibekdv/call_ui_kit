/// A three-bar animated speaking indicator.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Displays three vertical bars that animate in a sine-wave pattern to
/// indicate that a participant is actively speaking.
///
/// Uses a single animation controller with phase offsets to create a
/// staggered wave effect across the three bars. The indicator fades
/// in/out based on [visible].
///
/// ```dart
/// SpeakingIndicator(
///   color: theme.speakingBorderColor,
///   visible: participant.isSpeaking,
/// )
/// ```
class SpeakingIndicator extends StatefulWidget {
  /// The colour applied to all three bars.
  final Color color;

  /// The maximum height each bar animates to, in logical pixels.
  final double maxHeight;

  /// The minimum height each bar animates from, in logical pixels.
  final double minHeight;

  /// The width of each individual bar, in logical pixels.
  final double barWidth;

  /// The full cycle duration for the sine animation.
  final Duration duration;

  /// Whether the indicator is visible. When `false`, it fades out.
  final bool visible;

  /// Creates a [SpeakingIndicator].
  const SpeakingIndicator({
    super.key,
    required this.color,
    this.maxHeight = 14,
    this.minHeight = 4,
    this.barWidth = 3,
    this.duration = const Duration(milliseconds: 700),
    this.visible = true,
  });

  @override
  State<SpeakingIndicator> createState() => _SpeakingIndicatorState();
}

class _SpeakingIndicatorState extends State<SpeakingIndicator>
    with TickerProviderStateMixin {
  static const _barCount = 3;
  // Phase offsets: 120ms / 700ms ≈ 0.171 per bar
  static const _phaseOffsets = [0.0, 0.171, 0.343];

  late final AnimationController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.visible ? 1.0 : 0.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(SpeakingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _barHeight(int index, double value) {
    final sineValue = math.sin((value + _phaseOffsets[index]) * 2 * math.pi);
    final normalized = (sineValue + 1) / 2; // 0..1
    return widget.minHeight +
        (widget.maxHeight - widget.minHeight) * normalized;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: widget.maxHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_barCount, (index) {
                return Container(
                  width: widget.barWidth,
                  height: _barHeight(index, _controller.value),
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(widget.barWidth / 2),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
