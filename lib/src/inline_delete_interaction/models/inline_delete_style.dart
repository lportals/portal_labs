import 'package:flutter/material.dart';

/// Configuration style for the [InlineDeleteInteraction] component.
/// Supports dynamic theme-aware defaults for both light and dark modes.
class InlineDeleteStyle {
  /// Creates a [InlineDeleteStyle].
  const InlineDeleteStyle({
    this.backgroundColor,
    this.borderRadius,
    this.shadowColor = Colors.black,
    this.borderColor,
    this.borderWidth = 1.0,
    this.itemTextStyle,
    this.destructiveTextStyle,
    this.titleStyle,
    this.uppercaseTitle = true,
    this.iconColor,
    this.destructiveIconColor,
    this.confirmButtonColor = const Color(0xFFE54D4D),
    this.confirmButtonTextStyle,
    this.cancelButtonColor,
    this.cancelButtonTextStyle,
    this.enableHaptics = true,
    this.width = 280.0,
    this.rowHeight = 48.0,
    this.modalPadding = 12.0,
    this.titlePadding,
    this.backdropBlur = 2.0,
    this.barrierColor,
    this.springMass = 1.0,
    this.springStiffness = 220.0,
    this.springDamping = 26.0,
    this.appearanceDuration = const Duration(milliseconds: 320),
    this.appearanceScaleStart = 0.95,
  });

  /// The background color of the modal.
  final Color? backgroundColor;

  /// The border radius of the modal.
  final BorderRadius? borderRadius;

  /// The shadow color of the modal.
  final Color shadowColor;

  /// The color of the modal's border.
  final Color? borderColor;

  /// The width of the modal's border.
  final double borderWidth;

  /// The text style for regular menu items.
  final TextStyle? itemTextStyle;

  /// The text style for the destructive menu item.
  final TextStyle? destructiveTextStyle;

  /// The text style for the header title.
  final TextStyle? titleStyle;

  /// Whether to force the title to uppercase.
  final bool uppercaseTitle;

  /// The icon color for regular menu items.
  final Color? iconColor;

  /// The icon color for the destructive menu item.
  final Color? destructiveIconColor;

  /// The background color for the confirmation button.
  final Color confirmButtonColor;

  /// The text style for the confirmation button.
  final TextStyle? confirmButtonTextStyle;

  /// The background color for the cancel button.
  final Color? cancelButtonColor;

  /// The text style for the cancel button.
  final TextStyle? cancelButtonTextStyle;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  /// The width of the modal.
  final double width;

  /// The height of each menu row.
  final double rowHeight;

  /// The internal padding for the modal content (defines concentric radius).
  final double modalPadding;

  /// The padding for the title section.
  final EdgeInsets? titlePadding;

  /// The amount of backdrop blur to apply when the menu is open.
  final double backdropBlur;

  /// The color of the barrier behind the menu.
  final Color? barrierColor;

  /// The mass of the spring animation.
  final double springMass;

  /// The stiffness of the spring animation.
  final double springStiffness;

  /// The damping of the spring animation.
  final double springDamping;

  /// The duration of the appearance animation.
  final Duration appearanceDuration;

  /// The starting scale of the menu appearance.
  final double appearanceScaleStart;

  /// Resolves the style using the current [BuildContext] and [ThemeData].
  InlineDeleteStyle resolve(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InlineDeleteStyle(
      backgroundColor: backgroundColor ??
          (isDark ? const Color(0xFF1C1C1E) : Colors.white),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      shadowColor: shadowColor,
      borderColor: borderColor ??
          (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0)),
      itemTextStyle: itemTextStyle ??
          TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
      destructiveTextStyle: destructiveTextStyle ??
          const TextStyle(
            fontSize: 14,
            color: Color(0xFFE54D4D),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          titleStyle: titleStyle ??
          TextStyle(
            fontSize: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : const Color(0xFF999999),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
      uppercaseTitle: uppercaseTitle,
      iconColor: iconColor ?? (isDark ? Colors.white : const Color(0xFF1C1C1E)),
      destructiveIconColor: destructiveIconColor ?? const Color(0xFFE54D4D),
      confirmButtonColor: confirmButtonColor,
      confirmButtonTextStyle: confirmButtonTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
      cancelButtonColor: cancelButtonColor ??
          (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5)),
      cancelButtonTextStyle: cancelButtonTextStyle ??
          TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : const Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
      enableHaptics: enableHaptics,
      width: width,
      rowHeight: rowHeight,
      modalPadding: modalPadding,
      titlePadding: titlePadding ?? const EdgeInsets.fromLTRB(16, 20, 16, 12),
      backdropBlur: backdropBlur,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.02), // Ultra subtle
      springMass: springMass,
      springStiffness: springStiffness,
      springDamping: springDamping,
      appearanceDuration: appearanceDuration,
      appearanceScaleStart: appearanceScaleStart,
    );
  }

  /// Creates a copy of this style with the given fields replaced.
  InlineDeleteStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Color? shadowColor,
    Color? borderColor,
    double? borderWidth,
    TextStyle? itemTextStyle,
    TextStyle? destructiveTextStyle,
    TextStyle? titleStyle,
    bool? uppercaseTitle,
    Color? iconColor,
    Color? destructiveIconColor,
    Color? confirmButtonColor,
    TextStyle? confirmButtonTextStyle,
    Color? cancelButtonColor,
    TextStyle? cancelButtonTextStyle,
    bool? enableHaptics,
    double? width,
    double? rowHeight,
    double? modalPadding,
    EdgeInsets? titlePadding,
    double? backdropBlur,
    Color? barrierColor,
    double? springMass,
    double? springStiffness,
    double? springDamping,
    Duration? appearanceDuration,
    double? appearanceScaleStart,
  }) {
    return InlineDeleteStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      destructiveTextStyle: destructiveTextStyle ?? this.destructiveTextStyle,
      titleStyle: titleStyle ?? this.titleStyle,
      uppercaseTitle: uppercaseTitle ?? this.uppercaseTitle,
      iconColor: iconColor ?? this.iconColor,
      destructiveIconColor: destructiveIconColor ?? this.destructiveIconColor,
      confirmButtonColor: confirmButtonColor ?? this.confirmButtonColor,
      confirmButtonTextStyle:
          confirmButtonTextStyle ?? this.confirmButtonTextStyle,
      cancelButtonColor: cancelButtonColor ?? this.cancelButtonColor,
      cancelButtonTextStyle:
          cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      width: width ?? this.width,
      rowHeight: rowHeight ?? this.rowHeight,
      modalPadding: modalPadding ?? this.modalPadding,
      titlePadding: titlePadding ?? this.titlePadding,
      backdropBlur: backdropBlur ?? this.backdropBlur,
      barrierColor: barrierColor ?? this.barrierColor,
      springMass: springMass ?? this.springMass,
      springStiffness: springStiffness ?? this.springStiffness,
      springDamping: springDamping ?? this.springDamping,
      appearanceDuration: appearanceDuration ?? this.appearanceDuration,
      appearanceScaleStart: appearanceScaleStart ?? this.appearanceScaleStart,
    );
  }
}


