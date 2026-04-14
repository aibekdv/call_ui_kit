import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:call_ui_kit/call_ui_kit.dart';
import 'package:call_ui_kit/src/screens/layers/call_bottom_bar.dart';

Widget _app(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  const theme = CallTheme.whatsApp();
  final strings = CallStrings.englishDefaults;

  group('CallBottomBar', () {
    testWidgets('shows mute, speaker, and end call buttons', (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
        ),
      ));

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });

    testWidgets('shows mic_off icon when muted', (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: true,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
        ),
      ));

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('hides camera button when onToggleCamera is null',
        (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
          onToggleCamera: null,
        ),
      ));

      expect(find.byIcon(Icons.videocam), findsNothing);
      expect(find.byIcon(Icons.videocam_off), findsNothing);
    });

    testWidgets('shows camera button when onToggleCamera provided',
        (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isCameraOff: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
          onToggleCamera: () {},
        ),
      ));

      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('calls onEndCall and onResetHideTimer on end call tap',
        (tester) async {
      var endCallCalled = false;
      var resetCalled = false;

      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () => resetCalled = true,
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () => endCallCalled = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.call_end));
      expect(endCallCalled, true);
      expect(resetCalled, true);
    });

    testWidgets('calls onToggleMute on mute tap', (tester) async {
      var muteCalled = false;

      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () => muteCalled = true,
          onToggleSpeaker: () {},
          onEndCall: () {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.mic));
      expect(muteCalled, true);
    });

    testWidgets('buttons have semantic labels', (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
        ),
      ));

      // Check that Semantics widgets with labels exist
      expect(
        find.bySemanticsLabel(strings.mute),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(strings.endCall),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(strings.speaker),
        findsOneWidget,
      );
    });

    testWidgets('hides screen share button when callback is null',
        (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
          onToggleScreenShare: null,
        ),
      ));

      expect(find.byIcon(Icons.screen_share), findsNothing);
    });

    testWidgets('shows more button when onShowMore provided', (tester) async {
      await tester.pumpWidget(_app(
        CallBottomBar(
          theme: theme,
          strings: strings,
          isMuted: false,
          isSpeakerOn: false,
          onResetHideTimer: () {},
          onToggleMute: () {},
          onToggleSpeaker: () {},
          onEndCall: () {},
          onShowMore: () {},
        ),
      ));

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });
  });
}
