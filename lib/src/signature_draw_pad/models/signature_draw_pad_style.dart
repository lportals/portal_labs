import 'package:flutter/material.dart';

/// Style configuration for the [SignatureDrawPad] widget.
class SignatureDrawPadStyle {
  /// Creates a new [SignatureDrawPadStyle] instance.
  const SignatureDrawPadStyle({
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E5E7),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderWidth = 1.0,
    this.strokeWidth = 3.0,
    this.activeColor = const Color(0xFF1D1D1F),
    this.paletteColors = const [
      Color(0xFF1D1D1F), // Black
      Color(0xFF7B8E97), // Slate
      Color(0xFFF16F4F), // Coral
      Color(0xFF2E8A3E), // Green
      Color(0xFF2B88D9), // Blue
      Color(0xFF9E57B7), // Purple
    ],
    this.labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1D1D1F),
    ),
    this.confirmButtonStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1D1D1F),
    ),
    this.confirmButtonColor = const Color(0xFFE5E5E7),
    this.confirmButtonBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.playbackDuration = const Duration(seconds: 2),
    this.shimmerColor = Colors.white,
    this.enableHaptics = true,
    this.viewIcon = Icons.visibility_outlined,
    this.clearIcon = Icons.refresh_rounded,
    this.undoIcon = Icons.undo_rounded,
    this.eraserIcon = Icons.cleaning_services_outlined,
    this.labelIcon = Icons.edit_outlined,
    this.dottedBorderColor = const Color(0xFFE5E5E7),
    this.paletteBorderRadius = 12.0,
  });

  /// The background color of the drawing area.
  final Color backgroundColor;

  /// The color of the border around the pad.
  final Color borderColor;

  /// The border radius of the pad.
  final BorderRadius borderRadius;

  /// The width of the border around the pad.
  final double borderWidth;

  /// The default width of the signature stroke.
  final double strokeWidth;

  /// The initial active color for drawing.
  final Color activeColor;

  /// The list of colors available in the palette.
  final List<Color> paletteColors;

  /// The text style for the "Draw signature" label.
  final TextStyle labelStyle;

  /// The text style for the confirm button.
  final TextStyle confirmButtonStyle;

  /// The background color of the confirm button.
  final Color confirmButtonColor;

  /// The border radius of the confirm button.
  final BorderRadius confirmButtonBorderRadius;

  /// The total duration for the signature playback animation.
  final Duration playbackDuration;

  /// The color of the shimmer effect at the end of playback.
  final Color shimmerColor;

  /// Whether to enable haptic feedback on interactions.
  final bool enableHaptics;

  /// The icon used for signature playback.
  final IconData viewIcon;

  /// The icon used for clearing the pad.
  final IconData clearIcon;

  /// The icon used for undoing the last stroke.
  final IconData undoIcon;

  /// The icon used for the eraser tool.
  final IconData eraserIcon;

  /// The icon displayed next to the label.
  final IconData labelIcon;

  /// The color of the dotted border around the drawing area.
  final Color dottedBorderColor;

  /// The border radius of the color swatches in the palette.
  final double paletteBorderRadius;

  /// Creates a copy of this style with the given fields replaced.
  SignatureDrawPadStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    double? borderWidth,
    double? strokeWidth,
    Color? activeColor,
    List<Color>? paletteColors,
    TextStyle? labelStyle,
    TextStyle? confirmButtonStyle,
    Color? confirmButtonColor,
    BorderRadius? confirmButtonBorderRadius,
    Duration? playbackDuration,
    Color? shimmerColor,
    bool? enableHaptics,
    IconData? viewIcon,
    IconData? clearIcon,
    IconData? undoIcon,
    IconData? eraserIcon,
    IconData? labelIcon,
    Color? dottedBorderColor,
    double? paletteBorderRadius,
  }) {
    return SignatureDrawPadStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      activeColor: activeColor ?? this.activeColor,
      paletteColors: paletteColors ?? this.paletteColors,
      labelStyle: labelStyle ?? this.labelStyle,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
      confirmButtonColor: confirmButtonColor ?? this.confirmButtonColor,
      confirmButtonBorderRadius:
          confirmButtonBorderRadius ?? this.confirmButtonBorderRadius,
      playbackDuration: playbackDuration ?? this.playbackDuration,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      viewIcon: viewIcon ?? this.viewIcon,
      clearIcon: clearIcon ?? this.clearIcon,
      undoIcon: undoIcon ?? this.undoIcon,
      eraserIcon: eraserIcon ?? this.eraserIcon,
      labelIcon: labelIcon ?? this.labelIcon,
      dottedBorderColor: dottedBorderColor ?? this.dottedBorderColor,
      paletteBorderRadius: paletteBorderRadius ?? this.paletteBorderRadius,
    );
  }
}
