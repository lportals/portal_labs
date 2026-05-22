import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_labs/src/common/portal_animations.dart';
import 'models/coverflow_carousel_style.dart';

export 'models/coverflow_carousel_style.dart';

/// Interaction states of the [CoverflowCarousel].
enum CoverflowState {
  /// The carousel is at rest and not being interacted with.
  idle,

  /// The user is dragging the carousel cards directly.
  draggingCarousel,

  /// The user is dragging the slider thumb.
  draggingSlider,

  /// The carousel is in the middle of a programmatic snapping or scrolling animation.
  animating,
}

/// A premium, programmatic controller for [CoverflowCarousel].
///
/// Allows external code to synchronize with the current page, jump to a
/// specific page, or animate to a page with custom durations and curves.
class CoverflowCarouselController extends ChangeNotifier {
  /// Creates a [CoverflowCarouselController] with the given [initialPage].
  CoverflowCarouselController({this.initialPage = 0});

  /// The initial page the carousel should display.
  final int initialPage;

  double _page = 0.0;

  /// The current fractional scroll page of the carousel.
  double get page => _page;

  void Function(int page, {Duration? duration, Curve? curve})?
  _animateToPageCallback;
  void Function(int page)? _jumpToPageCallback;

  /// Animates the carousel to a specific page.
  void animateToPage(int page, {Duration? duration, Curve? curve}) {
    _animateToPageCallback?.call(page, duration: duration, curve: curve);
  }

  /// Instantly jumps the carousel to a specific page.
  void jumpToPage(int page) {
    _jumpToPageCallback?.call(page);
  }

  void _updatePageInternal(double newPage) {
    if (_page != newPage) {
      _page = newPage;
      notifyListeners();
    }
  }
}

/// A premium 3D Coverflow carousel widget inspired by the classic iPod interface.
///
/// Displays a list of children in 3D perspective, rotated around the Y-axis and
/// overlapping toward the center. Supports horizontal swipes, tapping on side cards
/// to bring them to center, and dual-interactive scrolling via a custom slider track.
class CoverflowCarousel extends StatefulWidget {
  /// Creates a [CoverflowCarousel] with the given children and style configurations.
  const CoverflowCarousel({
    super.key,
    required this.children,
    this.style = const CoverflowCarouselStyle(),
    this.controller,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.enableHaptics = true,
  });

  /// The list of widgets to display in the carousel.
  final List<Widget> children;

  /// Optional style configuration for sizing, spacing, perspective, and sub-widgets.
  final CoverflowCarouselStyle style;

  /// Optional controller for external programmatic navigation.
  final CoverflowCarouselController? controller;

  /// The initial card index to show (only used if [controller] is null).
  final int initialIndex;

  /// Callback triggered when the active integer card index changes.
  final ValueChanged<int>? onIndexChanged;

  /// Whether to trigger a light haptic impact feedback when scrolling past cards.
  final bool enableHaptics;

  @override
  State<CoverflowCarousel> createState() => _CoverflowCarouselState();
}

