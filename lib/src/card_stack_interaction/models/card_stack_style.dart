import 'package:flutter/material.dart';

/// Style configuration for the [CardStackInteraction].
///
/// Allows customizing the layout's visual properties, including text styles,
/// container colors, and interaction button appearances.
class CardStackStyle {
  /// Creates a [CardStackStyle] with the given appearance properties.
  const CardStackStyle({
    this.cardBackgroundColor = Colors.white,
    this.cardShadowColor = const Color(0x14000000),
    this.titleColor = const Color(0xFF1D1D1F),
    this.subtitleColor = const Color(0xFF8E8E93),
    this.dateColor = const Color(0xFF8E8E93),
    this.iconContainerColor = const Color(0xFF1D1D1F),
    this.iconColor = Colors.white,
    this.borderRadius = 22.0,
    this.buttonBackgroundColor = Colors.white,
    this.buttonTextColor = const Color(0xFF1D1D1F),
    this.cardHeight = 90.0,
    this.cardSpacing = 16.0,
    this.collapsedOffset = 10.0,
    this.collapsedScaleDelta = 0.08,
  });

  /// The default high-fidelity theme for Portal Labs Stack.
  factory CardStackStyle.portalLabs() => const CardStackStyle();

  /// The background color of each individual card.
  final Color cardBackgroundColor;

  /// The shadow color applied when a card is in its expanded state.
  final Color cardShadowColor;

  /// The color displayable on the title across the card.
  final Color titleColor;

  /// The text color of subtending information within each card.
  final Color subtitleColor;

  /// The date font color for the item.
  final Color dateColor;

  /// The background color for the icon square container.
  final Color iconContainerColor;

  /// The color for the icon itself.
  final Color iconColor;

  /// The corner radius for the cards and icon containers.
  final double borderRadius;

  /// The background color for the expansion/collapse button.
  final Color buttonBackgroundColor;

  /// The text/icon color for the expansion/collapse button.
  final Color buttonTextColor;

  /// The height of each card in the stack.
  final double cardHeight;

  /// The vertical spacing between cards when expanded.
  final double cardSpacing;

  /// The vertical offset between cards when stacked/collapsed.
  final double collapsedOffset;

  /// The amount of scale reduction for each card underneath the top card.
  final double collapsedScaleDelta;
}
