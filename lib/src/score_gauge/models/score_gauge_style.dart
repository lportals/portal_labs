import 'package:flutter/material.dart';

/// Style configuration for the [ScoreGauge] component.
///
/// Houses all visual, typographic, and behavioral properties.
/// Pass a custom instance to control the appearance of the gauge.
class ScoreGaugeStyle {
  /// Creates a [ScoreGaugeStyle] with robust and premium defaults.
  const ScoreGaugeStyle({
    // Gauge Arc Track Settings
    this.trackThickness = 28.0,
    this.trackBackgroundColor = const Color(0xFFF2F2F7),
    this.trackGradientColors = const [
      Color(0xFFFF3B30), // Red (Danger/Poor)
      Color(0xFFFF9500), // Orange (Warning/Fair)
      Color(0xFFFFCC00), // Yellow (Good)
      Color(0xFF34C759), // Green (Excellent)
      Color(0xFF5AC8FA), // Blue (Outstanding)
    ],
    this.startAngleDegrees = 145.0,
    this.sweepAngleDegrees = 250.0,

    // Gauge Value Indicator (Needle/Arrow/Marker)
    this.indicatorColor, // Nullable to dynamically match the traffic light category
    this.indicatorSize = 14.0,
    this.indicatorGap = 6.0,

    // Ticks Settings
    this.showTicks = true,
    this.tickCount = 19,
    this.tickLength = 6.0,
    this.tickThickness = 1.5,
    this.tickColor = const Color(0xFFE5E5EA),
    this.tickGap = 8.0,
    this.longTickLengthScale = 0.5,
    this.shortTickLengthScale = 0.25,

    // Typographic Styles
    this.valueTextStyle = const TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1C1C1E),
      letterSpacing: -2.0,
      height: 1.0,
    ),
    this.labelTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Color(0xFF636366),
      letterSpacing: 1.2,
      height: 1.2,
    ),
    this.labelGap = 8.0,

    // Behavior
    this.enableHaptics = true,
    this.animationDuration = const Duration(milliseconds: 1400),
  });

  /// Thickness (stroke width) of the gauge's arc track.
  final double trackThickness;

  /// Background color of the gauge arc representing the inactive portion.
  final Color trackBackgroundColor;

  /// Colors used to create a gradient sweep along the gauge arc.
  final List<Color> trackGradientColors;

  /// The angle (in degrees) at which the gauge arc starts drawing.
  /// 0 is right (3 o'clock), 90 is bottom (6 o'clock), 180 is left (9 o'clock), 270 is top (12 o'clock).
  final double startAngleDegrees;

  /// The total sweep angle (in degrees) of the gauge arc.
  final double sweepAngleDegrees;

  /// Color of the value triangle arrow/indicator inside the arc.
  /// If null, dynamically matches the current score's category color (traffic light style).
  final Color? indicatorColor;

  /// Width/height of the triangular indicator.
  final double indicatorSize;

  /// Distance between the inner edge of the arc track and the triangle indicator.
  final double indicatorGap;

  /// Whether tick marks are drawn outside/around the gauge arc track.
  final bool showTicks;

  /// Number of tick marks to draw along the gauge.
  final int tickCount;

  /// Length of each individual tick line.
  final double tickLength;

  /// Thickness of each tick line.
  final double tickThickness;

  /// Color of the tick lines.
  final Color tickColor;

  /// Distance between the outer edge of the gauge arc and the tick lines.
  final double tickGap;

  /// Relative length of the alternating long ticks as a fraction of trackThickness.
  final double longTickLengthScale;

  /// Relative length of the alternating short ticks as a fraction of trackThickness.
  final double shortTickLengthScale;

  /// TextStyle for the numeric value rendered inside the gauge.
  final TextStyle valueTextStyle;

  /// TextStyle for the text label rendered inside the gauge (e.g. "VERY GOOD").
  final TextStyle labelTextStyle;

  /// Gap between the numeric value and the text label.
  final double labelGap;

  /// Whether to fire light haptic feedback on interactions or level changes.
  final bool enableHaptics;

  /// Transition duration for gauge value updates.
  final Duration animationDuration;

  /// Returns a copy of this style with the given fields replaced.
  ScoreGaugeStyle copyWith({
    double? trackThickness,
    Color? trackBackgroundColor,
    List<Color>? trackGradientColors,
    double? startAngleDegrees,
    double? sweepAngleDegrees,
    Color? indicatorColor,
    double? indicatorSize,
    double? indicatorGap,
    bool? showTicks,
    int? tickCount,
    double? tickLength,
    double? tickThickness,
    Color? tickColor,
    double? tickGap,
    double? longTickLengthScale,
    double? shortTickLengthScale,
    TextStyle? valueTextStyle,
    TextStyle? labelTextStyle,
    double? labelGap,
    bool? enableHaptics,
    Duration? animationDuration,
  }) {
    return ScoreGaugeStyle(
      trackThickness: trackThickness ?? this.trackThickness,
      trackBackgroundColor: trackBackgroundColor ?? this.trackBackgroundColor,
      trackGradientColors: trackGradientColors ?? this.trackGradientColors,
      startAngleDegrees: startAngleDegrees ?? this.startAngleDegrees,
      sweepAngleDegrees: sweepAngleDegrees ?? this.sweepAngleDegrees,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      indicatorGap: indicatorGap ?? this.indicatorGap,
      showTicks: showTicks ?? this.showTicks,
      tickCount: tickCount ?? this.tickCount,
      tickLength: tickLength ?? this.tickLength,
      tickThickness: tickThickness ?? this.tickThickness,
      tickColor: tickColor ?? this.tickColor,
      tickGap: tickGap ?? this.tickGap,
      longTickLengthScale: longTickLengthScale ?? this.longTickLengthScale,
      shortTickLengthScale: shortTickLengthScale ?? this.shortTickLengthScale,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      labelGap: labelGap ?? this.labelGap,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
