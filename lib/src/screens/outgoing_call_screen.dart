/// The outgoing call screen with end-call and optional toggle buttons.
library;

import 'package:flutter/material.dart';

import '../models/call_strings.dart';
import '../models/call_theme.dart';
import '../models/call_type.dart';
import '../widgets/call_avatar.dart';

/// Displays an outgoing call screen with caller info, optional mute/speaker
/// toggles, and an end-call button.
///
/// This is a [StatelessWidget] with zero animation controllers or timers
/// for maximum performance. Call duration or status text is passed in
/// externally via [callStatusText].
///
/// ```dart
/// OutgoingCallScreen(
///   callerName: 'Alex Rivera',
///   callerAvatarUrl: 'https://example.com/avatar.jpg',
///   callType: CallType.video,
///   callStatusText: 'Ringing…',
///   onEndCall: () => Navigator.pop(context),
///   onToggleMute: () => setState(() => _isMuted = !_isMuted),
///   onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
/// )
/// ```
class OutgoingCallScreen extends StatelessWidget {
  /// The name of the person being called.
  final String callerName;

  /// Optional avatar URL for the person being called.
  final String? callerAvatarUrl;

  /// The type of outgoing call (audio or video).
  final CallType callType;

  /// The visual theme. Defaults to [CallTheme.whatsApp].
  final CallTheme theme;

  /// Localised strings. Defaults to [CallStrings.english].
  final CallStrings? strings;

  /// Status text override (e.g. "Ringing…", "00:03").
  /// When null, shows [CallStrings.calling].
  final String? callStatusText;

  /// Whether the local microphone is muted.
  final bool isMuted;

  /// Whether the speaker is active.
  final bool isSpeakerOn;

  /// Called when the end-call button is tapped.
  final VoidCallback onEndCall;

  /// Called when the mute toggle is tapped.
  /// When null, the mute button is hidden.
  final VoidCallback? onToggleMute;

  /// Called when the speaker toggle is tapped.
  /// When null, the speaker button is hidden.
  final VoidCallback? onToggleSpeaker;

  /// Called when the minimize / PiP button is tapped.
  /// When null, the minimize button is hidden.
  final VoidCallback? onMinimize;

  /// Creates an [OutgoingCallScreen].
  const OutgoingCallScreen({
    super.key,
    required this.callerName,
    this.callerAvatarUrl,
    this.callType = CallType.audio,
    this.theme = const CallTheme.whatsApp(),
    this.strings,
    this.callStatusText,
    this.isMuted = false,
    this.isSpeakerOn = false,
    required this.onEndCall,
    this.onToggleMute,
    this.onToggleSpeaker,
    this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    final s = strings ?? CallStrings.english();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar with minimize ──
            if (onMinimize != null)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onMinimize,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Tooltip(
                      message: s.pictureInPicture,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Caller info ──
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CallAvatar(
                      displayName: callerName,
                      avatarUrl: callerAvatarUrl,
                      radius: 50,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      callerName,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      callStatusText ?? s.calling,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Controls row ──
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onToggleSpeaker != null)
                    _ToggleButton(
                      icon: Icons.volume_up,
                      isActive: isSpeakerOn,
                      theme: theme,
                      onTap: onToggleSpeaker!,
                    ),
                  if (onToggleMute != null)
                    _ToggleButton(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      isActive: isMuted,
                      theme: theme,
                      onTap: onToggleMute!,
                    ),
                  GestureDetector(
                    onTap: onEndCall,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.endCallColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final CallTheme theme;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive
              ? theme.speakerActiveBackground
              : theme.buttonBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? theme.speakerActiveIconColor : theme.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}
