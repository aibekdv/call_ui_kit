# call_ui_kit

A ready-to-use Flutter call UI kit that handles personal audio calls, personal video calls, and group calls. Zero external dependencies — only Flutter SDK.

Inspired by WhatsApp call design. Fully customizable through themes and localized strings.

## Screenshots

<p float="left">
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/personal_audio_call.png" width="200" />
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/personal_video_call.png" width="200" />
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/screen_share.png" width="200" />
</p>
<p float="left">
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/group_more_sheet.png" width="200" />
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/speaker_view.png" width="200" />
  <img src="https://raw.githubusercontent.com/aibekdv/call_ui_kit/main/screenshots/speaker_view_speaking.png" width="200" />
</p>

| Screenshot | Description |
|------------|-------------|
| Personal Audio Call | 1:1 audio call with caller avatar, status text, and controls |
| Personal Video Call | 1:1 video call with draggable PiP, flip camera, and more sheet |
| Screen Share | Group call with screen sharing and participant thumbnails |
| More Sheet | Customizable bottom sheet with encryption label |
| Speaker View | 7+ participants — active speaker prominent with thumbnail row |
| Speaking Border | Animated green border on the active speaker's tile |

## Features

- **Personal audio call** — caller avatar, call status, speaker toggle
- **Personal video call** — remote/local video, draggable PiP, camera flip, swap on tap
- **Group video call** — adaptive grid (2x2, 2x3), speaker view (7+ participants), thumbnail row
- **Group audio call** — participant tiles with avatars, speaking indicators
- **Screen sharing** — dedicated layout with screen share banner and stop button
- **Auto-hide controls** — top bar, bottom bar, and side buttons hide after 4 seconds
- **Participants panel** — draggable bottom sheet with host actions (mute, remove)
- **"More" bottom sheet** — customizable actions sheet with encryption label
- **Full localization** — every user-facing string is configurable via `CallStrings`
- **Full theming** — every color is configurable via `CallTheme`
- **Speaking indicators** — animated sine-wave bars and glowing tile borders
- **Signal strength** — 4-level indicator per participant
- **PiP view** — draggable, corner-snapping, responsive to safe areas

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  call_ui_kit: 0.2.0
```

## Quick Start

### Personal Audio Call

```dart
CallScreen(
  callerName: 'Sarah Johnson',
  callerAvatarUrl: 'https://example.com/avatar.jpg',
  callType: CallType.audio,
  localParticipant: const CallParticipant(
    id: 'local',
    displayName: 'You',
    isLocalUser: true,
  ),
  isMuted: _isMuted,
  isSpeakerOn: _isSpeakerOn,
  callStatusText: '02:45',
  onEndCall: () => Navigator.pop(context),
  onToggleMute: () => setState(() => _isMuted = !_isMuted),
  onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
)
```

### Personal Video Call

```dart
CallScreen(
  callerName: 'Alex Rivera',
  callerAvatarUrl: 'https://example.com/avatar.jpg',
  callType: CallType.video,
  localParticipant: const CallParticipant(
    id: 'local',
    displayName: 'You',
    isLocalUser: true,
  ),
  localVideoWidget: localVideoView,   // your camera widget
  remoteVideoWidget: remoteVideoView, // remote camera widget
  isMuted: _isMuted,
  isCameraOff: _isCameraOff,
  isSpeakerOn: _isSpeakerOn,
  callStatusText: '04:23',
  onEndCall: () => Navigator.pop(context),
  onToggleMute: () => setState(() => _isMuted = !_isMuted),
  onToggleCamera: () => setState(() => _isCameraOff = !_isCameraOff),
  onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
  onFlipCamera: () => /* flip camera logic */,
)
```

### Group Video Call

```dart
CallScreen(
  callerName: 'Team Meeting',
  isGroupCall: true,
  callType: CallType.video,
  localParticipant: const CallParticipant(
    id: 'local',
    displayName: 'You',
    isLocalUser: true,
    isHost: true,
  ),
  participants: [
    CallParticipant(
      id: '2',
      displayName: 'Alex Rivera',
      avatarUrl: 'https://example.com/alex.jpg',
      videoWidget: alexVideoView, // or null if camera off
      isSpeaking: true,
    ),
    CallParticipant(
      id: '3',
      displayName: 'Priya Sharma',
      avatarUrl: 'https://example.com/priya.jpg',
      isMuted: true,
      isCameraOff: true,
    ),
    // ... more participants
  ],
  isMuted: _isMuted,
  isCameraOff: _isCameraOff,
  isSpeakerOn: _isSpeakerOn,
  callStatusText: '12:07',
  onEndCall: () => Navigator.pop(context),
  onToggleMute: () => setState(() => _isMuted = !_isMuted),
  onToggleCamera: () => setState(() => _isCameraOff = !_isCameraOff),
  onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
  onAddParticipant: () => /* invite logic */,
  onMuteParticipant: (p) => /* mute participant */,
  onRemoveParticipant: (p) => /* remove participant */,
)
```

### Screen Sharing

```dart
CallScreen(
  callerName: 'Design Review',
  isGroupCall: true,
  callType: CallType.video,
  localParticipant: localParticipant,
  participants: participants,
  screenShareWidget: screenShareView, // the shared screen widget
  isScreenSharing: _isLocalSharing,
  onStopScreenShare: () => setState(() => _isLocalSharing = false),
  // ... other required params
)
```

## API Reference

### CallScreen

The main widget. All UI is driven by the parameters you pass — the kit does not manage call state.

#### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callerName` | `String` | Caller or group name shown in the top bar |
| `localParticipant` | `CallParticipant` | The local user's participant data |
| `onEndCall` | `VoidCallback` | Called when end-call button is tapped |
| `onToggleMute` | `VoidCallback` | Called when mute button is tapped |
| `onToggleSpeaker` | `VoidCallback` | Called when speaker button is tapped |

#### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `callerAvatarUrl` | `String?` | `null` | Avatar URL for the caller |
| `isGroupCall` | `bool` | `false` | Enables group call layout |
| `callType` | `CallType` | `CallType.video` | `.audio` or `.video` |
| `participants` | `List<CallParticipant>` | `[]` | Remote participants (group call) |
| `localVideoWidget` | `Widget?` | `null` | Local camera stream widget |
| `remoteVideoWidget` | `Widget?` | `null` | Remote camera stream widget (personal call) |
| `screenShareWidget` | `Widget?` | `null` | Screen share stream widget |
| `isMuted` | `bool` | `false` | Local mic muted state |
| `isCameraOff` | `bool` | `false` | Local camera off state |
| `isSpeakerOn` | `bool` | `false` | Speaker active state |
| `isScreenSharing` | `bool` | `false` | Local screen sharing state |
| `isHandRaised` | `bool` | `false` | Local hand raised state |
| `showEncryptionLabel` | `bool` | `true` | Show encryption label in "more" sheet |
| `theme` | `CallTheme` | `CallTheme.whatsApp()` | Color theme |
| `strings` | `CallStrings?` | `null` (English defaults) | Localized strings |
| `callStatusText` | `String?` | `null` | Status text override (e.g. "02:45") |

#### Optional Callbacks

All optional callbacks — when `null`, the corresponding button is hidden.

| Callback | Type | Description |
|----------|------|-------------|
| `onToggleCamera` | `VoidCallback?` | Camera toggle button |
| `onFlipCamera` | `VoidCallback?` | Flip camera button (top bar) |
| `onToggleScreenShare` | `VoidCallback?` | Screen share button (bottom bar) |
| `onStopScreenShare` | `VoidCallback?` | Stop button on screen share banner |
| `onAddParticipant` | `VoidCallback?` | Add participant button (right side) |
| `onEffects` | `VoidCallback?` | Effects button (right side) |
| `onMinimize` | `VoidCallback?` | Minimize/PiP button (top bar) |
| `onRaiseHand` | `VoidCallback?` | Raise hand button |
| `onMuteParticipant` | `void Function(CallParticipant)?` | Host mutes a participant |
| `onRemoveParticipant` | `void Function(CallParticipant)?` | Host removes a participant |
| `moreSheetBuilder` | `Widget Function(BuildContext, CallTheme)?` | Custom "more" sheet content |

### CallParticipant

Immutable data model for a single participant. Supports `copyWith()` and proper equality (`==`/`hashCode`).

```dart
const CallParticipant({
  required String id,
  required String displayName,
  String? avatarUrl,
  bool isMuted = false,
  bool isCameraOff = false,
  bool isSpeaking = false,
  bool isScreenSharing = false,
  bool isHost = false,
  bool isLocalUser = false,
  SignalStrength signalStrength = SignalStrength.excellent,
  Widget? videoWidget,
  Widget? screenShareWidget,
})
```

| Field | Description |
|-------|-------------|
| `id` | Unique identifier for the participant |
| `displayName` | Name shown on tile and in participant list |
| `avatarUrl` | Network image URL; falls back to colored initials |
| `isMuted` | Shows mute icon on tile |
| `isCameraOff` | Shows avatar instead of video |
| `isSpeaking` | Activates animated speaking border and indicator |
| `isScreenSharing` | Shows screen share badge |
| `isHost` | Shows host badge; enables host actions in panel |
| `isLocalUser` | Marks as local user |
| `signalStrength` | `.excellent`, `.good`, `.poor`, or `.none` |
| `videoWidget` | The live video stream widget |
| `screenShareWidget` | The screen share stream widget |

