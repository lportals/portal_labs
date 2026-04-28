import 'package:flutter/material.dart';

/// Style configuration for the [SlotPickerInteraction] component.
class SlotPickerStyle {

  /// Creates a [SlotPickerStyle].
  const SlotPickerStyle({
    this.collapsedBackgroundColor = const Color(0xFFF2F2F7),
    this.expandedBackgroundColor = Colors.white,
    this.labelColor = const Color(0xFF1C1C1E),
    this.secondaryLabelColor = const Color(0xFF8E8E93),
    this.slotTextColor = const Color(0xFF1C1C1E),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shadows = const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    this.activeSwitchColor = Colors.black,
    this.inactiveSwitchColor = const Color(0xFFD1D1D6),
    this.titleStyle,
    this.slotTextStyle,
    this.inputBorder,
    this.inputFillColor = Colors.white,
    this.addButtonColor = const Color(0xFFF2F2F7),
    this.errorColor = const Color(0xFFFF3B30),
    this.dividerColor = const Color(0xFFC6C6C8),
    this.addButtonTextStyle,
    this.removeIconColor = const Color(0xFF8E8E93),
    this.removeButtonBackgroundColor = const Color(0xFFF2F2F7),
    this.headerPadding = const EdgeInsets.fromLTRB(16, 8, 16, 4),
    this.contentPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });
  /// Background color of the container when collapsed.
  final Color collapsedBackgroundColor;

  /// Background color when an item is expanded.
  final Color expandedBackgroundColor;

  /// Color for the text labels.
  final Color labelColor;

  /// Color for the secondary text labels (e.g., "From", "To").
  final Color secondaryLabelColor;

  /// Color for the slot time text.
  final Color slotTextColor;

  /// Border radius for the items.
  final BorderRadius borderRadius;

  /// Shadow decoration for the expanded state.
  final List<BoxShadow> shadows;

  /// Color for the active toggle switch.
  final Color activeSwitchColor;

  /// Color for the inactive toggle switch background.
  final Color inactiveSwitchColor;

  /// TextStyle for the main item title.
  final TextStyle? titleStyle;

  /// TextStyle for the slot text.
  final TextStyle? slotTextStyle;

  /// Border for the time inputs.
  final BoxBorder? inputBorder;

  /// Filling color for the time inputs.
  final Color? inputFillColor;

  /// Color used for error highlights (overlaps).
  final Color errorColor;

  /// Color for the divider between header and content.
  final Color dividerColor;

  /// TextStyle for the "Add More" button.
  final TextStyle? addButtonTextStyle;

  /// Color for the remove icon.
  final Color removeIconColor;

  /// Background color for the remove button.
  final Color removeButtonBackgroundColor;

  /// Padding for the header section.
  final EdgeInsetsGeometry headerPadding;

  /// Padding for the slots section.
  final EdgeInsetsGeometry contentPadding;

  /// Background color for the "Add More" button.
  final Color? addButtonColor;

  /// Allows inheriting properties and overriding specific ones.
  SlotPickerStyle copyWith({
    Color? collapsedBackgroundColor,
    Color? expandedBackgroundColor,
    Color? labelColor,
    Color? secondaryLabelColor,
    Color? slotTextColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    Color? activeSwitchColor,
    Color? inactiveSwitchColor,
    TextStyle? titleStyle,
    TextStyle? slotTextStyle,
    BoxBorder? inputBorder,
    Color? inputFillColor,
    Color? errorColor,
    Color? dividerColor,
    TextStyle? addButtonTextStyle,
    Color? removeIconColor,
    Color? removeButtonBackgroundColor,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SlotPickerStyle(
      collapsedBackgroundColor:
          collapsedBackgroundColor ?? this.collapsedBackgroundColor,
      expandedBackgroundColor:
          expandedBackgroundColor ?? this.expandedBackgroundColor,
      labelColor: labelColor ?? this.labelColor,
      secondaryLabelColor: secondaryLabelColor ?? this.secondaryLabelColor,
      slotTextColor: slotTextColor ?? this.slotTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      activeSwitchColor: activeSwitchColor ?? this.activeSwitchColor,
      inactiveSwitchColor: inactiveSwitchColor ?? this.inactiveSwitchColor,
      titleStyle: titleStyle ?? this.titleStyle,
      slotTextStyle: slotTextStyle ?? this.slotTextStyle,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      errorColor: errorColor ?? this.errorColor,
      dividerColor: dividerColor ?? this.dividerColor,
      addButtonTextStyle: addButtonTextStyle ?? this.addButtonTextStyle,
      removeIconColor: removeIconColor ?? this.removeIconColor,
      removeButtonBackgroundColor: removeButtonBackgroundColor ?? this.removeButtonBackgroundColor,
      headerPadding: headerPadding ?? this.headerPadding,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
