import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class MediaCollapsibleViewShowcase extends StatefulWidget {
  const MediaCollapsibleViewShowcase({super.key});

  @override
  State<MediaCollapsibleViewShowcase> createState() =>
      _MediaCollapsibleViewShowcaseState();
}

class _MediaCollapsibleViewShowcaseState
    extends State<MediaCollapsibleViewShowcase> {
  final List<MediaComment> _initialComments = [
    MediaComment(
      id: '1',
      userName: 'mr_whiskers',
      text: 'Meow meow, this UI is purrr-fect! 🐾',
      avatarUrl:
          'https://plus.unsplash.com/premium_photo-1667030474693-6d0632f97029?q=80&w=987&auto=format&fit=crop',
      createdAt: DateTime.now(),
    ),
    MediaComment(
      id: '2',
      userName: 'tuna_lover_99',
      text: 'I pushed my food bowl off the table while watching this. Worth it. 🥛',
      avatarUrl:
          'https://images.unsplash.com/photo-1561948955-570b270e7c36?q=80&w=901&auto=format&fit=crop',
      createdAt: DateTime.now(),
    ),
    MediaComment(
      id: '3',
      userName: 'calico_queen',
      text: "Where is the red dot? I've been staring at the screen for hours! 🔴",
      avatarUrl:
          'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?q=80&w=1335&auto=format&fit=crop',
      createdAt: DateTime.now(),
    ),
    MediaComment(
      id: '4',
      userName: 'grumpy_garfield',
      text: 'Hiss... too much scrolling, not enough lasagna. 😾',
      avatarUrl:
          'https://images.unsplash.com/photo-1571566882372-1598d88abd90?q=80&w=987&auto=format&fit=crop',
      createdAt: DateTime.now(),
    ),
  ];

  late List<MediaComment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(_initialComments);
  }

  void _addNewComment(String text) {
    setState(() {
      _comments.insert(
        0,
        MediaComment(
          id: DateTime.now().toString(),
          userName: 'You (Cat)',
          text: text,
          avatarUrl:
              'https://images.unsplash.com/photo-1543852786-1cf6624b9987?q=80&w=987&auto=format&fit=crop',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // hasAppBar: false — MediaCollapsibleView is a full-screen immersive
    // component. The ⓘ and back buttons float as overlays instead.
    return ShowcaseShell(
      title: 'Media Collapsible View',
      description:
          'A Reels-inspired component with fluid coordinate scaling between '
          'full-screen media and a gesture-driven comment sheet. Features '
          'dual-phase gesture handover and dynamic background blur layering '
          'without GPU overhead.',
      codeSnippet: '''MediaCollapsibleView(
  mediaUrl: 'https://example.com/thumbnail.jpg',
  userAvatarUrl: 'https://example.com/avatar.jpg',
  comments: _comments,
  style: MediaViewStyle(
    accentColor: Colors.blueAccent,
    sheetBackgroundColor: Color(0xFF141416),
  ),
  onSendComment: (text) => _addComment(text),
)''',
      hasAppBar: false,
      showBackButton: false,
      child: MediaCollapsibleView(
        mediaUrl:
            "https://media2.giphy.com/media/v1.Y2lkPTZjMDliOTUyMTU3MnZhMnhja2t3dGFzcjBpcGt5bDZ0MGU0Zm1vNm40Nmp0azhnNSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/VbnUQpnihPSIgIXuZv/giphy.gif",
        userAvatarUrl:
            'https://plus.unsplash.com/premium_photo-1667030474693-6d0632f97029?q=80&w=987&auto=format&fit=crop',
        comments: _comments,
        style: const MediaViewStyle(
          sheetBackgroundColor: Color(0xFF0F0F12),
          accentColor: Color(0xFF3B82F6),
          blurAmount: 60,
        ),
        onSendComment: _addNewComment,
        onLike: () {},
      ),
    );
  }
}
