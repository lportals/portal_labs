import 'package:flutter/material.dart';

/// A configuration object that defines the visual aesthetic of the [TagSelectionInteraction].
class TagSelectionStyle {

  /// Creates a [TagSelectionStyle] with custom values.
  const TagSelectionStyle({
    required this.selectedAreaColor,
    required this.unselectedTagColor,
    required this.selectedTagColor,
    required this.unselectedTextStyle,
    required this.selectedTextStyle,
    required this.closeIconColor,
    this.borderRadius = 12.0,
    this.selectedTagShadows = const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8.0,
        offset: Offset(0, 4),
      ),
    ],
    this.selectedAreaBorderRadius = 16.0,
    this.tagPadding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.damping = 15.0,
    this.stiffness = 1.0,
    this.enableHaptics = true,
  });
  /// The background color of the selected area container.
  final Color selectedAreaColor;

  /// The color of the unselected (pool) tags.
  final Color unselectedTagColor;

  /// The background color of a selected tag.
  final Color selectedTagColor;

  /// The text style for unselected tags.
  final TextStyle unselectedTextStyle;

  /// The text style for selected tags.
  final TextStyle selectedTextStyle;

  /// The color of the close icon on selected tags.
  final Color closeIconColor;

  /// The border radius of the tags.
  final double borderRadius;

  /// The shadows applied to selected tags.
  final List<BoxShadow> selectedTagShadows;

  /// The border radius of the selected area background.
  final double selectedAreaBorderRadius;

  /// The padding inside each tag.
  final EdgeInsets tagPadding;

  /// The spring damping for the flight animation.
  final double damping;

  /// The spring stiffness for the flight animation.
  final double stiffness;

  /// Whether to enable haptic feedback on interactions.
  final bool enableHaptics;

  /// The default high-fidelity light theme style.
  static const light = TagSelectionStyle(
    selectedAreaColor: Colors.white,
    unselectedTagColor: Color(0xFFF0F2F5),
    selectedTagColor: Colors.white,
    unselectedTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      color: Colors.black54,
    ),
    selectedTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: Colors.black,
    ),
    closeIconColor: Colors.black26,
  );

  /// The default high-fidelity dark theme style.
  static const dark = TagSelectionStyle(
    selectedAreaColor: Color(0xFF1C1C1E),
    unselectedTagColor: Color(0xFF2C2C2E),
    selectedTagColor: Color(0xFF3A3A3C),
    unselectedTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      color: Color(0x99FFFFFF),
    ),
    selectedTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: Colors.white,
    ),
    closeIconColor: Color(0x4DFFFFFF),
  );
}
