import 'package:flutter/material.dart';

/// Style configuration for the [PinnableList] component.
class PinnableListStyle {
  /// The background color of the count badge in section headers.
  final Color? badgeBackgroundColor;

  /// The text style of the count badge in section headers.
  final TextStyle? badgeTextStyle;

  /// The text style for section header titles.
  final TextStyle? sectionHeaderStyle;

  /// Whether to show the count badge next to section headers.
  final bool showHeaderBadge;

  /// The vertical spacing between sections.
  final double sectionSpacing;

  /// The spacing between the header and the list items.
  final double headerToItemsSpacing;

  // --- Card Specific Styling ---
  
  /// The background color of the default cards.
  final Color? cardBackgroundColor;

  /// The border radius of the default cards.
  final BorderRadius? cardBorderRadius;

  /// The border decoration for the default cards.
  final BoxBorder? cardBorder;

  /// The custom shadows for the cards.
  final List<BoxShadow>? cardShadows;

  const PinnableListStyle({
    this.badgeBackgroundColor,
    this.badgeTextStyle,
    this.sectionHeaderStyle,
    this.showHeaderBadge = true,
    this.sectionSpacing = 24.0,
    this.headerToItemsSpacing = 12.0,
    this.cardBackgroundColor,
    this.cardBorderRadius,
    this.cardBorder,
    this.cardShadows,
  });

  /// Creates a copy of this style with the given fields replaced.
  PinnableListStyle copyWith({
    Color? badgeBackgroundColor,
    TextStyle? badgeTextStyle,
    TextStyle? sectionHeaderStyle,
    bool? showHeaderBadge,
    double? sectionSpacing,
    double? headerToItemsSpacing,
    Color? cardBackgroundColor,
    BorderRadius? cardBorderRadius,
    BoxBorder? cardBorder,
    List<BoxShadow>? cardShadows,
  }) {
    return PinnableListStyle(
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      sectionHeaderStyle: sectionHeaderStyle ?? this.sectionHeaderStyle,
      showHeaderBadge: showHeaderBadge ?? this.showHeaderBadge,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      headerToItemsSpacing: headerToItemsSpacing ?? this.headerToItemsSpacing,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadows: cardShadows ?? this.cardShadows,
    );
  }
}
