import 'package:flutter/material.dart';

/// Style configuration for the [MediaCollapsibleView].
///
/// Allows customizing colors, blur intensity, and text labels for
/// a consistent premium look throughout the application.
class MediaViewStyle {
  /// Background color behind the video/blur frame.
  final Color backgroundColor;

  /// Background color of the interactive bottom sheet.
  final Color sheetBackgroundColor;

  /// Main text color for comments and title.
  final Color textColor;

  /// Secondary text color for usernames and subtending labels.
  final Color secondaryTextColor;

  /// Accent color for action icons, send button, and interactive elements.
  final Color accentColor;

  /// Color of the divider line and input field border in the sheet.
  final Color dividerColor;

  /// Intensity of the background blur effect.
  final double blurAmount;

  /// Placeholder text for the comment input field.
  final String commentHintText;

  const MediaViewStyle({
    this.backgroundColor = Colors.black,
    this.sheetBackgroundColor = const Color(0xFF141416),
    this.textColor = Colors.white,
    this.secondaryTextColor = Colors.white70,
    this.accentColor = Colors.blueAccent,
    this.dividerColor = const Color(0x14FFFFFF),
    this.blurAmount = 50.0,
    this.commentHintText = "Meow something...",
  });

  /// The default visual theme for Portal LabsMedia components.
  factory MediaViewStyle.portalLabs() => const MediaViewStyle();
}
