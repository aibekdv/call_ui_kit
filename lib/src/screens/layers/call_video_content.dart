/// The main video / avatar content layer for the call screen.
library;

import 'package:flutter/material.dart';

import '../../models/call_participant.dart';
import '../../models/call_strings.dart';
import '../../models/call_theme.dart';
import '../../utils/group_call_layout_resolver.dart';
import '../../widgets/call_avatar.dart';
import '../../widgets/participant_tile.dart';
import '../../widgets/thumbnail_row.dart';

/// Renders the appropriate video layout based on call type and participant count.
///
/// For personal calls: shows remote video or an avatar fallback.
/// For group calls: resolves layout via [GroupCallLayoutResolver] and renders
/// grid, speaker view, or screen-share view accordingly.
class CallVideoContent extends StatelessWidget {
  final CallTheme theme;
  final CallStrings strings;
  final bool isGroupCall;
  final String callerName;
  final String? callerAvatarUrl;
  final List<CallParticipant> participants;
  final CallParticipant localParticipant;
  final Widget? remoteVideoWidget;
  final Widget? screenShareWidget;
  final bool isCameraOff;
  final VoidCallback onShowParticipantsPanel;

  const CallVideoContent({
    super.key,
    required this.theme,
    required this.strings,
    required this.isGroupCall,
    required this.callerName,
    this.callerAvatarUrl,
    required this.participants,
    required this.localParticipant,
    this.remoteVideoWidget,
    this.screenShareWidget,
    required this.isCameraOff,
    required this.onShowParticipantsPanel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isGroupCall) {
      return _buildPersonalCallContent();
    }

    final totalCount = participants.length + 1;
    final hasScreenShare = screenShareWidget != null;
    final layout = GroupCallLayoutResolver.resolve(
      totalCount: totalCount,
      hasScreenShare: hasScreenShare,
    );

    Widget content;
    switch (layout) {
      case GroupCallLayoutMode.fullScreenPip:
        return _buildPersonalCallContent();
      case GroupCallLayoutMode.grid2x2:
        content = _buildGrid(2, 2);
      case GroupCallLayoutMode.grid2x3:
        content = _buildGrid(2, 3);
      case GroupCallLayoutMode.speakerView:
        content = _buildSpeakerView();
      case GroupCallLayoutMode.screenShare:
        content = _buildScreenShareView();
    }

    return SafeArea(child: content);
  }

  Widget _buildPersonalCallContent() {
    final hasRemoteVideo = remoteVideoWidget != null && !isCameraOff;

    if (isGroupCall && participants.isNotEmpty) {
      final remote = participants.first;
      if (remote.videoWidget != null && !remote.isCameraOff) {
        return Positioned.fill(child: remote.videoWidget!);
      }
    }

    if (hasRemoteVideo) {
      return remoteVideoWidget!;
    }

    return Container(
      color: theme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CallAvatar(
              displayName: callerName,
              avatarUrl: callerAvatarUrl,
              radius: 40,
              theme: theme,
              backgroundColor: theme.buttonBackground,
              fontSize: 80 * 0.35,
            ),
            const SizedBox(height: 12),
            Text(
              callerName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isCameraOff) ...[
              const SizedBox(height: 4),
              Text(
                strings.cameraIsOff,
                style: TextStyle(
                  color: theme.textPrimary.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int columns, int maxRows) {
    final allParticipants = [
      ...participants,
      localParticipant,
    ];
    final count = allParticipants.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleCount = count.clamp(0, columns * maxRows);
        final rows = (visibleCount / columns).ceil().clamp(1, maxRows);
        final tileHeight = constraints.maxHeight / rows;
        final colWidth = constraints.maxWidth / columns;

        return Stack(
          children: List.generate(visibleCount, (index) {
            final p = allParticipants[index];
            final spanFullWidth = columns == 2 && count == 3 && index == 0;
            final tileWidth = spanFullWidth ? constraints.maxWidth : colWidth;

            // For the 3-participant special case: first tile is full-width row 0,
            // remaining tiles are in row 1.
            final int col;
            final int row;
            if (spanFullWidth) {
              col = 0;
              row = 0;
            } else if (columns == 2 && count == 3 && index > 0) {
              col = index - 1;
              row = 1;
            } else {
              col = index % columns;
              row = index ~/ columns;
            }

            return Positioned(
              key: ValueKey(p.id),
              left: col * colWidth,
              top: row * tileHeight,
              width: tileWidth - 1,
              height: tileHeight - 1,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: ParticipantTile(
                  participant: p,
                  theme: theme,
                  strings: strings,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSpeakerView() {
    final activeSpeaker =
        participants.cast<CallParticipant?>().firstWhere(
              (p) => p!.isSpeaking,
              orElse: () =>
                  participants.isNotEmpty ? participants.first : null,
            );

    final thumbnailParticipants = participants
        .where((p) => p.id != activeSpeaker?.id)
        .toList()
      ..add(localParticipant);

    return Column(
      children: [
        Expanded(
          flex: 65,
          child: activeSpeaker != null
              ? ParticipantTile(
                  participant: activeSpeaker,
                  theme: theme,
                  strings: strings,
                )
              : Container(color: theme.background),
        ),
        ThumbnailRow(
          participants: thumbnailParticipants,
          theme: theme,
          strings: strings,
          maxVisible: 6,
          onShowMore: onShowParticipantsPanel,
        ),
      ],
    );
  }

  Widget _buildScreenShareView() {
    final thumbnailParticipants = [
      ...participants,
      localParticipant,
    ];

    return Column(
      children: [
        Expanded(
          flex: 65,
          child: Container(
            color: const Color(0xFF0A0A0A),
            child: screenShareWidget ?? const SizedBox.expand(),
          ),
        ),
        ThumbnailRow(
          participants: thumbnailParticipants,
          theme: theme,
          strings: strings,
          maxVisible: 6,
          onShowMore: onShowParticipantsPanel,
        ),
      ],
    );
  }
}
