/// A small drag-handle indicator for bottom sheets.
library;

import 'package:flutter/material.dart';

/// A rounded handle bar typically shown at the top of a modal bottom sheet
/// to indicate it can be dragged.
class HandleBar extends StatelessWidget {
  /// Optional margin override. Defaults to `EdgeInsets.symmetric(vertical: 10)`.
  final EdgeInsetsGeometry? margin;

  const HandleBar({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
