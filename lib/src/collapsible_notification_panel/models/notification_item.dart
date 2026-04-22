import 'package:flutter/material.dart';

/// Represents a single notification item in the [CollapsibleNotificationPanel].
class NotificationItem {
  /// Unique identifier for the notification.
  final String id;

  /// The title of the notification.
  final String title;

  /// The description or body of the notification.
  final String description;

  /// When the notification occurred (e.g., "Just Now", "2 min ago").
  final String timestamp;

  /// Icon to display alongside the notification.
  final IconData icon;

  /// Primary color for the icon background or accent.
  final Color color;

  /// Optional callback when the notification is tapped.
  final VoidCallback? onTap;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.color = const Color(0xFF1C1C1E),
    this.onTap,
  });
}
