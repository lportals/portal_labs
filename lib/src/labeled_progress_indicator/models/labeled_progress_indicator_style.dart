import 'package:flutter/material.dart';

/// Style configuration for the [LabeledProgressIndicator] component.
class LabeledProgressIndicatorStyle {
  /// Creates a [LabeledProgressIndicatorStyle] with the given appearance properties.
  const LabeledProgressIndicatorStyle({
    this.backgroundColor = const Color(0xFFF3F4F6),
    this.progressColor = const Color(0xFF007AFF),
    this.trackColor = const Color(0xFFE5E7EB),
    this.textStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6B7280),
    ),
    this.height = 12.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.shimmerColor = Colors.white,
    this.shimmerWidth = 0.4,
    this.animationDuration = const Duration(milliseconds: 100),
    this.shimmerDuration = const Duration(milliseconds: 2000),
    this.showCompletionPulse = true,
    this.showPercentage = false,
    this.percentageTextStyle,
    this.percentageFormat = '{val}%',
  });

  /// The background color of the widget container.
  final Color backgroundColor;

  /// The primary color of the progress bar.
  final Color progressColor;

  /// The color of the progress bar track (unfilled part).
  final Color trackColor;

  /// The style of the label text.
  final TextStyle textStyle;

  /// The style for the optional percentage text.
  final TextStyle? percentageTextStyle;

  /// Format for the percentage. Use '{val}' as placeholder for the number.
  final String percentageFormat;

  /// The height of the progress bar.
  final double height;

  /// The border radius of the progress bar.
  final BorderRadius borderRadius;

  /// The color of the shimmer effect.
  final Color shimmerColor;

  /// The width of the shimmer highlight (0.0 to 1.0).
  final double shimmerWidth;

  /// The duration of the progress value transition.
  final Duration animationDuration;

  /// The duration of one full shimmer cycle.
  final Duration shimmerDuration;

  /// Whether to trigger a scale and glow pulse when progress reaches 100%.
  final bool showCompletionPulse;

  /// Whether to display the percentage value inside or near the label.
  final bool showPercentage;

  /// Creates a copy of this style with the given fields replaced.
  LabeledProgressIndicatorStyle copyWith({
    Color? backgroundColor,
    Color? progressColor,
    Color? trackColor,
    TextStyle? textStyle,
    double? height,
    BorderRadius? borderRadius,
    Color? shimmerColor,
    double? shimmerWidth,
    Duration? animationDuration,
    Duration? shimmerDuration,
    bool? showCompletionPulse,
    bool? showPercentage,
    TextStyle? percentageTextStyle,
    String? percentageFormat,
  }) {
    return LabeledProgressIndicatorStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      progressColor: progressColor ?? this.progressColor,
      trackColor: trackColor ?? this.trackColor,
      textStyle: textStyle ?? this.textStyle,
      percentageTextStyle: percentageTextStyle ?? this.percentageTextStyle,
      percentageFormat: percentageFormat ?? this.percentageFormat,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      shimmerWidth: shimmerWidth ?? this.shimmerWidth,
      animationDuration: animationDuration ?? this.animationDuration,
      shimmerDuration: shimmerDuration ?? this.shimmerDuration,
      showCompletionPulse: showCompletionPulse ?? this.showCompletionPulse,
      showPercentage: showPercentage ?? this.showPercentage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabeledProgressIndicatorStyle &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          progressColor == other.progressColor &&
          trackColor == other.trackColor &&
          textStyle == other.textStyle &&
          height == other.height &&
          borderRadius == other.borderRadius &&
          shimmerColor == other.shimmerColor &&
          shimmerWidth == other.shimmerWidth &&
          animationDuration == other.animationDuration &&
          shimmerDuration == other.shimmerDuration;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      progressColor.hashCode ^
      trackColor.hashCode ^
      textStyle.hashCode ^
      height.hashCode ^
      borderRadius.hashCode ^
      shimmerColor.hashCode ^
      shimmerWidth.hashCode ^
      animationDuration.hashCode ^
      shimmerDuration.hashCode;
}
