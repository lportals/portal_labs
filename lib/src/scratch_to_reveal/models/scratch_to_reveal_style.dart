import 'package:flutter/material.dart';

/// Defines the visual configuration for the [ScratchToReveal] component.
class ScratchToRevealStyle {

  /// Creates a [ScratchToRevealStyle].
  const ScratchToRevealStyle({
    this.backgroundColor = Colors.white,
    this.surfaceColor = const Color(0xFF2C2C2E),
    this.brushSize = 30.0,
    this.titleStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    this.labelTextStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    this.resetButtonStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    this.cornerRadius = 24.0,
    this.gridColor = const Color(0xFF3A3A3C),
    this.successThreshold = 0.80,
    this.gridColumns = 15,
    this.gridRows = 10,
    this.particleColor = const Color(0xFF666666),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  /// The background color of the main card container.
  final Color backgroundColor;

  /// The primary color of the scratchable surface.
  final Color surfaceColor;

  /// The radius of the scratch brush in logical pixels.
  final double brushSize;

  /// The style for the card title (e.g., "Apple Credits").
  final TextStyle titleStyle;

  /// The style for the 'Scratch to reveal' text on the surface.
  final TextStyle labelTextStyle;

  /// The style for the "Start again" button text.
  final TextStyle resetButtonStyle;

  /// The border radius for the card and scratch area.
  final double cornerRadius;

  /// The color of the diagonal grid lines on the surface.
  final Color gridColor;

  /// The percentage of surface scratched (0.0 to 1.0) required to trigger 
  /// completion or auto-reveal.
  final double successThreshold;

  /// The number of columns for the internal coverage tracking grid.
  final int gridColumns;

  /// The number of rows for the internal coverage tracking grid.
  final int gridRows;

  /// The color of the falling debris particles.
  final Color particleColor;

  /// The duration of the fade-out/reveal animation.
  final Duration animationDuration;

  /// Creates a copy of this style but with the given fields replaced with 
  /// the new values.
  ScratchToRevealStyle copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    double? brushSize,
    TextStyle? titleStyle,
    TextStyle? labelTextStyle,
    TextStyle? resetButtonStyle,
    double? cornerRadius,
    Color? gridColor,
    double? successThreshold,
    int? gridColumns,
    int? gridRows,
    Color? particleColor,
    Duration? animationDuration,
  }) {
    return ScratchToRevealStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      brushSize: brushSize ?? this.brushSize,
      titleStyle: titleStyle ?? this.titleStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      resetButtonStyle: resetButtonStyle ?? this.resetButtonStyle,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      gridColor: gridColor ?? this.gridColor,
      successThreshold: successThreshold ?? this.successThreshold,
      gridColumns: gridColumns ?? this.gridColumns,
      gridRows: gridRows ?? this.gridRows,
      particleColor: particleColor ?? this.particleColor,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Default high-fidelity style.
  static const ScratchToRevealStyle premium = ScratchToRevealStyle();
}
