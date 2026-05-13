import 'package:flutter/material.dart';

/// Defines the visual and interaction orientation of the archive folder.
enum ArchiveFolderOrientation {
  /// Vertical layout (upright).
  vertical,

  /// Horizontal layout (laying flat).
  horizontal,
}

/// The visual style configuration for the [ArchiveFolder].
class ArchiveFolderStyle {
  /// Creates a [ArchiveFolderStyle].
  const ArchiveFolderStyle({
    this.folderColor = const Color(0xFF30BB53),
    this.borderRadius = 12.0,
    this.glassBlur = 15.0,
    this.titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
    this.subtitleStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    this.itemRevealDistance = 140.0,
    this.itemSpacing = 60.0,
    this.itemStaggerDelay = 0.4,
    this.itemBaseScale = 0.85,
    this.itemBaseRotation = -0.15,
    this.animationDuration = const Duration(milliseconds: 700),
    this.animationCurve = Curves.easeOutQuart,
    this.enableHaptics = true,
    this.orientation = ArchiveFolderOrientation.horizontal,
    this.folderWidth = 175.0,
    this.folderHeight = 240.0,
    this.tabProtrusion = 25.0,
    this.enableItemRotation = true,
    this.itemWidth = 140.0,
    this.itemHeight = 180.0,
  });

  /// The primary color of the folder flaps.
  final Color folderColor;

  /// The corner radius of the folder.
  final double borderRadius;

  /// The intensity of the glassmorphism blur effect on the front flap.
  final double glassBlur;

  /// The text style for the main title on the flap.
  final TextStyle titleStyle;

  /// The text style for the subtitle on the flap.
  final TextStyle subtitleStyle;

  /// How far items slide out when the folder is opened.
  final double itemRevealDistance;

  /// The vertical spacing between items when revealed.
  final double itemSpacing;

  /// The duration of the staggered entry delay (0.0 to 1.0).
  final double itemStaggerDelay;

  /// The initial scale of items when they are tucked inside.
  final double itemBaseScale;

  /// The initial rotation (in radians) of items when they are tucked inside.
  final double itemBaseRotation;

  /// The duration of the open/close animation.
  final Duration animationDuration;

  /// The curve used for the opening/closing animation.
  final Curve animationCurve;

  /// Whether to trigger haptic feedback on interactions.
  final bool enableHaptics;

  /// The layout orientation of the folder.
  final ArchiveFolderOrientation orientation;

  /// The base width of the folder body.
  final double folderWidth;

  /// The total height of the folder.
  final double folderHeight;

  /// The width of the side tab that protrudes from the back flap.
  final double tabProtrusion;

  /// Whether to apply unique, organic rotations to items when they are revealed.
  final bool enableItemRotation;

  /// The fixed width of each archival item inside the folder.
  final double itemWidth;

  /// The fixed height of each archival item inside the folder.
  final double itemHeight;

  /// Copies the style with specified overrides.
  ArchiveFolderStyle copyWith({
    Color? folderColor,
    double? borderRadius,
    double? glassBlur,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? itemRevealDistance,
    double? itemSpacing,
    double? itemStaggerDelay,
    double? itemBaseScale,
    double? itemBaseRotation,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableHaptics,
    ArchiveFolderOrientation? orientation,
    double? folderWidth,
    double? folderHeight,
    double? tabProtrusion,
    bool? enableItemRotation,
    double? itemWidth,
    double? itemHeight,
  }) {
    return ArchiveFolderStyle(
      folderColor: folderColor ?? this.folderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      glassBlur: glassBlur ?? this.glassBlur,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      itemRevealDistance: itemRevealDistance ?? this.itemRevealDistance,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemStaggerDelay: itemStaggerDelay ?? this.itemStaggerDelay,
      itemBaseScale: itemBaseScale ?? this.itemBaseScale,
      itemBaseRotation: itemBaseRotation ?? this.itemBaseRotation,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      orientation: orientation ?? this.orientation,
      folderWidth: folderWidth ?? this.folderWidth,
      folderHeight: folderHeight ?? this.folderHeight,
      tabProtrusion: tabProtrusion ?? this.tabProtrusion,
      enableItemRotation: enableItemRotation ?? this.enableItemRotation,
      itemWidth: itemWidth ?? this.itemWidth,
      itemHeight: itemHeight ?? this.itemHeight,
    );
  }
}
