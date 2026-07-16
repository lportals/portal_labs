import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class _Message {
  final String sender;
  final String time;
  final String message;
  bool isRead;
  bool isMuted = false;

  _Message({
    required this.sender,
    required this.time,
    required this.message,
    this.isRead = false,
  });
}

class SwipeableActionTileShowcase extends StatefulWidget {
  const SwipeableActionTileShowcase({super.key});

  @override
  State<SwipeableActionTileShowcase> createState() =>
      _SwipeableActionTileShowcaseState();
}

class _SwipeableActionTileShowcaseState
    extends State<SwipeableActionTileShowcase> {
  int? _swipingIndex;
  
  // Track keys for all tiles to close others programmatically
  late final List<GlobalKey<SwipeableActionTileState>> _tileKeys = 
      List.generate(3, (_) => GlobalKey<SwipeableActionTileState>());

  // Local state for list of messages
  late final List<_Message> _messages = [
    _Message(
      sender: 'Design Team',
      time: '11:57 AM',
      message: 'Weekly sync notes are now available on Notion. Please review before...',
      isRead: false,
    ),
    _Message(
      sender: 'Alice Smith',
      time: '10:34 AM',
      message: 'Are we still on for lunch today? I was thinking we could try that new...',
      isRead: true,
    ),
    _Message(
      sender: 'Apple',
      time: 'Saturday',
      message: 'Your invoice #123456 is available. Thank you for your purchase from...',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Swipeable Action Tile',
      description:
          'A physics-based swipeable list tile that reveals custom actions with momentum and spring snapping.',
      codeSnippet: _codeSnippet,
      backgroundColor: const Color(0xFFF2F2F7), // Match AppBar to standard iOS light gray
      child: _messages.isEmpty
          ? const Center(
              child: Text(
                'No messages',
                style: TextStyle(color: Colors.black45, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Determine if dividers above/below should be hidden
                final showDividerAfter = _swipingIndex != index && _swipingIndex != (index + 1);
                final messageItem = _messages[index];

                return Column(
                  children: [
                    _buildMessageTile(
                      index: index,
                      messageItem: messageItem,
                    ),
                    if (index < _messages.length - 1)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: showDividerAfter ? 1.0 : 0.0,
                        child: const Divider(
                          color: Colors.black12,
                          height: 1,
                          thickness: 1,
                          indent: 76, // Starts exactly where the text content starts
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMessageTile({
    required int index,
    required _Message messageItem,
  }) {
    return SwipeableActionTile(
      key: _tileKeys[index],
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on message from ${messageItem.sender}'),
            duration: const Duration(milliseconds: 700),
          ),
        );
      },
      onSwipeStateChanged: (isSwiping) {
        setState(() {
          if (isSwiping) {
            _swipingIndex = index;
            // Close all other tiles when this one starts swiping
            for (int i = 0; i < _tileKeys.length; i++) {
              if (i != index) {
                _tileKeys[i].currentState?.close();
              }
            }
          } else if (_swipingIndex == index) {
            _swipingIndex = null;
          }
        });
      },
      style: const SwipeableActionTileStyle(
        cornerRadius: 16.0, // Rounded corners
        actionWidth: 54.0,  // 48px button + 6px spacing = 54.0 width
        idleCardColor: Color(0xFFF2F2F7), // Match list background
        cardColor: Colors.white,           // Slide into white background
        tileShadow: [
          BoxShadow(
            color: Color(0x0D000000), // Soft shadow
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      startActions: [
        SwipeAction(
          icon: Icon(
            messageItem.isRead ? Icons.mark_chat_unread_outlined : Icons.check_circle_outline,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
          label: messageItem.isRead ? 'Mark as unread' : 'Mark as read',
          onTap: () {
            setState(() {
              messageItem.isRead = !messageItem.isRead;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(messageItem.isRead ? 'Marked as read' : 'Marked as unread'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
      endActions: [
        SwipeAction(
          icon: Icon(
            messageItem.isMuted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
            color: Colors.white,
          ),
          backgroundColor: Colors.blueGrey,
          label: messageItem.isMuted ? 'Unmute' : 'Mute',
          onTap: () {
            setState(() {
              messageItem.isMuted = !messageItem.isMuted;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(messageItem.isMuted ? 'Notifications muted' : 'Notifications unmuted'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        SwipeAction(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          backgroundColor: Colors.red,
          label: 'Delete message',
          onTap: () {
            final sender = messageItem.sender;
            setState(() {
              _messages.removeAt(index);
              _swipingIndex = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted message from $sender'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
      child: Container(
        // Transparent container background so the parent container's dynamic color shows through
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            Container(
              width: 12,
              alignment: Alignment.center,
              child: !messageItem.isRead
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(width: 8, height: 8),
            ),
            const SizedBox(width: 4),
            // Avatar Placeholder
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(
                messageItem.isMuted ? Icons.notifications_off : Icons.person,
                color: Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        messageItem.sender,
                        style: const TextStyle(
                          color: Colors.black, // Dark text
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        messageItem.time,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    messageItem.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0),
              child: Icon(Icons.chevron_right, color: Colors.black26, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

const String _codeSnippet = '''
SwipeableActionTile(
  startActions: [
    SwipeAction(
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      backgroundColor: Colors.blue,
      onTap: () {
        // Mark as read
      },
    ),
  ],
  endActions: [
    SwipeAction(
      icon: const Icon(Icons.notifications_off_outlined, color: Colors.white),
      backgroundColor: Colors.blueAccent,
      onTap: () {
        // Mute
      },
    ),
    SwipeAction(
      icon: const Icon(Icons.delete_outline, color: Colors.white),
      backgroundColor: Colors.red,
      onTap: () {
        // Delete
      },
    ),
  ],
  child: Container(
    color: Colors.black,
    padding: const EdgeInsets.all(16),
    child: Text('Swipe me!'),
  ),
);
''';
