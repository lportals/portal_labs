import 'package:flutter/material.dart';

/// Style configuration for the [FeedbackInteraction] widget.
class FeedbackInteractionStyle {
  /// Creates a [FeedbackInteractionStyle] with the given parameters.
  const FeedbackInteractionStyle({
    this.backgroundColor = const Color(0xFFF5F2F0),
    this.foregroundColor = const Color(0xFF1A1A1A),
    this.undoBackgroundColor = const Color(0xFFEBE8E6),
    this.messageTextStyle,
    this.undoTextStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    this.undoBorderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.spacing = 16.0,
    this.enableHaptics = true,
    this.buttonInitialWidth = 76.0,
    this.pillExpandedWidth = 320.0,
    this.springStiffness = 240.0,
    this.springDamping = 18.0,
    this.positiveIcon = Icons.thumb_up_rounded,
    this.negativeIcon = Icons.thumb_down_rounded,
    this.undoIcon = Icons.undo_rounded,
    this.fadeVelocity = 5.0,
    this.maxBlur = 16.0,
    this.settleThreshold = 0.1,
  });

  /// The background color of the buttons.
  final Color backgroundColor;

  /// The color of the icons and text.
  final Color foregroundColor;

  /// The background color of the "Undo" button.
  final Color undoBackgroundColor;

  /// The text style for the "Feedback Received!" message.
  final TextStyle? messageTextStyle;

  /// The text style for the "Undo" button text.
  final TextStyle? undoTextStyle;

  /// The border radius of the buttons.
  final BorderRadius borderRadius;

  /// The border radius of the "Undo" button.
  final BorderRadius undoBorderRadius;

  /// The padding for the buttons.
  final EdgeInsets padding;

  /// The spacing between the thumbs up and thumbs down buttons.
  final double spacing;

  /// Whether to enable haptic feedback on interaction.
  final bool enableHaptics;

  /// The initial width of each feedback button.
  final double buttonInitialWidth;

  /// The width of the expanded feedback pill.
  final double pillExpandedWidth;

  /// The stiffness of the spring animation.
  final double springStiffness;

  /// The damping of the spring animation.
  final double springDamping;

  /// The icon used for positive feedback.
  final IconData positiveIcon;

  /// The icon used for negative feedback.
  final IconData negativeIcon;

  /// The icon used for the undo action.
  final IconData undoIcon;

  /// The speed at which the non-selected button fades out.
  final double fadeVelocity;

  /// The maximum blur intensity for the non-selected button.
  final double maxBlur;

  /// The threshold at which the widget becomes interactive again during closing.
  final double settleThreshold;

  /// Creates a copy of this style with the given fields replaced.
  FeedbackInteractionStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? undoBackgroundColor,
    TextStyle? messageTextStyle,
    TextStyle? undoTextStyle,
    BorderRadius? borderRadius,
    BorderRadius? undoBorderRadius,
    EdgeInsets? padding,
    double? spacing,
    bool? enableHaptics,
    double? buttonInitialWidth,
    double? pillExpandedWidth,
    double? springStiffness,
    double? springDamping,
    IconData? positiveIcon,
    IconData? negativeIcon,
    IconData? undoIcon,
    double? fadeVelocity,
    double? maxBlur,
    double? settleThreshold,
  }) {
    return FeedbackInteractionStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      undoBackgroundColor: undoBackgroundColor ?? this.undoBackgroundColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      undoTextStyle: undoTextStyle ?? this.undoTextStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      undoBorderRadius: undoBorderRadius ?? this.undoBorderRadius,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      buttonInitialWidth: buttonInitialWidth ?? this.buttonInitialWidth,
      pillExpandedWidth: pillExpandedWidth ?? this.pillExpandedWidth,
      springStiffness: springStiffness ?? this.springStiffness,
      springDamping: springDamping ?? this.springDamping,
      positiveIcon: positiveIcon ?? this.positiveIcon,
      negativeIcon: negativeIcon ?? this.negativeIcon,
      undoIcon: undoIcon ?? this.undoIcon,
      fadeVelocity: fadeVelocity ?? this.fadeVelocity,
      maxBlur: maxBlur ?? this.maxBlur,
      settleThreshold: settleThreshold ?? this.settleThreshold,
    );
  }
}
