/// The bottom controls bar for the call screen.
library;

import 'package:flutter/material.dart';

import '../../models/call_theme.dart';

/// A rounded bar of circular control buttons (mute, camera, speaker, end call, etc.).
///
/// Each optional button is shown only when its callback is provided.
class CallBottomBar extends StatelessWidget {
  final EdgeInsets safeArea;
  final CallTheme theme;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final VoidCallback onResetHideTimer;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onEndCall;
  final VoidCallback? onShowMore;
  final VoidCallback? onToggleCamera;
  final VoidCallback? onToggleScreenShare;
  final bool isScreenSharing;

  const CallBottomBar({
    super.key,
    required this.safeArea,
    required this.theme,
    required this.isMuted,
    this.isCameraOff = false,
    required this.isSpeakerOn,
    this.isScreenSharing = false,
    required this.onResetHideTimer,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onEndCall,
    this.onShowMore,
    this.onToggleCamera,
    this.onToggleScreenShare,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
      padding: EdgeInsets.only(
        left: 12 + safeArea.left,
        right: 12 + safeArea.right,
        bottom: safeArea.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.barBackground.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Three dots / more menu
            if (onShowMore != null)
              _buildControlButton(
                icon: Icons.more_horiz,
                iconColor: theme.textPrimary,
                backgroundColor: theme.buttonBackground,
                size: 50,
                onTap: onShowMore!,
              ),

            // Screen share toggle
            if (onToggleScreenShare != null)
              _buildControlButton(
                icon: isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
                iconColor: theme.textPrimary,
                backgroundColor: theme.buttonBackground,
                size: 50,
                onTap: onToggleScreenShare!,
              ),

            // Video camera toggle
            if (onToggleCamera != null)
              _buildControlButton(
                icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
                iconColor: theme.textPrimary,
                backgroundColor: theme.buttonBackground,
                size: 50,
                onTap: onToggleCamera!,
              ),

            // Speaker
            _buildControlButton(
              icon: Icons.volume_up,
              iconColor: isSpeakerOn
                  ? theme.speakerActiveIconColor
                  : theme.textPrimary,
              backgroundColor: isSpeakerOn
                  ? theme.speakerActiveBackground
                  : theme.buttonBackground,
              size: 50,
              onTap: onToggleSpeaker,
            ),

            // Microphone
            _buildControlButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              iconColor: theme.textPrimary,
              backgroundColor: theme.buttonBackground,
              size: 50,
              onTap: onToggleMute,
            ),

            // End call
            _buildControlButton(
              icon: Icons.call_end,
              iconColor: theme.textPrimary,
              backgroundColor: theme.endCallColor,
              size: 58,
              iconSize: 26,
              onTap: onEndCall,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required double size,
    double iconSize = 22,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onResetHideTimer();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
