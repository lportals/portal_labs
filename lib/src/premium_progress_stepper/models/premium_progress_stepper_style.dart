import 'package:flutter/material.dart';

/// Style configuration for the [PremiumProgressStepper] component.
class PremiumProgressStepperStyle {
  /// Creates a [PremiumProgressStepperStyle].
  const PremiumProgressStepperStyle({
    this.activeColor = const Color(0xFF1D1D1F), // Primary Black
    this.inactiveColor = const Color(0xFFE5E7EB), // Light Gray
    this.dotColor = Colors.white,
    this.primaryButtonColor = const Color(0xFF1D1D1F), // Primary Black
    this.primaryButtonTextColor = Colors.white,
    this.finishButtonColor = const Color(0xFF1D1D1F), // Primary Black
    this.secondaryButtonColor = const Color(0xFFF3F4F6), // Light Gray
    this.secondaryButtonTextColor = Colors.black,
    this.disabledButtonColor = const Color(0xFFE5E7EB), // Light Gray
    this.disabledButtonTextColor = const Color(0xFF9CA3AF), // Gray
    this.buttonBorderRadius = 40,
    this.buttonHeight = 56,
    this.indicatorHeight = 32,
    this.dotSize = 8,
    this.stepSpacing = 40,
    this.buttonTextStyle,
    this.enableHaptics = true,
    this.padding = const EdgeInsets.all(24),
    this.springMass = 1.0,
    this.springStiffness = 150.0,
    this.springDamping = 15.0,
    this.showFinishIcon = true,
    this.finishIcon,
  });

  /// The color of the active step and progress line.
  final Color activeColor;

  /// The color of the inactive step dots.
  final Color inactiveColor;

  /// The color of the dot inside the step.
  final Color dotColor;

  /// The background color of the primary action button.
  final Color primaryButtonColor;

  /// The text color of the primary action button.
  final Color primaryButtonTextColor;

  /// The background color of the primary action button on the last step.
  final Color? finishButtonColor;

  /// The background color of the secondary action button (Back).
  final Color secondaryButtonColor;

  /// The text color of the secondary action button.
  final Color secondaryButtonTextColor;

  /// The background color of the primary button when disabled.
  final Color disabledButtonColor;

  /// The text color of the primary button when disabled.
  final Color disabledButtonTextColor;

  /// Whether to show an icon on the finish step.
  final bool showFinishIcon;

  /// The custom widget to show as an icon on the finish step.
  final Widget? finishIcon;

  /// The border radius of the action buttons.
  final double buttonBorderRadius;

  /// The height of the buttons.
  final double buttonHeight;

  /// The height of the progress indicator pill.
  final double indicatorHeight;

  /// The size of the inner dots.
  final double dotSize;

  /// The spacing between steps.
  final double stepSpacing;

  /// The typography for the buttons.
  final TextStyle? buttonTextStyle;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  /// Padding around the component.
  final EdgeInsets padding;

  /// The mass of the spring for the indicator animation.
  final double springMass;

  /// The stiffness of the spring for the indicator animation.
  final double springStiffness;

  /// The damping of the spring for the indicator animation.
  final double springDamping;

  PremiumProgressStepperStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? dotColor,
    Color? primaryButtonColor,
    Color? primaryButtonTextColor,
    Color? finishButtonColor,
    Color? secondaryButtonColor,
    Color? secondaryButtonTextColor,
    Color? disabledButtonColor,
    Color? disabledButtonTextColor,
    double? buttonBorderRadius,
    double? buttonHeight,
    double? indicatorHeight,
    double? dotSize,
    double? stepSpacing,
    TextStyle? buttonTextStyle,
    bool? enableHaptics,
    EdgeInsets? padding,
    double? springMass,
    double? springStiffness,
    double? springDamping,
  }) {
    return PremiumProgressStepperStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      dotColor: dotColor ?? this.dotColor,
      primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
      primaryButtonTextColor: primaryButtonTextColor ?? this.primaryButtonTextColor,
      finishButtonColor: finishButtonColor ?? this.finishButtonColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      secondaryButtonTextColor: secondaryButtonTextColor ?? this.secondaryButtonTextColor,
      disabledButtonColor: disabledButtonColor ?? this.disabledButtonColor,
      disabledButtonTextColor: disabledButtonTextColor ?? this.disabledButtonTextColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      dotSize: dotSize ?? this.dotSize,
      stepSpacing: stepSpacing ?? this.stepSpacing,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      padding: padding ?? this.padding,
      springMass: springMass ?? this.springMass,
      springStiffness: springStiffness ?? this.springStiffness,
      springDamping: springDamping ?? this.springDamping,
    );
  }
}