### CallTheme

Controls all colors. Use `CallTheme.whatsApp()` as a starting point and `copyWith()` to customize.

```dart
CallTheme(
  background: Color(0xFF000000),
  barBackground: Color(0xFF1C1C1E),
  buttonBackground: Color(0xFF2C2C2E),
  endCallColor: Color(0xFFE53935),
  speakingColor: Color(0xFF25D366),
  speakerActiveBackground: Colors.white,
  speakerActiveIconColor: Colors.black,
  textPrimary: Colors.white,
  textSecondary: Color(0xFFAAAAAA),
  dividerColor: Color(0xFF3A3A3C),
)
```

Custom theme example:

```dart
final myTheme = const CallTheme.whatsApp().copyWith(
  endCallColor: Colors.red,
  speakingColor: Colors.blue,
);
```

### CallStrings

Every user-facing string is configurable. Use `CallStrings.english()` as default, or provide your own for localization.

```dart
CallStrings(
  calling: 'Calling...',
  cameraIsOff: 'Camera is off',
  you: 'You',
  endToEndEncrypted: 'End-to-end encrypted',
  shareScreen: 'Share screen',
  sendMessage: 'Send message',
  participants: 'Participants',
  shareCallLink: 'Share call link',
  cancel: 'Cancel',
  stop: 'Stop',
  youAreSharingYourScreen: 'You are sharing your screen',
  speaking: 'Speaking',
  muted: 'Muted',
  muteAll: 'Mute all',
  invite: 'Invite',
  mute: 'Mute',
  unmute: 'Unmute',
  removeFromCall: 'Remove from call',
  pictureInPicture: 'Picture in picture',
  addParticipant: 'Add participant',
  flipCamera: 'Flip camera',
  effects: 'Effects',
  isSharingScreen: (name) => '$name is sharing their screen',
  participantsCount: (count) => '$count participant${count == 1 ? '' : 's'}',
  moreParticipants: (count) => '+$count more',
)
```

### CallType

```dart
enum CallType { audio, video }
```

### SignalStrength

```dart
enum SignalStrength { excellent, good, poor, none }
```

## Group Call Layouts

The layout is automatically resolved based on participant count:

| Participants | Layout |
|-------------|--------|
| 1-2 | Full screen + PiP |
| 3-4 | 2x2 grid |
| 5-6 | 2x3 grid |
| 7+ | Speaker view (active speaker + thumbnail row) |
| Any + screen share | Screen share view + thumbnail row |

## "More" Bottom Sheet

The `moreSheetBuilder` callback lets you add custom actions to the "more" bottom sheet. The kit wraps your content with a handle bar, encryption label, and cancel button.

```dart
CallScreen(
  // ...
  moreSheetBuilder: (context, theme) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: theme.buttonBackground,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        ListTile(
          title: Text('Share Screen', style: TextStyle(color: theme.textPrimary)),
          trailing: Icon(Icons.screen_share, color: theme.textPrimary),
          onTap: () {
            Navigator.pop(context);
            // your logic
          },
        ),
        ListTile(
          title: Text('Send Message', style: TextStyle(color: theme.textPrimary)),
          trailing: Icon(Icons.message, color: theme.textPrimary),
          onTap: () {
            Navigator.pop(context);
            // your logic
          },
        ),
      ],
    ),
  ),
)
```

## Exported Widgets

These widgets are exported for standalone use if needed:

| Widget | Description |
|--------|-------------|
| `CallAvatar` | Circle avatar with network image or colored initials fallback |
| `ParticipantTile` | Single participant tile with video, overlays, and speaking border |
| `FloatingPipView` | Draggable picture-in-picture overlay that snaps to corners |
| `SpeakingIndicator` | Animated 3-bar sine-wave speaking indicator |
| `ScreenShareBanner` | Slide-in banner for screen sharing status |
| `MoreBottomSheet` | Bottom sheet with handle bar, encryption label, and cancel button |
| `ParticipantsPanel` | Draggable scrollable participant list with host actions |
| `SignalStrengthIcon` | 4-bar signal strength indicator |

## Exported Utilities

| Utility | Description |
|---------|-------------|
| `GroupCallLayoutResolver` | Resolves grid layout mode based on participant count |
| `PipSnapCalculator` | Calculates nearest corner snap position for PiP view |

## Requirements

- Flutter SDK >= 3.29.0
- Dart SDK >= 3.11.3

## License

See [LICENSE](LICENSE) file.
