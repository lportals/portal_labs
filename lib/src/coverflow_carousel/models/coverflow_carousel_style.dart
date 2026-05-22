import 'package:flutter/material.dart';

/// Style configuration for the [CoverflowCarousel].
///
/// Allows customizing the layout's visual properties, including dimensions,
/// 3D perspective rotation, overlapping spacing, shadow offsets, and the
/// appearance of the built-in slider and index label.
class CoverflowCarouselStyle {
  /// Creates a [CoverflowCarouselStyle] with premium default values.
  const CoverflowCarouselStyle({
    // Card dimensions: square proportions like classic album art
    this.cardWidth = 220.0,
    this.cardHeight = 220.0,
    // Classic CoverFlow default: 70° rotation so side cards visibly face inward
    this.maxRotationAngle = 1.22173, // 70 * pi / 180 = ~1.22173 rad (70°)
    // Slight scale-down so the active card visually pops above side cards
    this.scaleDelta = 0.85,
    // Perspective tuned to approximate SwiftUI's implicit camera distance (~1/500)
    this.perspective = 0.002,
    this.centerOffset = 100.0,
    this.sideSpacing = 40.0,
    // Z-offset: keep 0 by default to match SwiftUI's pure-perspective depth
    this.zOffset = 0.0,
    this.borderRadius = 20.0,
    this.shadowColor = const Color(0x44000000),
    this.shadowBlurRadius = 20.0,
    this.shadowOffset = const Offset(0, 12),
    // Negative spacing = cards heavily overlap, exactly like SwiftUI spacing slider < 0
    this.spacing = -130.0,
    this.enableReflection = false,
    this.reflectionOpacity = 0.5,
    this.reflectionGap = 5.0,
    this.showSlider = true,
    this.sliderTrackColor = const Color(0xFFE5E5EA),
    this.sliderThumbColor = Colors.white,
    this.sliderHeight = 6.0,
    this.sliderThumbWidth = 36.0,
    this.sliderThumbHeight = 16.0,
    this.showIndexIndicator = true,
    this.indexTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  });

  /// The width of each individual card in the carousel.
  final double cardWidth;

  /// The height of each individual card in the carousel.
  final double cardHeight;

  /// The maximum rotation angle (in radians) applied to side cards.
  ///
  /// Rotation is interpolated based on distance from the active center.
  final double maxRotationAngle;

  /// The scale multiplier applied to cards when they are pushed to the side.
  ///
  /// Must be between 0.0 and 1.0 (default is 0.8).
  final double scaleDelta;

  /// The perspective factor used in the 3D projection matrix.
  ///
  /// Represents the entry at (3, 2) in Matrix4. Recommended: 0.001 to 0.002.
  final double perspective;

  /// The horizontal distance (in pixels) between the center card and the first side card.
  final double centerOffset;

  /// The horizontal spacing (in pixels) between subsequent side cards.
  final double sideSpacing;

  /// The depth distance (in pixels) that side cards are pushed back along the Z-axis.
  final double zOffset;

  /// The border radius for the card corners.
  final double borderRadius;

  /// The color of the card's drop shadow.
  final Color shadowColor;

  /// The blur radius of the card's drop shadow.
  final double shadowBlurRadius;

  /// The position offset of the card's drop shadow.
  final Offset shadowOffset;

  /// The uniform layout spacing between adjacent cards.
  ///
  /// Negative values (e.g. -120) cause cards to overlap.
  final double spacing;

  /// Whether to render a mirrored reflection of the card directly below it.
  final bool enableReflection;

  /// The opacity of the rendered card reflection.
  ///
  /// Must be between 0.0 and 1.0.
  final double reflectionOpacity;

  /// The vertical spacing gap between the card and its reflection.
  final double reflectionGap;

  /// Whether to render the horizontal slider track and thumb control below the carousel.
  final bool showSlider;

  /// The background color of the slider track.
  final Color sliderTrackColor;

  /// The fill color of the draggable slider thumb.
  final Color sliderThumbColor;

  /// The vertical thickness of the slider track.
  final double sliderHeight;

  /// The horizontal width of the pill-shaped slider thumb.
  final double sliderThumbWidth;

  /// The vertical height of the pill-shaped slider thumb.
  final double sliderThumbHeight;

  /// Whether to display the integer index label text below the carousel.
  final bool showIndexIndicator;

  /// The text style of the index indicator text.
  final TextStyle indexTextStyle;
}
