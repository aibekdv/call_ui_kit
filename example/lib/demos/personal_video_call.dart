import 'package:call_ui_kit/call_ui_kit.dart';
import 'package:flutter/material.dart';

class PersonalVideoCallDemo extends StatefulWidget {
  const PersonalVideoCallDemo({super.key});

  @override
  State<PersonalVideoCallDemo> createState() => _PersonalVideoCallDemoState();
}

class _PersonalVideoCallDemoState extends State<PersonalVideoCallDemo> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isScreenSharing = false;

  @override
  Widget build(BuildContext context) {
    return CallScreen(
      callerName: 'Alex Rivera',
      callerAvatarUrl: 'https://i.pravatar.cc/300?img=3',
      callType: CallType.video,
      localParticipant: const CallParticipant(
        id: 'local',
        displayName: 'You',
        isLocalUser: true,
      ),
      // Replace with real video widgets from your WebRTC / camera plugin
      localVideoWidget: Container(color: Colors.blueGrey),
      remoteVideoWidget: Container(color: Colors.teal),
      isMuted: _isMuted,
      isCameraOff: _isCameraOff,
      isSpeakerOn: _isSpeakerOn,
      isScreenSharing: _isScreenSharing,
      callStatusText: '04:23',
      onEndCall: () => Navigator.pop(context),
      onToggleMute: () => setState(() => _isMuted = !_isMuted),
      onToggleCamera: () => setState(() => _isCameraOff = !_isCameraOff),
      onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
      onFlipCamera: () => debugPrint('Flip camera'),
      onStopScreenShare: () => setState(() => _isScreenSharing = false),
      moreSheetBuilder: (context, theme) => _MoreSheetContent(
        theme: theme,
        isScreenSharing: _isScreenSharing,
        onToggleScreenShare: () {
          Navigator.pop(context);
          setState(() => _isScreenSharing = !_isScreenSharing);
        },
        onSendMessage: () {
          Navigator.pop(context);
          debugPrint('Send message');
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// More sheet content
// ---------------------------------------------------------------------------

class _MoreSheetContent extends StatelessWidget {
  final CallTheme theme;
  final bool isScreenSharing;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onSendMessage;

  const _MoreSheetContent({
    required this.theme,
    required this.isScreenSharing,
    required this.onToggleScreenShare,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.buttonBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              isScreenSharing ? 'Stop Screen Share' : 'Share Screen',
              style: TextStyle(color: theme.textPrimary),
            ),
            trailing: Icon(
              isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
              color: theme.textPrimary.withValues(alpha: 0.7),
            ),
            onTap: onToggleScreenShare,
          ),
          ListTile(
            title: Text(
              'Send Message',
              style: TextStyle(color: theme.textPrimary),
            ),
            trailing: Icon(
              Icons.message,
              color: theme.textPrimary.withValues(alpha: 0.7),
            ),
            onTap: onSendMessage,
          ),
        ],
      ),
    );
  }
}
