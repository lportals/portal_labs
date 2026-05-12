import 'package:flutter/material.dart';

/// Configuration style for [CinematicTextTransition].
class CinematicTextTransitionStyle {
  /// Creates a [CinematicTextTransitionStyle].
  const CinematicTextTransitionStyle({
    this.textStyle = const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.duration = const Duration(milliseconds: 1200),
    this.enableHaptics = true,
    this.enableElasticity = true,
    this.textAlign = TextAlign.center,
  });

  /// The text style for the characters.
  final TextStyle textStyle;

  /// The total duration of the sweep animation.
  final Duration duration;

  /// Whether to trigger haptic feedback on animation start.
  final bool enableHaptics;

  /// Whether to enable the physics-based whip wave motion.
  final bool enableElasticity;

  /// How the text should be aligned within its container.
  final TextAlign textAlign;

  /// Creates a copy of this style with the given fields replaced.
  CinematicTextTransitionStyle copyWith({
    TextStyle? textStyle,
    Duration? duration,
    bool? enableHaptics,
    bool? enableElasticity,
    TextAlign? textAlign,
  }) {
    return CinematicTextTransitionStyle(
      textStyle: textStyle ?? this.textStyle,
      duration: duration ?? this.duration,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableElasticity: enableElasticity ?? this.enableElasticity,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}
