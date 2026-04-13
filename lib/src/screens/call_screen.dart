/// The unified call screen handling personal audio, personal video,
/// and group video calls.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../models/call_participant.dart';
import '../models/call_strings.dart';
import '../models/call_theme.dart';
import '../models/call_type.dart';
import '../widgets/floating_pip_view.dart';
import '../widgets/more_bottom_sheet.dart';
import '../widgets/participants_panel.dart';
import '../widgets/screen_share_banner.dart';
import 'layers/call_bottom_bar.dart';
import 'layers/call_right_buttons.dart';
import 'layers/call_top_bar.dart';
import 'layers/call_video_content.dart';

/// A single call screen widget that adapts to personal audio, personal video,
/// and group video calls based on the provided configuration.
///
/// The layout is a five-layer [Stack]:
/// 1. Video content (always visible)
/// 2. Top app bar (auto-hide)
/// 3. Right side floating buttons (auto-hide)
/// 4. Local PiP view (always visible)
/// 5. Bottom controls bar (auto-hide)
///
/// Controls auto-hide after 4 seconds and reappear on screen tap,
/// matching WhatsApp behaviour.
class CallScreen extends StatefulWidget {
  // ── Identity ──

  /// The caller or group name displayed in the top bar.
  final String callerName;

  /// Optional avatar URL for the caller.
  final String? callerAvatarUrl;

  /// Whether this is a group call with multiple participants.
  final bool isGroupCall;

  /// The type of call (audio or video).
  final CallType callType;

  // ── Participants (group call) ──

  /// All remote participants in a group call.
  final List<CallParticipant> participants;

  /// The local participant.
  final CallParticipant localParticipant;

  // ── Video widgets ──

  /// The widget displaying the local camera stream.
  final Widget? localVideoWidget;

  /// The widget displaying the remote camera stream (personal call).
  final Widget? remoteVideoWidget;

  /// The widget displaying a remote screen share stream.
  final Widget? screenShareWidget;

  // ── State ──

  /// Whether the local microphone is muted.
  final bool isMuted;

  /// Whether the local camera is turned off.
  final bool isCameraOff;

  /// Whether the speaker is active (vs earpiece).
  final bool isSpeakerOn;

  /// Whether the local user is sharing their screen.
  final bool isScreenSharing;

  /// Whether the local user has raised their hand.
  final bool isHandRaised;

  // ── Config ──

  /// Whether to show the encryption label in the more sheet.
  final bool showEncryptionLabel;

  /// The visual theme. Defaults to [CallTheme.whatsApp].
  final CallTheme theme;

  /// Localised strings. Defaults to [CallStrings.english] when null.
  final CallStrings? strings;

  /// Optional call status text override (e.g. "Calling...", "04:23").
  /// If null, shows [strings.calling].
  final String? callStatusText;

  // ── Callbacks ──

  /// Called when the end-call button is tapped.
  final VoidCallback onEndCall;

  /// Called when the mute toggle is tapped.
  final VoidCallback onToggleMute;

  /// Called when the camera toggle is tapped.
  /// When null, the camera toggle button is hidden.
  final VoidCallback? onToggleCamera;

  /// Called when the speaker toggle is tapped.
  final VoidCallback onToggleSpeaker;

  /// Called when the flip-camera button is tapped.
  /// When null, the flip-camera button is hidden.
  final VoidCallback? onFlipCamera;

  /// Called when the screen-share button in the bottom bar is tapped.
  /// When null, the screen-share button is hidden from the bottom bar.
  final VoidCallback? onToggleScreenShare;

  /// Called when "Stop" is tapped on the screen-share banner.
  final VoidCallback? onStopScreenShare;

  /// Called when the add-participant button is tapped.
  /// When null, the add-participant button is hidden.
  final VoidCallback? onAddParticipant;

  /// Called when the effects button is tapped.
  /// When null, the effects button is hidden.
  final VoidCallback? onEffects;

  /// Builds custom content for the "more" bottom sheet.
  /// When provided, the builder receives [BuildContext] and [CallTheme]
  /// and should return the widget(s) to display in the sheet body.
  /// When null, the "more" button is hidden from the bottom bar.
  final Widget Function(BuildContext context, CallTheme theme)?
      moreSheetBuilder;

