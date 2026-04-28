import 'package:flutter/material.dart';

/// Model representing an item that can be pinned or unpinned in a list.
class PinnableItem {

  /// Creates a [PinnableItem].
  const PinnableItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.icon,
    this.isPinned = false,
    this.order = 0,
    this.metadata = const {},
  });
  /// Unique identifier for the item.
  final String id;

  /// Primary title of the item.
  final String title;

  /// Secondary description or metadata.
  final String subtitle;

  /// Leading icon or image widget.
  final Widget? icon;

  /// Whether the item is currently pinned.
  final bool isPinned;

  /// Internal identifier for the item's position in the list.
  /// Used for maintaining list order during animations.
  final int order;

  /// Metadata associated with the item.
  final Map<String, dynamic> metadata;

  /// Creates a copy of this item with the given fields replaced.
  PinnableItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    Widget? icon,
    bool? isPinned,
    int? order,
    Map<String, dynamic>? metadata,
  }) {
    return PinnableItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      isPinned: isPinned ?? this.isPinned,
      order: order ?? this.order,
      metadata: metadata ?? this.metadata,
    );
  }
}
