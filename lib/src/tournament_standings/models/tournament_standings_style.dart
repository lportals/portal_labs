import 'package:flutter/material.dart';

/// Style configuration for the [TournamentStandings] widget.
class TournamentStandingsStyle {
  /// Creates a [TournamentStandingsStyle] configuration.
  const TournamentStandingsStyle({
    this.backgroundColor,
    this.sidebarBackgroundColor,
    this.contentBackgroundColor,
    this.activeTabColor,
    this.tabBarBackgroundColor,
    this.tabTextStyle,
    this.activeTabTextStyle,
    this.matchCardBackgroundColor,
    this.matchCardBorderColor,
    this.matchCardTextStyle,
    this.scoreTextStyle,
    this.accentColor,
    this.connectingLineColor,
    this.connectingLineThickness = 1.5,
    this.matchCardWidth = 200.0,
    this.matchCardHeight = 90.0,
    this.matchCardSpacing = 20.0,
    this.enableHaptics = true,
    this.showQualificationIndicators = true,
  });

  /// Whether to show the qualification indicator colors on the left side of team rows.
  ///
  /// Defaults to true.
  final bool showQualificationIndicators;

  /// The root background color of the entire widget container.
  final Color? backgroundColor;

  /// Background color of the left sidebar containing the group standings list.
  final Color? sidebarBackgroundColor;

  /// Background color of the right content area showing stage details.
  final Color? contentBackgroundColor;

  /// Color of the active tab indicator pill.
  final Color? activeTabColor;

  /// Background color of the stage selection tab bar.
  final Color? tabBarBackgroundColor;

  /// Text style of inactive tabs.
  final TextStyle? tabTextStyle;

  /// Text style of the selected tab.
  final TextStyle? activeTabTextStyle;

  /// Background color of match cards in the bracket views.
  final Color? matchCardBackgroundColor;

  /// Border color of match cards in the bracket views.
  final Color? matchCardBorderColor;

  /// Text style for team names inside match cards.
  final TextStyle? matchCardTextStyle;

  /// Text style for scores inside match cards.
  final TextStyle? scoreTextStyle;

  /// Accent color for highlighting qualified teams or special badges.
  final Color? accentColor;

  /// Color of the connecting bracket lines.
  final Color? connectingLineColor;

  /// Thickness of the connecting bracket lines.
  ///
  /// Defaults to 1.5.
  final double connectingLineThickness;

  /// Width of the match card widgets in the bracket.
  ///
  /// Defaults to 200.0.
  final double matchCardWidth;

  /// Height of the match card widgets in the bracket.
  ///
  /// Defaults to 90.0.
  final double matchCardHeight;

  /// Vertical spacing between match cards in the bracket columns.
  ///
  /// Defaults to 20.0.
  final double matchCardSpacing;

  /// Whether to trigger lightweight haptic feedback on tab changes and interactions.
  ///
  /// Defaults to true.
  final bool enableHaptics;
}
