import 'package:flutter/material.dart';

/// Controls which side the value badge is anchored to relative to the track.
enum BadgeAnchor {
  /// Badge floats to the right of the pill track.
  right,

  /// Badge floats to the left of the pill track.
  left,
}

/// Style configuration for the [SliderControl] component.
///
/// Houses all visual, typographic, and behavioural appearance properties.
/// Pass a custom instance to [SliderControl.style] to override the defaults.
class SliderControlStyle {
  /// Creates a [SliderControlStyle] with the given appearance properties.
  const SliderControlStyle({
    this.trackWidth = 64.0,
    this.trackBorderRadius = 999.0,
    this.trackBackgroundColor = const Color(0xFFE5E5EA), // Soft light greyish subtone
    this.trackBorderColor = Colors.transparent, // No border by default
    this.trackBorderWidth = 0.0,
    this.lowColor = const Color(0xFF5E5CE6),
    this.highColor = const Color(0xFFFF453A),
    this.badgeSize = 64.0,
    this.badgeBorderWidth = 3.5,
    this.badgeBackgroundColor = Colors.transparent, // Invisible background placeholder
    this.badgeGap = 12.0,
    this.valueTextStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1C1C1E), // Dark text to stand out on light grey background
      letterSpacing: -0.5,
      height: 1.0,
    ),
    this.suffixTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1C1C1E), // Dark text
      letterSpacing: 0,
      height: 1.0,
    ),
    this.valueSuffix = '°',
    this.tickCount = 20,
    this.tickWidth = 10.0,
    this.tickThickness = 1.5,
    this.ticksUseGradient = true,
    this.showTicks = true,
    this.tickGap = 8.0,
    this.topLabel = 'HI',
    this.bottomLabel = 'LO',
    this.badgeAnchor = BadgeAnchor.right,
    this.bottomIcon,
    this.bottomIconColor = const Color(0x33000000), // Dark icon color with opacity
    this.bottomIconSize = 20.0,
    this.enableHaptics = true,
    this.arrowColor,
  });

  // ── Track ────────────────────────────────────────────────────────────────

  /// Width of the pill-shaped track in logical pixels.
  final double trackWidth;

  /// Corner radius of the pill track (fully rounded when >= trackWidth / 2).
  final double trackBorderRadius;

  /// Background colour of the unfilled portion of the track.
  final Color trackBackgroundColor;

  /// Colour of the 1px border drawn around the pill track.
  final Color trackBorderColor;

  /// Stroke width of the pill track border.
  final double trackBorderWidth;

  // ── Gradient fill ────────────────────────────────────────────────────────

  /// Colour applied when the value is at [SliderControl.min] (bottom).
  final Color lowColor;

  /// Colour applied when the value is at [SliderControl.max] (top).
  final Color highColor;

  // ── Value badge ──────────────────────────────────────────────────────────

  /// Diameter of the circular value badge in logical pixels.
  final double badgeSize;

  /// Stroke width of the bi-coloured ring drawn around the badge.
  final double badgeBorderWidth;

  /// Background fill colour of the badge circle.
  final Color badgeBackgroundColor;

  /// Horizontal gap between the pill edge and the badge centre.
  final double badgeGap;

  /// [TextStyle] for the numeric portion of the value label.
  final TextStyle valueTextStyle;

  /// [TextStyle] for the optional suffix (e.g. `°`, `%`).
  final TextStyle suffixTextStyle;

  /// String appended after the integer value inside the badge.
  /// Set to an empty string to show only the number.
  final String valueSuffix;

  /// Which side the badge floats on relative to the track.
  final BadgeAnchor badgeAnchor;

  // ── Tick marks ───────────────────────────────────────────────────────────

  /// Total number of tick marks rendered alongside the track.
  final int tickCount;

  /// Horizontal length of each tick line in logical pixels.
  final double tickWidth;

  /// Stroke thickness of each tick line.
  final double tickThickness;

  /// When `true`, ticks are coloured using the [lowColor]→[highColor] gradient.
  /// When `false`, ticks inherit a single mid-opacity white colour.
  final bool ticksUseGradient;

  /// Whether tick marks are rendered at all.
  final bool showTicks;

  /// Horizontal gap between the pill edge and the start of the tick lines.
  final double tickGap;

  /// Text label displayed at the top of the tick column (defaults to 'HI').
  final String topLabel;

  /// Text label displayed at the bottom of the tick column (defaults to 'LO').
  final String bottomLabel;

  // ── Bottom icon ──────────────────────────────────────────────────────────

  /// Optional icon rendered at the bottom-centre of the track pill.
  final IconData? bottomIcon;

  /// Colour applied to [bottomIcon].
  final Color bottomIconColor;

  /// Size of [bottomIcon] in logical pixels.
  final double bottomIconSize;

  // ── Behaviour ────────────────────────────────────────────────────────────

  /// Whether to fire [HapticFeedback.selectionClick] on each step crossing.
  final bool enableHaptics;

  /// Custom colour of the value arrow indicator selector.
  /// If null, automatically falls back to dynamic luminance-based black/white.
  final Color? arrowColor;

  // ── copyWith ─────────────────────────────────────────────────────────────

  /// Returns a copy of this style with the given fields replaced.
  SliderControlStyle copyWith({
    double? trackWidth,
    double? trackBorderRadius,
    Color? trackBackgroundColor,
    Color? trackBorderColor,
    double? trackBorderWidth,
    Color? lowColor,
    Color? highColor,
    double? badgeSize,
    double? badgeBorderWidth,
    Color? badgeBackgroundColor,
    double? badgeGap,
    TextStyle? valueTextStyle,
    TextStyle? suffixTextStyle,
    String? valueSuffix,
    int? tickCount,
    double? tickWidth,
    double? tickThickness,
    bool? ticksUseGradient,
    bool? showTicks,
    double? tickGap,
    String? topLabel,
    String? bottomLabel,
    BadgeAnchor? badgeAnchor,
    IconData? bottomIcon,
    Color? bottomIconColor,
    double? bottomIconSize,
    bool? enableHaptics,
    Color? arrowColor,
  }) {
    return SliderControlStyle(
      trackWidth: trackWidth ?? this.trackWidth,
      trackBorderRadius: trackBorderRadius ?? this.trackBorderRadius,
      trackBackgroundColor:
          trackBackgroundColor ?? this.trackBackgroundColor,
      trackBorderColor: trackBorderColor ?? this.trackBorderColor,
      trackBorderWidth: trackBorderWidth ?? this.trackBorderWidth,
      lowColor: lowColor ?? this.lowColor,
      highColor: highColor ?? this.highColor,
      badgeSize: badgeSize ?? this.badgeSize,
      badgeBorderWidth: badgeBorderWidth ?? this.badgeBorderWidth,
      badgeBackgroundColor:
          badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeGap: badgeGap ?? this.badgeGap,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      suffixTextStyle: suffixTextStyle ?? this.suffixTextStyle,
      valueSuffix: valueSuffix ?? this.valueSuffix,
      tickCount: tickCount ?? this.tickCount,
      tickWidth: tickWidth ?? this.tickWidth,
      tickThickness: tickThickness ?? this.tickThickness,
      ticksUseGradient: ticksUseGradient ?? this.ticksUseGradient,
      showTicks: showTicks ?? this.showTicks,
      tickGap: tickGap ?? this.tickGap,
      topLabel: topLabel ?? this.topLabel,
      bottomLabel: bottomLabel ?? this.bottomLabel,
      badgeAnchor: badgeAnchor ?? this.badgeAnchor,
      bottomIcon: bottomIcon ?? this.bottomIcon,
      bottomIconColor: bottomIconColor ?? this.bottomIconColor,
      bottomIconSize: bottomIconSize ?? this.bottomIconSize,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      arrowColor: arrowColor ?? this.arrowColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliderControlStyle &&
          runtimeType == other.runtimeType &&
          trackWidth == other.trackWidth &&
          trackBorderRadius == other.trackBorderRadius &&
          trackBackgroundColor == other.trackBackgroundColor &&
          trackBorderColor == other.trackBorderColor &&
          trackBorderWidth == other.trackBorderWidth &&
          lowColor == other.lowColor &&
          highColor == other.highColor &&
          badgeSize == other.badgeSize &&
          badgeBorderWidth == other.badgeBorderWidth &&
          badgeBackgroundColor == other.badgeBackgroundColor &&
          badgeGap == other.badgeGap &&
          valueTextStyle == other.valueTextStyle &&
          suffixTextStyle == other.suffixTextStyle &&
          valueSuffix == other.valueSuffix &&
          tickCount == other.tickCount &&
          tickWidth == other.tickWidth &&
          tickThickness == other.tickThickness &&
          ticksUseGradient == other.ticksUseGradient &&
          showTicks == other.showTicks &&
          tickGap == other.tickGap &&
          topLabel == other.topLabel &&
          bottomLabel == other.bottomLabel &&
          badgeAnchor == other.badgeAnchor &&
          bottomIcon == other.bottomIcon &&
          bottomIconColor == other.bottomIconColor &&
          bottomIconSize == other.bottomIconSize &&
          enableHaptics == other.enableHaptics &&
          arrowColor == other.arrowColor;

  @override
  int get hashCode =>
      trackWidth.hashCode ^
      trackBorderRadius.hashCode ^
      trackBackgroundColor.hashCode ^
      trackBorderColor.hashCode ^
      trackBorderWidth.hashCode ^
      lowColor.hashCode ^
      highColor.hashCode ^
      badgeSize.hashCode ^
      badgeBorderWidth.hashCode ^
      badgeBackgroundColor.hashCode ^
      badgeGap.hashCode ^
      valueTextStyle.hashCode ^
      suffixTextStyle.hashCode ^
      valueSuffix.hashCode ^
      tickCount.hashCode ^
      tickWidth.hashCode ^
      tickThickness.hashCode ^
      ticksUseGradient.hashCode ^
      showTicks.hashCode ^
      tickGap.hashCode ^
      topLabel.hashCode ^
      bottomLabel.hashCode ^
      badgeAnchor.hashCode ^
      bottomIcon.hashCode ^
      bottomIconColor.hashCode ^
      bottomIconSize.hashCode ^
      enableHaptics.hashCode ^
      arrowColor.hashCode;
}
