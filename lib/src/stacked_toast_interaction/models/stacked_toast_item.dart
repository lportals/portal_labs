import 'package:flutter/material.dart';

/// Defines the visual theme of the toast.
enum StackedToastType {
  /// Blue theme with info icon.
  info,
  /// Orange theme with warning icon.
  warning,
  /// Green theme with checkmark icon.
  success,
  /// Pink/Red theme with error icon.
  error,
  /// Dark/Custom theme with notification icon.
  custom,
}

/// Model representing a single toast notification.
class StackedToastItem {
  /// Unique identifier for the toast.
  final String id;
  /// Primary title of the toast (ignored if [builder] is used).
  final String title;
  /// Detailed message (ignored if [builder] is used).
  final String message;
  /// Type/Theme of the toast.
  final StackedToastType type;
  /// How long the toast remains visible.
  final Duration duration;
  /// Leading icon override.
  final IconData? icon;
  /// Primary color override for the theme.
  final Color? primaryColor;
  /// Background color override.
  final Color? backgroundColor;
  /// Label for the action button (default: "Close").
  final String actionLabel;
  /// Optional callback for the action button.
  final VoidCallback? onAction;
  
  /// CUSTOMIZATION: TextStyle override for the title.
  final TextStyle? titleTextStyle;
  /// CUSTOMIZATION: TextStyle override for the message.
  final TextStyle? messageTextStyle;
  /// CUSTOMIZATION: TextStyle override for the action button.
  final TextStyle? actionTextStyle;
  /// CUSTOMIZATION: Border radius override for this specific toast.
  final BorderRadius? borderRadius;

  /// ADVANCED: Custom builder for the toast content.
  /// If provided, this will be rendered instead of the default layout.
  /// This allows for total freedom in UI while inheriting stacking/animations.
  final Widget Function(BuildContext context, VoidCallback onClose)? builder;

  const StackedToastItem({
    required this.id,
    this.title = '',
    this.message = '',
    this.type = StackedToastType.info,
    this.duration = const Duration(seconds: 2),
    this.icon,
    this.primaryColor,
    this.backgroundColor,
    this.actionLabel = 'Close',
    this.onAction,
    this.titleTextStyle,
    this.messageTextStyle,
    this.actionTextStyle,
    this.borderRadius,
    this.builder,
  });
}
