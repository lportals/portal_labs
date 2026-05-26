import 'package:flutter/material.dart';

/// Style configuration for the [StackedCards] widget.
///
/// Allows customizing the layout's visual properties, including dimensions,
/// translation offsets, rotation angles, shadows, margins, and page indicators.
class StackedCardsStyle {
  /// Creates a [StackedCardsStyle] with premium default values.
  const StackedCardsStyle({
    this.cardWidth = 280.0,
    this.cardHeight = 380.0,
    this.horizontalOffset = 24.0,
    this.scaleDelta = 0.04,
    this.rotationAngle = 0.08,
    this.maxStackedItems = 3,
    this.borderRadius = 24.0,
    this.shadowColor = const Color(0x1F000000),
    this.shadowBlurRadius = 16.0,
    this.shadowOffset = const Offset(0, 8),
    this.shadows,
    this.alignment = Alignment.bottomRight,
    this.snapCurve = Curves.easeOutQuart,
    this.indicatorActiveColor = const Color(0xFF111111),
    this.indicatorInactiveColor = const Color(0xFFE5E5EA),
    this.indicatorSize = 8.0,
    this.indicatorSpacing = 6.0,
  });

  /// The width of each individual card in the stack.
  final double cardWidth;

  /// The height of each individual card in the stack.
  final double cardHeight;

  /// The horizontal spacing/offset between subsequent cards stacked behind the front card.
  final double horizontalOffset;

  /// The amount of scale reduction for each card underneath the front card (e.g. 0.04 reduces scale by 4% per layer).
  final double scaleDelta;

  /// The rotation angle (in radians) applied to cards in the stack when rotation is enabled.
  ///
  /// By default, is 0.08 radians (~4.5 degrees) clockwise per stack level.
  final double rotationAngle;

  /// The maximum number of cards visible in the stack.
  ///
  /// Remaining cards are hidden behind the stack with 0 opacity. Default is 3.
  final int maxStackedItems;

  /// The corner radius for the cards.
  final double borderRadius;

  /// The color of the card's drop shadow.
  final Color shadowColor;

  /// The blur radius of the card's drop shadow.
  final double shadowBlurRadius;

  /// The position offset of the card's drop shadow.
  final Offset shadowOffset;

  /// An optional custom list of shadows applied to the card.
  ///
  /// If provided, overrides [shadowColor], [shadowBlurRadius], and [shadowOffset].
  /// Set to an empty list `[]` to disable shadows completely.
  final List<BoxShadow>? shadows;

  /// The alignment anchor used for scaling and rotating cards in the stack.
  ///
  /// Defaults to [Alignment.bottomRight] to anchor cards at the bottom-right point,
  /// eliminating vertical bottom gaps and creating a clean overlap.
  final Alignment alignment;

  /// The curve used to snap cards back to position.
  ///
  /// Defaults to [Curves.easeOutQuart] for a smooth, premium deceleration
  /// with zero bouncy overshoot.
  final Curve snapCurve;

  /// The color of the active page indicator dot.
  final Color indicatorActiveColor;

  /// The color of inactive page indicator dots.
  final Color indicatorInactiveColor;

  /// The size (diameter) of inactive page indicator dots.
  final double indicatorSize;

  /// The spacing between dots in the page indicator.
  final double indicatorSpacing;
}
