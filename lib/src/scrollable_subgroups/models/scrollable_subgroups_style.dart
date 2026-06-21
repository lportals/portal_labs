import 'package:flutter/material.dart';

/// Style configuration for [ScrollableSubgroups].
class ScrollableSubgroupsStyle {
  /// Creates a [ScrollableSubgroupsStyle] configuration.
  const ScrollableSubgroupsStyle({
    this.headerTextStyle,
    this.headerBackgroundColor,
    this.headerPadding,
    this.groupSpacing = 16.0,
    this.headerHeight = 50.0,
    this.headerTopBorderRadius,
    this.scaffoldBackgroundColor,
    this.fadeDistance = 24.0,
  });

  /// Text style for each sticky group header (used only when no [headerBuilder]
  /// is provided to the parent widget).
  final TextStyle? headerTextStyle;

  /// Background color for each sticky group header.
  final Color? headerBackgroundColor;

  /// Padding applied inside each sticky group header.
  final EdgeInsetsGeometry? headerPadding;

  /// The overlap distance in pixels over which the previous group fades out
  /// after collision with the next group.
  ///
  /// Defaults to 24.0.
  final double fadeDistance;

  /// Vertical space rendered below each group's item list,
  /// visually separating consecutive groups.
  ///
  /// Defaults to 16.0.
  final double groupSpacing;

  /// Height of the sticky group header area.
  ///
  /// Increase this when you supply a custom [headerBuilder] that needs
  /// more vertical space (e.g. title + column-header row).
  ///
  /// Defaults to 50.0.
  final double headerHeight;

  /// Optional border radius applied to the TOP corners of the sticky header,
  /// so the header visually "caps" a rounded card.
  final BorderRadius? headerTopBorderRadius;

  /// Optional background color of the scaffold/viewport container.
  ///
  /// This is used to paint the negative-space corners on top of the sticky
  /// header, ensuring that background list items scrolling underneath the
  /// header do not show through the rounded corners. If null, it defaults to
  /// the Theme's scaffold background color.
  final Color? scaffoldBackgroundColor;
}
