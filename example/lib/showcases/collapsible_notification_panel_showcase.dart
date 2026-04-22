import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class CollapsibleNotificationPanelShowcase extends StatefulWidget {
  const CollapsibleNotificationPanelShowcase({super.key});

  @override
  State<CollapsibleNotificationPanelShowcase> createState() => _CollapsibleNotificationPanelShowcaseState();
}

class _CollapsibleNotificationPanelShowcaseState extends State<CollapsibleNotificationPanelShowcase> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Diego Sent a Message',
      description: '"Hey! Did you check the new spring animations?"',
      timestamp: 'Just Now',
      icon: Icons.chat_bubble_rounded,
      onTap: () {},
    ),
    NotificationItem(
      id: '2',
      title: 'New Interaction',
      description: 'Marcos and 4 others liked your recent post.',
      timestamp: '20m ago',
      icon: Icons.favorite_rounded,
      onTap: () {},
    ),
    NotificationItem(
      id: '3',
      title: 'Upcoming Event',
      description: 'Daily Sync: 10:30 AM starts in 15 minutes.',
      timestamp: '15m ago',
      icon: Icons.calendar_month_rounded,
      onTap: () {},
    ),
    NotificationItem(
      id: '4',
      title: 'Security Alert',
      description: 'Your verification code is 884-123. Use it to login.',
      timestamp: '1h ago',
      icon: Icons.lock_rounded,
      onTap: () {},
    ),
    NotificationItem(
      id: '5',
      title: 'System Update',
      description: 'Software Version 1.4.2 is ready to install.',
      timestamp: 'Yesterday',
      icon: Icons.settings_rounded,
      onTap: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Notification Center',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            CollapsibleNotificationPanel(
              items: _notifications,
              onItemTap: (item) {
                // Handle interaction
              },
            ),
          ],
        ),
      ),
    );
  }
}
