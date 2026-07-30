import 'package:flutter/material.dart';

/// Style configuration for the [EmotionSelector] component.
/// Provides extensive customization for colors, shapes, and animations
/// to ensure total reusability.
class EmotionSelectorStyle {
  /// Defines the visual properties for each emotion state in the selector.
  final List<EmotionStyle> emotionStyles;

  /// The duration of the expansion and morphing animations.
  final Duration animationDuration;

  /// The curve used for animations to provide a natural, spring-like feel.
  final Curve animationCurve;

  /// Creates an [EmotionSelectorStyle].
  const EmotionSelectorStyle({
    this.emotionStyles = const [
      EmotionStyle(
        color: Color(0xFF5E4BCE), // Very Unpleasant (Purple)
        icon: Icons.brightness_high, // Placeholder for 8-point star
        label: 'Very Unpleasant',
      ),
      EmotionStyle(
        color: Color(0xFF3362CC), // Unpleasant (Blue)
        icon: Icons.brightness_low, // Placeholder for 8-point star
        label: 'Unpleasant',
      ),
      EmotionStyle(
        color: Color(0xFF6F9CA4), // Neutral (Teal)
        icon: Icons.circle, // Placeholder for circle
        label: 'Neutral',
      ),
      EmotionStyle(
        color: Color(0xFFD6B249), // Pleasant (Yellow)
        icon: Icons.star_border, // Placeholder for 5-point star
        label: 'Pleasant',
      ),
      EmotionStyle(
        color: Color(0xFFD37B47), // Very Pleasant (Orange)
        icon: Icons.star, // Placeholder for 5-point star
        label: 'Very Pleasant',
      ),
    ],
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.fastLinearToSlowEaseIn,
  });

  /// Creates a copy of this style with the given fields replaced with the new values.
  EmotionSelectorStyle copyWith({
    List<EmotionStyle>? emotionStyles,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return EmotionSelectorStyle(
      emotionStyles: emotionStyles ?? this.emotionStyles,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}

/// Defines the style and properties for a single emotion option.
class EmotionStyle {
  /// The background color of the emotion pill.
  final Color color;

  /// The icon representing the emotion.
  final IconData icon;

  /// The semantic label or title for the emotion.
  final String label;

  /// Creates an [EmotionStyle].
  const EmotionStyle({
    required this.color,
    required this.icon,
    required this.label,
  });
}
