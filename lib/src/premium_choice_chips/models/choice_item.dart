import 'package:flutter/widgets.dart';

/// A flexible data model representing a selection item.
/// 
/// The component supports three types of visual representation:
/// 1. [emoji] - A simple text emoji (best for performance).
/// 2. [icon] - A Flutter [IconData] object (best for vector designs).
/// 3. [imagePath] - A URL or asset path (best for photographic content).
class ChoiceItem {
  /// The human-readable name of the item (e.g., 'Music', 'Apples').
  final String label;

  /// A text emoji string (e.g., '🎨'). 
  /// Set this to null if using [icon] or [imagePath].
  final String? emoji;

  /// A material or custom icon (e.g., LucideIcons.palette).
  /// Set this to null if using [emoji] or [imagePath].
  final IconData? icon;

  /// A path to a local asset or a network URL (starts with http).
  /// Set this to null if using [emoji] or [icon].
  final String? imagePath;

  const ChoiceItem({
    required this.label,
    this.emoji,
    this.icon,
    this.imagePath,
  });
}
