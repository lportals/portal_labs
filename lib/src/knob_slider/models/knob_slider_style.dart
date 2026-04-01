import 'package:flutter/material.dart';

/// Style configuration for the [KnobSlider] component.
class KnobSliderStyle {

  /// Creates a [KnobSliderStyle] with the given appearance properties.
  const KnobSliderStyle({
    this.ringColor = const Color(0xFFF2F2F7),
    this.knobColor = Colors.white,
    this.trackColor = const Color(0xFFF2F4F7),
    this.borderColor = const Color(0x26000000), // 15% Black
    this.activeTickColor = const Color(0xFF8E8E93),
    this.inactiveTickColor = const Color(0xFFD1D1D4),
    this.handleColor = const Color(0xFF8E8E93),
    this.valueTextStyle = const TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w800,
      color: Color(0xFF8E8E93),
      letterSpacing: -1.0,
    ),
    this.labelTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF8E8E93),
    ),
    this.knobScale = 0.58,
    this.tickLength = 8.0,
    this.tickWidth = 2.0,
    this.totalTicks = 60,
    this.shadowColor = const Color(0xFF000000),
    this.blurRadius = 20.0,
  });
  /// The background color of the outer ring.
  final Color ringColor;

  /// The background color of the inner knob.
  final Color knobColor;

  /// The color of the active ticks.
  final Color activeTickColor;

  /// The color of the inactive ticks.
  final Color inactiveTickColor;

  /// The color of the handle/indicator.
  final Color handleColor;

  /// The text style for the center value.
  final TextStyle valueTextStyle;

  /// The text style for the labels (if any).
  final TextStyle labelTextStyle;

  /// The size of the knob relative to the total container.
  final double knobScale;

  /// The length of the ticks.
  final double tickLength;

  /// The width of the ticks.
  final double tickWidth;

  /// The number of ticks to display.
  final int totalTicks;

  /// The shadow color for the knob.
  final Color shadowColor;

  /// Radius of the outer glow/shadow.
  final double blurRadius;

  /// The color of the track/middle ring.
  final Color trackColor;

  /// The border color drawn around the outer ring.
  final Color borderColor;

  /// Creates a copy of this style with the given fields replaced.
  KnobSliderStyle copyWith({
    Color? ringColor,
    Color? knobColor,
    Color? trackColor,
    Color? borderColor,
    Color? activeTickColor,
    Color? inactiveTickColor,
    Color? handleColor,
    TextStyle? valueTextStyle,
    TextStyle? labelTextStyle,
    double? knobScale,
    double? tickLength,
    double? tickWidth,
    int? totalTicks,
    Color? shadowColor,
    double? blurRadius,
  }) {
    return KnobSliderStyle(
      ringColor: ringColor ?? this.ringColor,
      knobColor: knobColor ?? this.knobColor,
      trackColor: trackColor ?? this.trackColor,
      borderColor: borderColor ?? this.borderColor,
      activeTickColor: activeTickColor ?? this.activeTickColor,
      inactiveTickColor: inactiveTickColor ?? this.inactiveTickColor,
      handleColor: handleColor ?? this.handleColor,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      knobScale: knobScale ?? this.knobScale,
      tickLength: tickLength ?? this.tickLength,
      tickWidth: tickWidth ?? this.tickWidth,
      totalTicks: totalTicks ?? this.totalTicks,
      shadowColor: shadowColor ?? this.shadowColor,
      blurRadius: blurRadius ?? this.blurRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnobSliderStyle &&
          runtimeType == other.runtimeType &&
          ringColor == other.ringColor &&
          knobColor == other.knobColor &&
          trackColor == other.trackColor &&
          borderColor == other.borderColor &&
          activeTickColor == other.activeTickColor &&
          inactiveTickColor == other.inactiveTickColor &&
          handleColor == other.handleColor &&
          valueTextStyle == other.valueTextStyle &&
          labelTextStyle == other.labelTextStyle &&
          knobScale == other.knobScale &&
          tickLength == other.tickLength &&
          tickWidth == other.tickWidth &&
          totalTicks == other.totalTicks &&
          shadowColor == other.shadowColor &&
          blurRadius == other.blurRadius;

  @override
  int get hashCode =>
      ringColor.hashCode ^
      knobColor.hashCode ^
      trackColor.hashCode ^
      borderColor.hashCode ^
      activeTickColor.hashCode ^
      inactiveTickColor.hashCode ^
      handleColor.hashCode ^
      valueTextStyle.hashCode ^
      labelTextStyle.hashCode ^
      knobScale.hashCode ^
      tickLength.hashCode ^
      tickWidth.hashCode ^
      totalTicks.hashCode ^
      shadowColor.hashCode ^
      blurRadius.hashCode;
}
