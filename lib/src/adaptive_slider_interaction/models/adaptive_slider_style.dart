import 'package:flutter/material.dart';

/// Defines the visual configuration for the Adaptive Slider.
class AdaptiveSliderStyle {
  /// Creates an [AdaptiveSliderStyle] with the given visual properties.
  const AdaptiveSliderStyle({
    this.trackHeight = 44.0,
    this.thumbSize = 34.0,
    this.trackBorderRadius = 22.0,
    this.inactiveColor = const Color(0xFFF2F2F7),
    this.titleColor = const Color(0xFF8E8E93),
    this.unitColor = Colors.black,
    this.fontFamily,
    this.activeDotColor = Colors.white,
    this.inactiveDotColor = const Color(0x14000000), // Black with 0.08 opacity
    this.colorSteps = const [
      AdaptiveColorStep(
        threshold: 0.0,
        colors: [Color(0xFFFFD60A), Color(0xFFFF9F0A)], // Yellow to Orange
      ),
      AdaptiveColorStep(
        threshold: 0.5,
        colors: [Color(0xFFFF375F), Color(0xFFFF2D55)], // Pink-ish
      ),
      AdaptiveColorStep(
        threshold: 1.0,
        colors: [Color(0xFFBF5AF2), Color(0xFFAF52DE)], // Purple-ish
      ),
    ],
  });

  /// Height of the slider track.
  final double trackHeight;

  /// Diameter of the slider thumb.
  final double thumbSize;

  /// Border radius for the track.
  final double trackBorderRadius;

  /// Color of the inactive portion of the track.
  final Color inactiveColor;

  /// Color of the title text (e.g., "Calories").
  final Color titleColor;

  /// Color of the unit text (e.g., "kCal").
  final Color unitColor;

  /// The font family used for the number display.
  final String? fontFamily;

  /// Color of the dots when they are behind the thumb.
  final Color activeDotColor;

  /// Color of the dots when they are ahead of the thumb.
  final Color inactiveDotColor;

  /// List of color steps to interpolate for the adaptive gradient.
  /// Each step defines a value threshold and its primary gradient colors.
  final List<AdaptiveColorStep> colorSteps;
}

/// Represents a mapping between a value threshold and a set of colors.
class AdaptiveColorStep {
  /// Creates an [AdaptiveColorStep] with a [threshold] and [colors].
  const AdaptiveColorStep({required this.threshold, required this.colors});

  /// The value (from 0.0 to 1.0) at which this step is fully active.
  final double threshold;

  /// The gradient colors for this threshold.
  final List<Color> colors;
}
