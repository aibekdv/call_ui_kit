import 'package:flutter/material.dart';

import 'demos/audio_screen_share.dart';
import 'demos/group_audio_call.dart';
import 'demos/group_screen_share.dart';
import 'demos/group_video_call.dart';
import 'demos/personal_audio_call.dart';
import 'demos/personal_video_call.dart';

void main() => runApp(const CallUiKitExample());

class CallUiKitExample extends StatelessWidget {
  const CallUiKitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call UI Kit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  static const _demos = <_DemoItem>[
    _DemoItem(
      icon: Icons.phone,
      title: 'Personal Audio Call',
      subtitle: 'WhatsApp theme — active audio call',
    ),
    _DemoItem(
      icon: Icons.videocam,
      title: 'Personal Video Call',
      subtitle: 'WhatsApp theme — active video call',
    ),
    _DemoItem(
      icon: Icons.group,
      title: 'Group Video Call (8 people)',
      subtitle: 'WhatsApp theme — random speaking',
    ),
    _DemoItem(
      icon: Icons.screen_share,
      title: 'Group Call + Screen Share',
      subtitle: 'WhatsApp theme — screen share layout',
    ),
    _DemoItem(
      icon: Icons.groups,
      title: 'Group Audio Call (5 people)',
      subtitle: 'WhatsApp theme — audio group call',
    ),
    _DemoItem(
      icon: Icons.screen_share_outlined,
      title: 'Audio Call + Screen Share',
      subtitle: 'WhatsApp theme — audio with screen share',
    ),
  ];

  static const _screens = <int, Widget Function()>{
    0: PersonalAudioCallDemo.new,
    1: PersonalVideoCallDemo.new,
    2: GroupVideoCallDemo.new,
    3: GroupScreenShareDemo.new,
    4: GroupAudioCallDemo.new,
    5: AudioScreenShareDemo.new,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call UI Kit Demo')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = _demos[index];
          return Card(
            child: ListTile(
              leading: Icon(demo.icon, size: 32),
              title: Text(demo.title),
              subtitle: Text(demo.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _screens[index]!()),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DemoItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DemoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
