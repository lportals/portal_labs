import 'package:flutter/material.dart';

/// Configuration style class for [QuickPickerInteraction].
///
/// Every property that affects visual appearance, timing, or spatial layout
/// is surfaced here with a sensible default — nothing is hardcoded inside the
/// widget itself. Developers can pass only the fields they want to override.
class QuickPickerStyle {
  /// Creates a [QuickPickerStyle].
  const QuickPickerStyle({
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.openBackgroundColor = const Color(0xFFE6E6E6),
    this.activeSegmentColor = Colors.white,
    this.selectedColor = const Color(0xFF545454),
    this.selectedIconColor = const Color(0xFFAEAEAE),
    this.unselectedColor = const Color(0xFF8E8E93),
    this.chevronColor = const Color(0xFF545454),
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.enableHaptics = true,
    this.animationDuration = const Duration(milliseconds: 350),
    this.popupAnimationDuration = const Duration(milliseconds: 150),
    this.selectionDismissDelay = const Duration(milliseconds: 80),
    this.maxIconBlur = 3.0,
    this.iconSize = 20.0,
    this.chevronSize = 20.0,
    this.popupShadowColor = Colors.transparent,
    this.triggerShadowColor = Colors.transparent,
    this.triggerBorderColor = Colors.transparent,
    this.popupBorderColor = const Color(0xFFF0F0F0),
    this.popupBackgroundColor = const Color(0xFFF0F0F0),
    this.popupSegmentWidth = 110.0,
    this.popupPadding = const EdgeInsets.all(4),
    this.popupOffset = const Offset(0, -10),
    this.pressScale = 0.90,
  });

  // ── Trigger button colors ──────────────────────────────────────────────────

  /// The background color of the trigger button when the popup is closed.
  final Color backgroundColor;

  /// The background color of the trigger button when the popup menu is open.
  final Color openBackgroundColor;

  // ── Popup / popover colors ─────────────────────────────────────────────────

  /// The background color of the active (selected) segment pill in the popup.
  final Color activeSegmentColor;

  /// The text color for the selected option (trigger button and popup).
  final Color selectedColor;

  /// The icon color for the selected option (trigger button and popup).
  final Color selectedIconColor;

  /// The text and icon color for unselected options in the popup.
  final Color unselectedColor;

  // ── Trigger chrome colors ──────────────────────────────────────────────────

  /// The color of the rotating chevron dropdown arrow.
  final Color chevronColor;

  // ── Typography ─────────────────────────────────────────────────────────────

  /// The text style used for option labels throughout the widget.
  final TextStyle textStyle;

  // ── Shape ─────────────────────────────────────────────────────────────────

  /// Corner radius for both the trigger button and the popup capsule.
  final double borderRadius;

  /// Padding inside the trigger button around its row of children.
  final EdgeInsets padding;

  // ── Behaviour ─────────────────────────────────────────────────────────────

  /// Whether to fire lightweight haptic feedback on interaction.
  final bool enableHaptics;

  // ── Timing ────────────────────────────────────────────────────────────────

  /// Duration used for all text sweep, icon blur, width-morph, and color
  /// transition animations on the trigger button.
  final Duration animationDuration;

  /// Duration of the popup capsule's enter and exit slide+fade animation.
  ///
  /// Decoupled from [animationDuration] so the popup can feel snappier or
  /// slower independently of the trigger button's transition speed.
  final Duration popupAnimationDuration;

  /// How long to wait after an option is tapped before the popup begins its
  /// slide-out / fade-out exit animation.
  ///
  /// Keep this short (≤ [animationDuration] * 0.6) so the interaction feels
  /// instant; long enough that the selection scale-in on the active pill is
  /// visible before the popup disappears.
  final Duration selectionDismissDelay;

  // ── Icon / chevron sizing ─────────────────────────────────────────────────

  /// The maximum Gaussian blur sigma applied to the icon during a transition.
  final double maxIconBlur;

  /// The render size of option icons (trigger button and popup).
  final double iconSize;

  /// The render size of the rotating chevron arrow.
  final double chevronSize;

  // ── Interaction feedback ──────────────────────────────────────────────────

  /// The scale factor of the trigger button during a press gesture.
  ///
  /// `0.90` produces a pronounced tactile shrink; `0.96` is more subtle.
  final double pressScale;

  // ── Trigger shadow & border ───────────────────────────────────────────────

  /// Shadow color of the popup options menu. Set to [Colors.transparent] for flat.
  final Color popupShadowColor;

  /// Shadow color of the trigger button. Set to [Colors.transparent] for flat.
  final Color triggerShadowColor;

  /// Border color of the trigger button. Set to [Colors.transparent] for none.
  final Color triggerBorderColor;

  // ── Popup layout ──────────────────────────────────────────────────────────

  /// Border color of the popup capsule container.
  final Color popupBorderColor;

  /// Background color of the popup capsule container.
  final Color popupBackgroundColor;

  /// Fixed logical-pixel width of each option segment inside the popup.
  ///
  /// Increase this if option labels are long; decrease for a more compact look.
  final double popupSegmentWidth;

  /// Internal padding of the popup capsule container.
  ///
  /// Affects the breathing room between the capsule border and the option pills.
  final EdgeInsets popupPadding;

  /// Positional offset of the popup relative to the trigger button's top-center
  /// anchor. A negative `dy` moves the popup upward (above the trigger).
  final Offset popupOffset;

  // ── copyWith ──────────────────────────────────────────────────────────────

  /// Creates a copy of this style with the given fields replaced.
  QuickPickerStyle copyWith({
    Color? backgroundColor,
    Color? openBackgroundColor,
    Color? activeSegmentColor,
    Color? selectedColor,
    Color? selectedIconColor,
    Color? unselectedColor,
    Color? chevronColor,
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
    bool? enableHaptics,
    Duration? animationDuration,
    Duration? popupAnimationDuration,
    Duration? selectionDismissDelay,
    double? maxIconBlur,
    double? iconSize,
    double? chevronSize,
    double? pressScale,
    Color? popupShadowColor,
    Color? triggerShadowColor,
    Color? triggerBorderColor,
    Color? popupBorderColor,
    Color? popupBackgroundColor,
    double? popupSegmentWidth,
    EdgeInsets? popupPadding,
    Offset? popupOffset,
  }) {
    return QuickPickerStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      openBackgroundColor: openBackgroundColor ?? this.openBackgroundColor,
      activeSegmentColor: activeSegmentColor ?? this.activeSegmentColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      chevronColor: chevronColor ?? this.chevronColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      animationDuration: animationDuration ?? this.animationDuration,
      popupAnimationDuration:
          popupAnimationDuration ?? this.popupAnimationDuration,
      selectionDismissDelay:
          selectionDismissDelay ?? this.selectionDismissDelay,
      maxIconBlur: maxIconBlur ?? this.maxIconBlur,
      iconSize: iconSize ?? this.iconSize,
      chevronSize: chevronSize ?? this.chevronSize,
      pressScale: pressScale ?? this.pressScale,
      popupShadowColor: popupShadowColor ?? this.popupShadowColor,
      triggerShadowColor: triggerShadowColor ?? this.triggerShadowColor,
      triggerBorderColor: triggerBorderColor ?? this.triggerBorderColor,
      popupBorderColor: popupBorderColor ?? this.popupBorderColor,
      popupBackgroundColor: popupBackgroundColor ?? this.popupBackgroundColor,
      popupSegmentWidth: popupSegmentWidth ?? this.popupSegmentWidth,
      popupPadding: popupPadding ?? this.popupPadding,
      popupOffset: popupOffset ?? this.popupOffset,
    );
  }
}
