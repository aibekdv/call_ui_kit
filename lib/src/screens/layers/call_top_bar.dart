/// The top app bar overlay for the call screen.
library;

import 'package:flutter/material.dart';

import '../../models/call_strings.dart';
import '../../models/call_theme.dart';
import '../../models/call_type.dart';

/// A gradient-backed top bar showing caller info and camera controls.
class CallTopBar extends StatelessWidget {
  final EdgeInsets safeArea;
  final CallTheme theme;
  final CallStrings strings;
  final String callerName;
  final String? callStatusText;
  final CallType callType;
  final bool isGroupCall;
  final int participantCount;
  final VoidCallback onResetHideTimer;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onMinimize;

  const CallTopBar({
    super.key,
    required this.safeArea,
    required this.theme,
    required this.strings,
    required this.callerName,
    this.callStatusText,
    required this.callType,
    required this.isGroupCall,
    required this.participantCount,
    required this.onResetHideTimer,
    this.onFlipCamera,
    this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: safeArea.top,
        left: safeArea.left,
        right: safeArea.right,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      height: 80 + safeArea.top,
      child: Row(
        children: [
          // Left — Minimize / PiP button
          Expanded(
            child: onMinimize != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.textPrimary,
                        size: 24,
                      ),
                      tooltip: strings.pictureInPicture,
                      onPressed: () {
                        onResetHideTimer();
                        onMinimize!();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Center — name + status
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  callerName,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  callStatusText ?? strings.calling,
                  style: TextStyle(
                    color: theme.textPrimary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                if (isGroupCall)
                  Text(
                    strings.participantsCount(participantCount),
                    style: TextStyle(
                      color: theme.textPrimary.withValues(alpha: 0.54),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Right — flip camera (when callback provided)
          Expanded(
            child: onFlipCamera != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.flip_camera_ios,
                        color: theme.textPrimary,
                        size: 28,
                      ),
                      tooltip: strings.flipCamera,
                      onPressed: () {
                        onResetHideTimer();
                        onFlipCamera!();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
