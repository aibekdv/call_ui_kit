/// A four-bar signal strength indicator icon.
library;

import 'package:flutter/material.dart';

import '../models/call_type.dart';

/// Renders a signal strength icon composed of four bars of increasing height.
///
/// The number of "lit" (coloured) bars and their colour depend on the
/// [strength] level:
///
/// - [SignalStrength.excellent] -- all 4 bars, green.
/// - [SignalStrength.good] -- 3 bars, yellow-green.
/// - [SignalStrength.poor] -- 2 bars, orange.
/// - [SignalStrength.none] -- 1 bar, red.
///
/// Unlit bars are rendered with a 30 % opacity version of the active colour.
///
/// ```dart
/// SignalStrengthIcon(
///   strength: participant.signalStrength,
///   size: 16,
/// )
/// ```
class SignalStrengthIcon extends StatelessWidget {
  /// The signal strength level to visualise.
  final SignalStrength strength;

  /// The overall logical-pixel size of the icon. Bars are scaled relative
  /// to this value.
  final double size;

  /// An optional override colour for the lit bars. When `null`, the colour
  /// is derived automatically from [strength].
  final Color? color;

  /// Creates a [SignalStrengthIcon].
  const SignalStrengthIcon({
    super.key,
    required this.strength,
    this.size = 16,
    this.color,
  });

  int get _litBars {
    return switch (strength) {
      SignalStrength.excellent => 4,
      SignalStrength.good => 3,
      SignalStrength.poor => 2,
      SignalStrength.none => 1,
    };
  }

  Color get _activeColor {
    if (color != null) return color!;
    return switch (strength) {
      SignalStrength.excellent => const Color(0xFF4CAF50),
      SignalStrength.good => const Color(0xFF8BC34A),
      SignalStrength.poor => const Color(0xFFFF9800),
      SignalStrength.none => const Color(0xFFF44336),
    };
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = size / 6;
    final gap = size / 12;
    final litCount = _litBars;
    final activeColor = _activeColor;
    final dimColor = activeColor.withValues(alpha: 0.3);

    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (index) {
          final barHeight = size * (0.25 + 0.25 * index);
          final isLit = index < litCount;
          return Container(
            width: barWidth,
            height: barHeight,
            margin: EdgeInsets.only(left: index == 0 ? 0 : gap),
            decoration: BoxDecoration(
              color: isLit ? activeColor : dimColor,
              borderRadius: BorderRadius.circular(barWidth / 2),
            ),
          );
        }),
      ),
    );
  }
}