  /// Called when the minimize / PiP button is tapped.
  /// When null, the minimize button is hidden.
  final VoidCallback? onMinimize;

  /// Called when the raise-hand button is tapped.
  final VoidCallback? onRaiseHand;

  /// Called when the host mutes a participant.
  final void Function(CallParticipant)? onMuteParticipant;

  /// Called when the host taps "Mute all".
  ///
  /// When provided, this is called instead of invoking [onMuteParticipant]
  /// for each unmuted participant, allowing the host app to batch the
  /// state update into a single operation.
  final VoidCallback? onMuteAll;

  /// Called when the host removes a participant.
  final void Function(CallParticipant)? onRemoveParticipant;

  /// Creates a [CallScreen].
  const CallScreen({
    super.key,
    required this.callerName,
    this.callerAvatarUrl,
    this.isGroupCall = false,
    this.callType = CallType.video,
    this.participants = const [],
    required this.localParticipant,
    this.localVideoWidget,
    this.remoteVideoWidget,
    this.screenShareWidget,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = false,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.showEncryptionLabel = true,
    this.theme = const CallTheme.whatsApp(),
    this.strings,
    this.callStatusText,
    required this.onEndCall,
    required this.onToggleMute,
    this.onToggleCamera,
    required this.onToggleSpeaker,
    this.onFlipCamera,
    this.onToggleScreenShare,
    this.onStopScreenShare,
    this.onAddParticipant,
    this.onEffects,
    this.moreSheetBuilder,
    this.onMinimize,
    this.onRaiseHand,
    this.onMuteParticipant,
    this.onMuteAll,
    this.onRemoveParticipant,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ValueNotifier<bool> _controlsVisible = ValueNotifier(true);
  final ValueNotifier<bool> _isSwapped = ValueNotifier(false);
  Timer? _hideTimer;
  late CallStrings _strings;
  String? _screenSharerName;

  void _resolveStrings() {
    _strings = widget.strings ?? CallStrings.englishDefaults;
  }

  void _resolveScreenSharer() {
    _screenSharerName = null;
    for (final p in widget.participants) {
      if (p.isScreenSharing) {
        _screenSharerName = p.displayName;
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveStrings();
    _resolveScreenSharer();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant CallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strings != widget.strings) {
      _resolveStrings();
    }
    if (oldWidget.participants != widget.participants ||
        oldWidget.isScreenSharing != widget.isScreenSharing) {
      _resolveScreenSharer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controlsVisible.dispose();
    _isSwapped.dispose();
    super.dispose();
  }

  void _onScreenTap() {
    _controlsVisible.value = !_controlsVisible.value;
    _hideTimer?.cancel();
    if (_controlsVisible.value) {
      _startHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _controlsVisible.value = false;
    });
  }

  void _showMoreBottomSheet() {
    if (widget.moreSheetBuilder == null) return;
    _resetHideTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoreBottomSheet(
        theme: widget.theme,
        strings: _strings,
        showEncryptionLabel: widget.showEncryptionLabel,
        child: widget.moreSheetBuilder!(ctx, widget.theme),
      ),
    );
  }

  void _showParticipantsPanel() {
    final allParticipants = [widget.localParticipant, ...widget.participants];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ParticipantsPanel(
        participants: allParticipants,
        isLocalHost: widget.localParticipant.isHost,
        theme: widget.theme,
        strings: _strings,
        onMuteParticipant: widget.onMuteParticipant,
        onMuteAll: widget.onMuteAll,
        onRemoveParticipant: widget.onRemoveParticipant,
        onInvite: widget.onAddParticipant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.paddingOf(context);
    final screenSize = MediaQuery.sizeOf(context);
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1 — Video content (tap here toggles controls)
            Positioned.fill(
              child: GestureDetector(
                onTap: _onScreenTap,
                behavior: HitTestBehavior.opaque,
                child: RepaintBoundary(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSwapped,
                    builder: (context, swapped, _) => CallVideoContent(
                      theme: theme,
                      strings: _strings,
                      isGroupCall: widget.isGroupCall,
                      callerName: widget.callerName,
                      callerAvatarUrl: widget.callerAvatarUrl,
                      participants: widget.participants,
                      localParticipant: widget.localParticipant,
                      remoteVideoWidget: swapped
                          ? widget.localVideoWidget
                          : widget.remoteVideoWidget,
                      screenShareWidget: widget.screenShareWidget,
                      isCameraOff: widget.isCameraOff,
                      onShowParticipantsPanel: _showParticipantsPanel,
                    ),
                  ),
                ),
              ),
            ),

            // Screen share banner
            if (widget.isScreenSharing || widget.screenShareWidget != null)
              Positioned(
                top: safeArea.top,
                left: safeArea.left,
                right: safeArea.right,
                child: ScreenShareBanner(
                  isLocalSharing: widget.isScreenSharing,
                  sharerName: widget.isScreenSharing ? null : _screenSharerName,
                  theme: theme,
                  strings: _strings,
                  onStop:
                      widget.isScreenSharing ? widget.onStopScreenShare : null,
                ),
              ),

            // Layer 2 — Top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _controlsVisible,
                builder: (context, visible, child) => IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                ),
                child: CallTopBar(
                  safeArea: safeArea,
                  theme: theme,
                  strings: _strings,
                  callerName: widget.callerName,
                  callStatusText: widget.callStatusText,
                  callType: widget.callType,
                  isGroupCall: widget.isGroupCall,
                  participantCount: widget.participants.length + 1,
                  onResetHideTimer: _resetHideTimer,
                  onFlipCamera: widget.onFlipCamera,
                  onMinimize: widget.onMinimize,
                ),
              ),
            ),

