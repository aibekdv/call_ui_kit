/// The "more options" bottom sheet shown from the three-dots button.
library;

import 'package:flutter/material.dart';

import '../models/call_strings.dart';
import '../models/call_theme.dart';
import 'handle_bar.dart';

/// A modal bottom sheet with a handle bar, optional encryption label,
/// custom content area, and a cancel button.
///
/// The [child] widget is placed between the encryption label and the cancel
/// button. Consumers provide their own menu items via [child]:
///
/// ```dart
/// MoreBottomSheet(
///   theme: theme,
///   strings: strings,
///   child: Column(
///     children: [
///       ListTile(title: Text('Share Screen'), onTap: ...),
///       ListTile(title: Text('Send Message'), onTap: ...),
///     ],
///   ),
/// )
/// ```
class MoreBottomSheet extends StatelessWidget {
  /// The visual theme.
  final CallTheme theme;

  /// Localised strings (used for the cancel button text).
  final CallStrings strings;

  /// Whether to show the end-to-end encryption label.
  final bool showEncryptionLabel;

  /// Custom content placed between the encryption label and cancel button.
  final Widget child;

  /// Creates a [MoreBottomSheet].
  const MoreBottomSheet({
    super.key,
    required this.theme,
    required this.strings,
    this.showEncryptionLabel = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.barBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const HandleBar(),

          // Encryption label
          if (showEncryptionLabel) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: theme.textPrimary.withValues(alpha: 0.54),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.endToEndEncrypted,
                  style: TextStyle(
                    color: theme.textPrimary.withValues(alpha: 0.54),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Custom content
          child,

          const SizedBox(height: 12),

          // Cancel button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.buttonBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                strings.cancel,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
