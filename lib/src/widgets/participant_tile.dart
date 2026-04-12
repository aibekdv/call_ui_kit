/// A tile widget that displays a single participant's video or avatar
/// with status overlays.
library;

import 'package:flutter/material.dart';

import '../models/call_participant.dart';
import '../models/call_strings.dart';
import '../models/call_theme.dart';
import 'call_avatar.dart';
import 'signal_strength_icon.dart';
import 'speaking_indicator.dart';

/// Displays a single call participant as a tile with layered overlays.
///
/// Shows the participant's live [CallParticipant.videoWidget] when available
/// and the camera is on, otherwise falls back to a circular avatar.
///
/// Overlays include a bottom gradient with name + speaking indicator,
/// mute icon, signal strength, screen-share badge, and an animated
/// speaking border.
class ParticipantTile extends StatefulWidget {
  /// The participant whose data drives this tile.
  final CallParticipant participant;

  /// The visual theme applied to the tile.
  final CallTheme theme;

  /// Localised strings.
  final CallStrings strings;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Creates a [ParticipantTile].
  const ParticipantTile({
    super.key,
    required this.participant,
    required this.theme,
    required this.strings,
    this.onTap,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile>
    with SingleTickerProviderStateMixin {
  AnimationController? _speakingController;
  Animation<double>? _speakingOpacity;

  void _ensureSpeakingController() {
    if (_speakingController != null) return;
    _speakingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _speakingOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _speakingController!, curve: Curves.easeInOut),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.participant.isSpeaking) {
      _ensureSpeakingController();
      _speakingController!.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.participant.isSpeaking) {
      _ensureSpeakingController();
      if (!_speakingController!.isAnimating) {
        _speakingController!.repeat(reverse: true);
      }
    } else if (_speakingController != null &&
        _speakingController!.isAnimating) {
      _speakingController!.stop();
      _speakingController!.value = 0.0;
    }
  }

  @override
  void dispose() {
    _speakingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.participant;
    final theme = widget.theme;
    final showVideo = p.videoWidget != null && !p.isCameraOff;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Video or avatar fallback
            if (showVideo)
              Positioned.fill(
                child: RepaintBoundary(child: p.videoWidget!),
              )
            else
              Container(
                color: theme.barBackground,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatar(p),
                      const SizedBox(height: 6),
                      Text(
                        p.displayName,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Layer 3: Bottom gradient (only when video is showing)
            if (showVideo)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.35,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Layer 4: Bottom-left — name + speaking indicator (only when video is showing)
            if (showVideo)
              Positioned(
                left: 8,
                right: p.isMuted ? 28 : 8,
                bottom: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        p.displayName,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isSpeaking) ...[
                      const SizedBox(width: 4),
                      SpeakingIndicator(
                        color: theme.speakingColor,
                        maxHeight: 12,
                        minHeight: 3,
                        barWidth: 2.5,
                      ),
                    ],
                  ],
                ),
              ),

            // Layer 5: Bottom-right — mic off
            if (p.isMuted)
              Positioned(
                right: 8,
                bottom: 8,
                child: Icon(
                  Icons.mic_off,
                  size: 14,
                  color: theme.textPrimary.withValues(alpha: 0.54),
                ),
              ),

            // Layer 6: Top-left — signal strength
            Positioned(
              left: 6,
              top: 6,
              child: SignalStrengthIcon(
                strength: p.signalStrength,
                size: 12,
              ),
            ),

            // Layer 7: Top-right — screen share
            if (p.isScreenSharing)
              Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.screen_share,
                  size: 14,
                  color: theme.textPrimary.withValues(alpha: 0.7),
                ),
              ),

            // Layer 8: Speaking border
            if (p.isSpeaking)
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _speakingOpacity!,
                  builder: (context, _) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.speakingColor.withValues(
                            alpha: _speakingOpacity!.value,
                          ),
                          width: 2.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(CallParticipant participant) {
    return CallAvatar(
      displayName: participant.displayName,
      avatarUrl: participant.avatarUrl,
      radius: 24,
      theme: widget.theme,
      id: participant.id,
    );
  }
}