            // Layer 3 — Right side floating buttons
            Positioned(
              top: 100 + safeArea.top,
              right: 12 + safeArea.right,
              child: ValueListenableBuilder<bool>(
                valueListenable: _controlsVisible,
                builder: (context, visible, child) => IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                ),
                child: CallRightButtons(
                  theme: theme,
                  strings: _strings,
                  onAddParticipant: widget.onAddParticipant,
                  onEffects: widget.onEffects,
                  onResetHideTimer: _resetHideTimer,
                ),
              ),
            ),

            // Layer 4 — Local PiP view (video calls only)
            if (widget.callType == CallType.video &&
                (!widget.isGroupCall || widget.participants.length <= 1))
              ValueListenableBuilder<bool>(
                valueListenable: _isSwapped,
                builder: (context, swapped, _) => FloatingPipView(
                  displayName: swapped
                      ? widget.callerName
                      : widget.localParticipant.displayName,
                  theme: theme,
                  strings: _strings,
                  screenSize: screenSize,
                  topBarHeight: safeArea.top + 80,
                  controlsHeight: safeArea.bottom + 100,
                  safeAreaLeft: safeArea.left,
                  safeAreaRight: safeArea.right,
                  safeAreaTop: safeArea.top,
                  safeAreaBottom: safeArea.bottom,
                  controlsVisible: _controlsVisible,
                  onTap: () => _isSwapped.value = !_isSwapped.value,
                  child: widget.isCameraOff
                      ? null
                      : swapped
                          ? widget.remoteVideoWidget
                          : widget.localVideoWidget,
                ),
              ),

            // Layer 5 — Bottom controls bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _controlsVisible,
                builder: (context, visible, child) => IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                ),
                child: CallBottomBar(
                  safeArea: safeArea,
                  theme: theme,
                  isMuted: widget.isMuted,
                  isCameraOff: widget.isCameraOff,
                  isSpeakerOn: widget.isSpeakerOn,
                  onResetHideTimer: _resetHideTimer,
                  onShowMore: widget.moreSheetBuilder != null
                      ? _showMoreBottomSheet
                      : null,
                  onToggleMute: widget.onToggleMute,
                  onToggleCamera: widget.onToggleCamera,
                  onToggleScreenShare: widget.onToggleScreenShare,
                  isScreenSharing: widget.isScreenSharing,
                  onToggleSpeaker: widget.onToggleSpeaker,
                  onEndCall: widget.onEndCall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
