import 'package:flutter/material.dart';

/// Configuration for the [SwipeableActionTile] physics and behavior.
class SwipeableActionTileStyle {
  /// Creates a style configuration for the [SwipeableActionTile].
  const SwipeableActionTileStyle({
    this.springDescription = const SpringDescription(
      mass: 1.0,
      stiffness: 200.0,
      damping: 20.0,
    ),
    this.enableHaptics = true,
    this.actionWidth = 80.0,
    this.cornerRadius = 0.0,
    this.swipeThreshold = 0.5,
    this.tileShadow = const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
    this.actionButtonSize = 48.0,
    this.cardColor = Colors.white,
    this.idleCardColor,
  });

  /// The physics spring used when snapping the tile open or closed.
  final SpringDescription springDescription;

  /// Whether to play haptic feedback when actions are revealed or fully opened.
  final bool enableHaptics;

  /// The width of each action button behind the tile.
  final double actionWidth;

  /// The corner radius for the tile, if any.
  final double cornerRadius;

  /// The swipe threshold (as a percentage of action width) required to automatically open.
  final double swipeThreshold;

  /// The background color of the card when it is swiped/active.
  final Color cardColor;

  /// The background color of the card when idle (matches list background to hide dividers cleanly).
  /// If null, it defaults to [cardColor].
  final Color? idleCardColor;

  /// The shadow applied to the swipeable tile.
  final List<BoxShadow>? tileShadow;

  /// The size of the circular action button.
  final double actionButtonSize;
}