class _CoverflowCarouselState extends State<CoverflowCarousel>
    with SingleTickerProviderStateMixin {
  late double _scrollOffset;
  late AnimationController _animationController;

  double _scrollStartValue = 0.0;
  double _scrollTargetValue = 0.0;
  int _currentIntegerIndex = 0;

  CoverflowState _state = CoverflowState.idle;

  @override
  void initState() {
    super.initState();
    _scrollOffset = (widget.controller?.initialPage ?? widget.initialIndex)
        .toDouble();
    _currentIntegerIndex = _scrollOffset.round();
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (mounted && _state == CoverflowState.animating) {
          setState(() => _state = CoverflowState.idle);
        }
      }
    });
    _connectController();
  }

  @override
  void didUpdateWidget(covariant CoverflowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disconnectController(oldWidget.controller);
      _connectController();
    }
  }

  @override
  void dispose() {
    _disconnectController(widget.controller);
    _animationController.dispose();
    super.dispose();
  }

  void _connectController() {
    if (widget.controller != null) {
      widget.controller!._animateToPageCallback = _animateToPage;
      widget.controller!._jumpToPageCallback = _jumpToPage;
      widget.controller!._updatePageInternal(_scrollOffset);
    }
  }

  void _disconnectController(CoverflowCarouselController? controller) {
    if (controller != null) {
      controller._animateToPageCallback = null;
      controller._jumpToPageCallback = null;
    }
  }

  void _onAnimationTick() {
    setState(() {
      _scrollOffset = lerpDouble(
        _scrollStartValue,
        _scrollTargetValue,
        const PortalSpringCurve().transform(_animationController.value),
      )!;
      _updateActiveIndexAndHaptics();
    });
  }

  void _updateActiveIndexAndHaptics() {
    final maxIndex = widget.children.length - 1;
    final newIndex = _scrollOffset.round().clamp(0, maxIndex);
    if (newIndex != _currentIntegerIndex) {
      _currentIntegerIndex = newIndex;
      widget.onIndexChanged?.call(_currentIntegerIndex);
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
    }
    widget.controller?._updatePageInternal(_scrollOffset);
  }

  void _animateToPage(int page, {Duration? duration, Curve? curve}) {
    _animationController.stop();
    _scrollStartValue = _scrollOffset;
    _scrollTargetValue = page.toDouble().clamp(
      0.0,
      (widget.children.length - 1).toDouble(),
    );

    setState(() => _state = CoverflowState.animating);

    // Calculate a dynamic duration based on the distance to travel.
    // A single page transition snaps quickly in 450ms, while multi-page
    // momentum scrolls scale up to 750ms to feel natural and weighted.
    final double distance = (_scrollTargetValue - _scrollStartValue).abs();
    final int dynamicMs = (distance <= 1.0)
        ? 450
        : (350 + (distance * 100).round()).clamp(450, 750);

    _animationController.duration =
        duration ?? Duration(milliseconds: dynamicMs);
    _animationController.forward(from: 0.0);
  }

  void _jumpToPage(int page) {
    _animationController.stop();
    setState(() {
      _state = CoverflowState.idle;
      _scrollOffset = page.toDouble().clamp(
        0.0,
        (widget.children.length - 1).toDouble(),
      );
      _updateActiveIndexAndHaptics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double carouselHeight = widget.style.enableReflection
            ? widget.style.cardHeight +
                  widget.style.reflectionGap +
                  (widget.style.cardHeight * 0.4) +
                  60.0
            : widget.style.cardHeight + 60.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The 3D Coverflow view
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _animationController.stop();
                setState(() => _state = CoverflowState.draggingCarousel);
              },
              onHorizontalDragUpdate: (details) {
                // Increase scroll sensitivity by dividing the drag delta by a smaller factor
                // of the card width (0.65x). This makes the carousel feel much lighter
                // and responsive to gestures without requiring wide swipes across the screen.
                final double cardStep = widget.style.cardWidth.clamp(
                  100.0,
                  double.infinity,
                );
                final double delta = -details.primaryDelta! / (cardStep * 0.65);
                setState(() {
                  _scrollOffset = (_scrollOffset + delta).clamp(
                    0.0,
                    (widget.children.length - 1).toDouble(),
                  );
                  _updateActiveIndexAndHaptics();
                });
              },
              onHorizontalDragEnd: (details) {
                final double velocity = details.primaryVelocity ?? 0.0;
                int target;
                if (velocity.abs() > 300) {
                  // Implement dynamic momentum-based page snapping (fling).
                  // Swiping quickly moves the carousel across multiple cards (1 page per 800px/s velocity).
                  // This loosens the stiffness and allows natural momentum scrolling.
                  final double pageChange = velocity / 800.0;
                  target = (_scrollOffset - pageChange).round().clamp(
                    0,
                    widget.children.length - 1,
                  );
                } else {
                  target = _scrollOffset.round();
                }
                _animateToPage(target);
              },
              child: SizedBox(
                width: double.infinity,
                height: carouselHeight,
                child: Stack(
                  children: _buildCoverflowCards(constraints),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Optional Index Text Label
            if (widget.style.showIndexIndicator && widget.children.isNotEmpty)
              Text('$_currentIntegerIndex', style: widget.style.indexTextStyle),
            if (widget.style.showSlider && widget.style.showIndexIndicator)
              const SizedBox(height: 16),
            // Optional Slider Track
            if (widget.style.showSlider && widget.children.isNotEmpty)
              _buildSlider(constraints),
          ],
        );
      },
    );
  }

  /// Builds the 3D coverflow cards rotated around the Y-axis and spaced
  /// along the X and Z axes.
  ///
  /// Z-orders the cards dynamically by their absolute distance to the current
  /// scroll offset, so that cards furthest away are painted first and the active
  /// center card is painted last. Apply perspective transformations, horizontal
  /// ease-out spacing, and opacity blending to each card.
  List<Widget> _buildCoverflowCards(BoxConstraints constraints) {
    if (widget.children.isEmpty) return const [];

    final double cardWidth = widget.style.cardWidth;
    final double cardHeight = widget.style.cardHeight;
    final double centerX = (constraints.maxWidth - cardWidth) / 2;
    // 20px vertical padding within the carousel stack
    const double centerY = 20.0;

    // Z-order: furthest from center paints first (behind), closest card paints last (on top).
    // Tiebreaker: when two cards are equidistant (mid-transition), the card closest
    // to the scroll target (the one being animated toward) paints on top, so the
    // "arriving" card always wins over the "leaving" card visually.
    final int scrollTarget = _scrollOffset.round();
    final sortedIndices = List<int>.generate(widget.children.length, (i) => i);
    sortedIndices.sort((a, b) {
      final distA = (a - _scrollOffset).abs();
      final distB = (b - _scrollOffset).abs();
      final cmp = distB.compareTo(distA);
      if (cmp != 0) return cmp;
      // Stable tiebreaker: card closer to the target (arriving card) paints on top
      final targetDistA = (a - scrollTarget).abs();
      final targetDistB = (b - scrollTarget).abs();
      return targetDistA.compareTo(targetDistB);
    });

    return sortedIndices.map((index) {
      final double diff = index - _scrollOffset;
      final double absDiff = diff.abs();

      // Don't render cards far off-screen to save GPU
      if (absDiff > 6.0) return const Positioned(child: SizedBox.shrink());

      // 1. Opacity: fade cards that approach the far visual limit
      double opacity = 1.0;
      if (absDiff > 4.0) {
        opacity = (1.0 - (absDiff - 4.0)).clamp(0.0, 1.0);
      }

      // 2. Y-axis rotation and scale transition factor.
      //    Transition rotation and scale over a 1.0 card span so they fold
      //    quickly as they leave the center. This keeps side cards thin and
      //    prevents wide/flat cards from overlapping messily.
      final double tRotation = absDiff.clamp(0.0, 1.0);
      // Use a cubic ease-out curve so cards fold away quickly from the center
      final double smoothTRotation =
          1.0 - (1.0 - tRotation) * (1.0 - tRotation) * (1.0 - tRotation);

      // Positive rotateY → left side of card comes toward viewer (faces right).
      // Left cards (diff < 0) need to face right → positive rotateY
      // Right cards (diff > 0) need to face left → negative rotateY
      final double rotationY =
          -diff.sign * smoothTRotation * widget.style.maxRotationAngle;

      final double scale =
          1.0 - (smoothTRotation * (1.0 - widget.style.scaleDelta));

      // 3. Horizontal translation using centerOffset and sideSpacing.
      //    Derive centerOffset and sideSpacing from widget.style.spacing so the
      //    spacing slider works and dynamically adjusts the CoverFlow geometry.
      //    - Center card to first side card transitions over centerOffset.
      //    - Subsequent side cards stack compressed at 50% of the spacing.
      final double baseStep = (cardWidth + widget.style.spacing).clamp(
        20.0,
        double.infinity,
      );
      final double centerOffset = baseStep;
      final double sideSpacing = baseStep * 0.5;

      final double tTranslation = absDiff.clamp(0.0, 1.0);
      final double smoothTTranslation =
          tTranslation * tTranslation * (3.0 - 2.0 * tTranslation);

      final double transitionPart = smoothTTranslation;
      final double stackedPart = absDiff - tTranslation;
      final double translationX =
          diff.sign *
          ((transitionPart * centerOffset) + (stackedPart * sideSpacing));

      final cardWidget = widget.children[index];


      Widget cardContent = RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            if (_scrollOffset.round() != index) {
              _animateToPage(index);
            }
          },
          child: _buildCardWrapper(cardWidget),
        ),
      );

      if (opacity < 1.0) {
        cardContent = Opacity(
          opacity: opacity,
          child: cardContent,
        );
      }

      return Positioned(
        left: centerX,
        top: centerY,
        width: cardWidth,
        height: cardHeight,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, -widget.style.perspective)
            ..translateByDouble(translationX, 0.0, 0.0, 1.0)
            ..rotateY(rotationY)
            // ignore: deprecated_member_use
            ..scale(scale),
          child: cardContent,
        ),
      );
    }).toList();
  }

  /// Wraps the card child with perspective shadow styling and card reflections.
  ///
  /// The card content is clipped using [ClipRRect]. To prevent shadow leak artifacts
  /// inside the reflection, we build the reflection using only the shadow-free
  /// [cardContent], mirror it upside down, and apply a [ShaderMask] with a linear
  /// gradient fade-out going from top (opaque) to bottom (transparent).
  Widget _buildCardWrapper(Widget child) {
    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(widget.style.borderRadius),
      child: child,
    );

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
        boxShadow: [
          BoxShadow(
            color: widget.style.shadowColor,
            blurRadius: widget.style.shadowBlurRadius,
            offset: widget.style.shadowOffset,
          ),
        ],
      ),
      child: cardContent,
    );

    if (!widget.style.enableReflection) {
      return card;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: widget.style.cardHeight + widget.style.reflectionGap,
          left: 0,
          right: 0,
          height: widget.style.cardHeight * 0.4,
          child: Opacity(
            opacity: widget.style.reflectionOpacity,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.4,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white.withValues(alpha: 0.0)],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
                  child: cardContent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(BoxConstraints constraints) {
    final double trackWidth = (constraints.maxWidth * 0.65).clamp(180.0, 340.0);
    final int maxIndex = widget.children.length - 1;
    if (maxIndex <= 0) return const SizedBox.shrink();

    final double progress = _scrollOffset / maxIndex;

    // Pattern matching to scale/elevate the slider thumb when active
    final double thumbScale = switch (_state) {
      CoverflowState.draggingSlider => 1.25,
      _ => 1.0,
    };

    final double thumbShadowOpacity = switch (_state) {
      CoverflowState.draggingSlider => 0.3,
      _ => 0.14,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        _animationController.stop();
        setState(() => _state = CoverflowState.draggingSlider);
        final double localX = details.localPosition.dx;
        final double tappedProgress = (localX / trackWidth).clamp(0.0, 1.0);
        final int targetPage = (tappedProgress * maxIndex).round();
        _animateToPage(targetPage);
      },
      onHorizontalDragStart: (_) {
        _animationController.stop();
        setState(() => _state = CoverflowState.draggingSlider);
      },
      onHorizontalDragUpdate: (details) {
        final double delta = details.primaryDelta! / trackWidth * maxIndex;
        setState(() {
          _scrollOffset = (_scrollOffset + delta).clamp(
            0.0,
            maxIndex.toDouble(),
          );
          _updateActiveIndexAndHaptics();
        });
      },
      onHorizontalDragEnd: (_) {
        final int target = _scrollOffset.round();
        _animateToPage(target);
      },
      child: Container(
        width: trackWidth,
        height: widget.style.sliderThumbHeight + 12,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Slider Track Line
            Container(
              width: trackWidth,
              height: widget.style.sliderHeight,
              decoration: BoxDecoration(
                color: widget.style.sliderTrackColor,
                borderRadius: BorderRadius.circular(
                  widget.style.sliderHeight / 2,
                ),
              ),
            ),
            // Draggable Thumb
            Positioned(
              left: (trackWidth - widget.style.sliderThumbWidth) * progress,
              child: AnimatedScale(
                scale: thumbScale,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  width: widget.style.sliderThumbWidth,
                  height: widget.style.sliderThumbHeight,
                  decoration: BoxDecoration(
                    color: widget.style.sliderThumbColor,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: thumbShadowOpacity,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0x1F000000),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
