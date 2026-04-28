import 'package:flutter/material.dart';

/// Defines the visual configuration for the [TodoListInteraction] component.
class TodoListStyle {
  /// Creates a [TodoListStyle].
  const TodoListStyle({
    this.dateStyle,
    this.categoryHeaderStyle,
    this.itemTextStyle,
    this.checkboxActiveColor,
    this.checkboxBorderColor,
    this.itemHeight = 32.0,
    this.outerBackgroundColor = const Color(0xFFF0F0F0),
    this.cardBackgroundColor = Colors.white,
    this.tabTrackColor = const Color(0xFFF0F0F0),
    this.tabIndicatorColor = Colors.white,
    this.tabTextStyle,
    this.outerBorderRadius = 40.0,
    this.cardBorderRadius = 32.0,
    this.springStiffness = 220.0,
    this.springDamping = 20.0,
    this.filters = const ['To-do', 'Completed', 'Pending'],
  });

  /// TextStyle for the date header at the top.
  final TextStyle? dateStyle;

  /// TextStyle for category headers.
  final TextStyle? categoryHeaderStyle;

  /// TextStyle for individual task titles.
  final TextStyle? itemTextStyle;

  /// Color of the checkbox when active/checked.
  final Color? checkboxActiveColor;

  /// Color of the checkbox border.
  final Color? checkboxBorderColor;

  /// Vertical height of each item row.
  final double itemHeight;

  /// Background color of the outer "Island" container.
  final Color? outerBackgroundColor;

  /// Background color of the inner content card.
  final Color? cardBackgroundColor;

  /// Background color of the filter tab track.
  final Color? tabTrackColor;

  /// Color of the sliding tab indicator.
  final Color? tabIndicatorColor;

  /// Text style for the filter tabs.
  final TextStyle? tabTextStyle;

  /// Corner radius of the outer container.
  final double outerBorderRadius;

  /// Corner radius of the inner card.
  final double cardBorderRadius;

  /// Physics: Stiffness of the spring simulations.
  final double springStiffness;

  /// Physics: Damping ratio of the spring simulations.
  final double springDamping;

  /// List of filter tab labels. Defaults to ['To-do', 'Completed', 'Pending'].
  final List<String> filters;

  /// Creates a copy of this style with the given fields replaced.
  TodoListStyle copyWith({
    TextStyle? dateStyle,
    TextStyle? categoryHeaderStyle,
    TextStyle? itemTextStyle,
    Color? checkboxActiveColor,
    Color? checkboxBorderColor,
    double? itemHeight,
    Color? outerBackgroundColor,
    Color? cardBackgroundColor,
    Color? tabTrackColor,
    Color? tabIndicatorColor,
    TextStyle? tabTextStyle,
    double? outerBorderRadius,
    double? cardBorderRadius,
    double? springStiffness,
    double? springDamping,
    List<String>? filters,
  }) {
    return TodoListStyle(
      dateStyle: dateStyle ?? this.dateStyle,
      categoryHeaderStyle: categoryHeaderStyle ?? this.categoryHeaderStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      checkboxActiveColor: checkboxActiveColor ?? this.checkboxActiveColor,
      checkboxBorderColor: checkboxBorderColor ?? this.checkboxBorderColor,
      itemHeight: itemHeight ?? this.itemHeight,
      outerBackgroundColor: outerBackgroundColor ?? this.outerBackgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      tabTrackColor: tabTrackColor ?? this.tabTrackColor,
      tabIndicatorColor: tabIndicatorColor ?? this.tabIndicatorColor,
      tabTextStyle: tabTextStyle ?? this.tabTextStyle,
      outerBorderRadius: outerBorderRadius ?? this.outerBorderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      springStiffness: springStiffness ?? this.springStiffness,
      springDamping: springDamping ?? this.springDamping,
      filters: filters ?? this.filters,
    );
  }
}
