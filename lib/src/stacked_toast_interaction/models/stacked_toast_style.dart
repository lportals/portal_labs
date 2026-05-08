import 'package:flutter/material.dart';

/// Style configuration for the [StackedToastInteraction].
class StackedToastStyle {

  /// Creates a [StackedToastStyle].
  const StackedToastStyle({
    this.borderRadius,
    this.horizontalPadding = 16.0,
    this.shadows = const [
      BoxShadow(
        color: Color(0x13000000),
        blurRadius: 32,
        offset: Offset(0, 16),
      ),
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
    this.maxStackedItems = 3,
    this.stackOffset = 12.0,
    this.stackScaleFactor = 0.05,
    this.topMargin = 10.0,
    this.titleTextStyle,
    this.messageTextStyle,
    this.actionTextStyle,
    this.spring,
  });
  /// Global border radius of the toast
  final BorderRadius? borderRadius;
  /// Horizontal padding of the toast relative to the screen
  final double horizontalPadding;
  /// Shadow for the cards
  final List<BoxShadow> shadows;
  /// Max number of items to show in the stack background
  final int maxStackedItems;
  /// Vertical offset of stacked items behind the front card
  final double stackOffset;
  /// Scaling factor for stacked items
  final double stackScaleFactor;
  /// Vertical margin from the top of the screen (after safe area)
  final double topMargin;

  /// GLOBAL CUSTOMIZATION: Default text style for all toast titles.
  final TextStyle? titleTextStyle;
  /// GLOBAL CUSTOMIZATION: Default text style for all toast messages.
  final TextStyle? messageTextStyle;
  /// GLOBAL CUSTOMIZATION: Default text style for all toast action buttons.
  final TextStyle? actionTextStyle;

  /// Optional spring physics configuration.
  final SpringDescription? spring;
}
