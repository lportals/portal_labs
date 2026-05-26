import 'dart:async';
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
    this.scrollDirection = Axis.horizontal,
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

  /// The axis along which the carousel scrolls (horizontal or vertical).
  final Axis scrollDirection;

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

  /// Guards tap-to-navigate during animation AND for a brief cooldown after.
  ///
  /// Without the post-animation cooldown, a double-click's second tap can
  /// arrive just after the animation settles. The card layout has shifted by
  /// then, so the same screen position now points to a different card —
  /// typically the one the user just left — causing a snap-back effect.
  bool _tapNavigationLocked = false;
  Timer? _tapUnlockTimer;

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
          setState(() {
            _scrollOffset = _scrollTargetValue;
            _state = CoverflowState.idle;
          });
          _updateActiveIndexAndHaptics();
          // Keep tap navigation locked for a short window after the animation
          // settles. The card layout shifts on completion and a late-arriving
          // double-click second tap can hit a different card than intended.
          _tapUnlockTimer?.cancel();
          _tapUnlockTimer = Timer(const Duration(milliseconds: 250), () {
            if (mounted) setState(() => _tapNavigationLocked = false);
          });
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
    _tapUnlockTimer?.cancel();
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
    final double target = page.toDouble().clamp(
      0.0,
      (widget.children.length - 1).toDouble(),
    );

    // If already animating to the same target, ignore the call.
    // This prevents jumpy resets on repeated programmatic animateToPage() calls.
    if (_state == CoverflowState.animating && _scrollTargetValue == target) {
      return;
    }

    _animationController.stop();
    _scrollStartValue = _scrollOffset;
    _scrollTargetValue = target;

    // Engage the tap lock immediately — the post-animation cooldown timer
    // (started in the status listener) will release it 250ms after settle.
    _tapUnlockTimer?.cancel();
    _tapNavigationLocked = true;

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
    final bool isHorizontal = widget.scrollDirection == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double carouselHeight = isHorizontal
            ? (widget.style.enableReflection
                  ? widget.style.cardHeight +
                        widget.style.reflectionGap +
                        (widget.style.cardHeight * 0.4) +
                        60.0
                  : widget.style.cardHeight + 60.0)
            : widget.style.cardHeight * 2.0 + 60.0;

        final double carouselWidth = isHorizontal
            ? constraints.maxWidth
            : (constraints.maxWidth - (widget.style.showSlider ? 60.0 : 0.0));

        Widget buildCarousel() {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: isHorizontal
                ? (_) {
                    _animationController.stop();
                    setState(() => _state = CoverflowState.draggingCarousel);
                  }
                : null,
            onHorizontalDragUpdate: isHorizontal
                ? (details) {
                    final double cardStep = widget.style.cardWidth.clamp(
                      100.0,
                      double.infinity,
                    );
                    final double delta =
                        -details.primaryDelta! / (cardStep * 0.65);
                    setState(() {
                      _scrollOffset = (_scrollOffset + delta).clamp(
                        0.0,
                        (widget.children.length - 1).toDouble(),
                      );
                      _updateActiveIndexAndHaptics();
                    });
                  }
                : null,
            onHorizontalDragEnd: isHorizontal
                ? (details) {
                    final double velocity = details.primaryVelocity ?? 0.0;
                    int target;
                    if (velocity.abs() > 300) {
                      final double pageChange = velocity / 800.0;
                      target = (_scrollOffset - pageChange).round().clamp(
                        0,
                        widget.children.length - 1,
                      );
                    } else {
                      target = _scrollOffset.round();
                    }
                    _animateToPage(target);
                  }
                : null,
            onVerticalDragStart: !isHorizontal
                ? (_) {
                    _animationController.stop();
                    setState(() => _state = CoverflowState.draggingCarousel);
                  }
                : null,
            onVerticalDragUpdate: !isHorizontal
                ? (details) {
                    final double cardStep = widget.style.cardHeight.clamp(
                      100.0,
                      double.infinity,
                    );
                    final double delta =
                        -details.primaryDelta! / (cardStep * 0.65);
                    setState(() {
                      _scrollOffset = (_scrollOffset + delta).clamp(
                        0.0,
                        (widget.children.length - 1).toDouble(),
                      );
                      _updateActiveIndexAndHaptics();
                    });
                  }
                : null,
            onVerticalDragEnd: !isHorizontal
                ? (details) {
                    final double velocity = details.primaryVelocity ?? 0.0;
                    int target;
                    if (velocity.abs() > 300) {
                      final double pageChange = velocity / 800.0;
                      target = (_scrollOffset - pageChange).round().clamp(
                        0,
                        widget.children.length - 1,
                      );
                    } else {
                      target = _scrollOffset.round();
                    }
                    _animateToPage(target);
                  }
                : null,
            child: SizedBox(
              width: isHorizontal ? double.infinity : carouselWidth,
              height: carouselHeight,
              child: Stack(
                clipBehavior: isHorizontal ? Clip.none : Clip.hardEdge,
                children: _buildCoverflowCards(
                  constraints,
                  carouselWidth,
                  carouselHeight,
                ),
              ),
            ),
          );
        }

        if (isHorizontal) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCarousel(),
              const SizedBox(height: 16),
              if (widget.style.showIndexIndicator && widget.children.isNotEmpty)
                Text(
                  '$_currentIntegerIndex',
                  style: widget.style.indexTextStyle,
                ),
              if (widget.style.showSlider && widget.style.showIndexIndicator)
                const SizedBox(height: 16),
              if (widget.style.showSlider && widget.children.isNotEmpty)
                _buildSlider(constraints, carouselHeight),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: buildCarousel()),
              if (widget.style.showSlider || widget.style.showIndexIndicator)
                const SizedBox(width: 16),
              if (widget.style.showSlider || widget.style.showIndexIndicator)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.style.showIndexIndicator &&
                        widget.children.isNotEmpty) ...[
                      Text(
                        '$_currentIntegerIndex',
                        style: widget.style.indexTextStyle,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (widget.style.showSlider && widget.children.isNotEmpty)
                      _buildSlider(constraints, carouselHeight),
                  ],
                ),
            ],
          );
        }
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
  List<Widget> _buildCoverflowCards(
    BoxConstraints constraints,
    double carouselWidth,
    double carouselHeight,
  ) {
    if (widget.children.isEmpty) return const [];

    final bool isHorizontal = widget.scrollDirection == Axis.horizontal;
    final double cardWidth = widget.style.cardWidth;
    final double cardHeight = widget.style.cardHeight;

    // Calculate the total horizontal width including reflection space for vertical mode
    // to keep the combined layout perfectly centered.
    final double reflectionWidth = widget.style.enableReflection
        ? cardWidth * 0.4 + widget.style.reflectionGap
        : 0.0;
    final double totalWidth =
        cardWidth + (isHorizontal ? 0.0 : reflectionWidth);

    final double centerX = isHorizontal
        ? (carouselWidth - cardWidth) / 2
        : ((carouselWidth - totalWidth) / 2 + reflectionWidth);

    final double centerY = isHorizontal
        ? 20.0
        : (carouselHeight - cardHeight) / 2;

    final int scrollTarget = _scrollOffset.round();
    final sortedIndices = List<int>.generate(widget.children.length, (i) => i);
    sortedIndices.sort((a, b) {
      final distA = (a - _scrollOffset).abs();
      final distB = (b - _scrollOffset).abs();
      final cmp = distB.compareTo(distA);
      if (cmp != 0) return cmp;
      final targetDistA = (a - scrollTarget).abs();
      final targetDistB = (b - scrollTarget).abs();
      return targetDistA.compareTo(targetDistB);
    });

    return sortedIndices.map((index) {
      final double diff = index - _scrollOffset;
      final double absDiff = diff.abs();

      final double maxVisibleDiff = isHorizontal ? 6.0 : 3.0;
      if (absDiff > maxVisibleDiff) {
        return const Positioned(child: SizedBox.shrink());
      }

      double opacity = 1.0;
      final double fadeStart = isHorizontal ? 4.0 : 2.0;
      final double fadeEnd = isHorizontal ? 5.0 : 3.0;
      if (absDiff > fadeStart) {
        opacity = (1.0 - (absDiff - fadeStart) / (fadeEnd - fadeStart)).clamp(
          0.0,
          1.0,
        );
      }

      final double tRotation = absDiff.clamp(0.0, 1.0);
      final double smoothTRotation =
          1.0 - (1.0 - tRotation) * (1.0 - tRotation) * (1.0 - tRotation);

      // Rotate Y for horizontal carousel; rotate X for vertical carousel.
      // Symmetrical rotation sign ensures top cards look down and bottom cards look up.
      final double rotationX = isHorizontal
          ? 0.0
          : diff.sign * smoothTRotation * widget.style.maxRotationAngle;
      final double rotationY = isHorizontal
          ? -diff.sign * smoothTRotation * widget.style.maxRotationAngle
          : 0.0;

      final double scale =
          1.0 - (smoothTRotation * (1.0 - widget.style.scaleDelta));

      // Calculate step size along the current scroll axis dimension
      final double stepDimension = isHorizontal ? cardWidth : cardHeight;
      final double baseStep = (stepDimension + widget.style.spacing).clamp(
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
      final double calculatedOffset =
          diff.sign *
          ((transitionPart * centerOffset) + (stackedPart * sideSpacing));

      final double translationX = isHorizontal ? calculatedOffset : 0.0;
      final double translationY = isHorizontal ? 0.0 : calculatedOffset;

      final cardWidget = widget.children[index];

      Widget cardContent = RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            // Block tap-to-navigate while animating or during the post-animation
            // cooldown window. The cooldown guards against the race condition where
            // a double-click's second tap arrives just after animation settle:
            // the layout has shifted by then and the tap hits the wrong card
            // (typically the one the user just left), causing a snap-back.
            if (_tapNavigationLocked) return;
            if (_scrollOffset.round() != index) {
              _animateToPage(index);
            }
          },
          child: _buildCardWrapper(cardWidget),
        ),
      );

      if (opacity < 1.0) {
        cardContent = Opacity(opacity: opacity, child: cardContent);
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
            ..translateByDouble(translationX, translationY, 0.0, 1.0)
            ..rotateX(rotationX)
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
  /// [cardContent], mirror it upside down (or sideways for vertical direction),
  /// and apply a [ShaderMask] with a linear gradient fade-out going from the card
  /// edge to the outer reflection boundary.
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

    final bool isHorizontal = widget.scrollDirection == Axis.horizontal;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: isHorizontal
              ? widget.style.cardHeight + widget.style.reflectionGap
              : 0,
          bottom: isHorizontal ? null : 0,
          left: isHorizontal ? 0 : null,
          right: isHorizontal
              ? 0
              : widget.style.cardWidth + widget.style.reflectionGap,
          height: isHorizontal ? widget.style.cardHeight * 0.4 : null,
          width: isHorizontal ? null : widget.style.cardWidth * 0.4,
          child: Opacity(
            opacity: widget.style.reflectionOpacity,
            child: Align(
              alignment: isHorizontal
                  ? Alignment.topCenter
                  : Alignment.centerRight,
              heightFactor: isHorizontal ? 0.4 : null,
              widthFactor: isHorizontal ? null : 0.4,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: isHorizontal
                        ? Alignment.topCenter
                        : Alignment.centerRight,
                    end: isHorizontal
                        ? Alignment.bottomCenter
                        : Alignment.centerLeft,
                    colors: [Colors.white, Colors.white.withValues(alpha: 0.0)],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(
                    isHorizontal ? 1.0 : -1.0,
                    isHorizontal ? -1.0 : 1.0,
                    1.0,
                  ),
                  child: cardContent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(BoxConstraints constraints, double carouselHeight) {
    final bool isHorizontal = widget.scrollDirection == Axis.horizontal;
    final double trackLength = isHorizontal
        ? (constraints.maxWidth * 0.65).clamp(180.0, 340.0)
        : (carouselHeight * 0.65).clamp(180.0, 340.0);
    final int maxIndex = widget.children.length - 1;
    if (maxIndex <= 0) return const SizedBox.shrink();

    final double progress = _scrollOffset / maxIndex;

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
        final double localPos = isHorizontal
            ? details.localPosition.dx
            : details.localPosition.dy;
        final double tappedProgress = (localPos / trackLength).clamp(0.0, 1.0);
        final int targetPage = (tappedProgress * maxIndex).round();
        _animateToPage(targetPage);
      },
      onHorizontalDragStart: isHorizontal
          ? (_) {
              _animationController.stop();
              setState(() => _state = CoverflowState.draggingSlider);
            }
          : null,
      onHorizontalDragUpdate: isHorizontal
          ? (details) {
              final double delta =
                  details.primaryDelta! / trackLength * maxIndex;
              setState(() {
                _scrollOffset = (_scrollOffset + delta).clamp(
                  0.0,
                  maxIndex.toDouble(),
                );
                _updateActiveIndexAndHaptics();
              });
            }
          : null,
      onHorizontalDragEnd: isHorizontal
          ? (_) {
              final int target = _scrollOffset.round();
              _animateToPage(target);
            }
          : null,
      onVerticalDragStart: !isHorizontal
          ? (_) {
              _animationController.stop();
              setState(() => _state = CoverflowState.draggingSlider);
            }
          : null,
      onVerticalDragUpdate: !isHorizontal
          ? (details) {
              final double delta =
                  details.primaryDelta! / trackLength * maxIndex;
              setState(() {
                _scrollOffset = (_scrollOffset + delta).clamp(
                  0.0,
                  maxIndex.toDouble(),
                );
                _updateActiveIndexAndHaptics();
              });
            }
          : null,
      onVerticalDragEnd: !isHorizontal
          ? (_) {
              final int target = _scrollOffset.round();
              _animateToPage(target);
            }
          : null,
      child: Container(
        width: isHorizontal ? trackLength : widget.style.sliderThumbHeight + 12,
        height: isHorizontal
            ? widget.style.sliderThumbHeight + 12
            : trackLength,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Slider Track Line
            Container(
              width: isHorizontal ? trackLength : widget.style.sliderHeight,
              height: isHorizontal ? widget.style.sliderHeight : trackLength,
              decoration: BoxDecoration(
                color: widget.style.sliderTrackColor,
                borderRadius: BorderRadius.circular(
                  widget.style.sliderHeight / 2,
                ),
              ),
            ),
            // Draggable Thumb
            Positioned(
              left: isHorizontal
                  ? (trackLength - widget.style.sliderThumbWidth) * progress
                  : null,
              top: !isHorizontal
                  ? (trackLength - widget.style.sliderThumbWidth) * progress
                  : null,
              child: AnimatedScale(
                scale: thumbScale,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  width: isHorizontal
                      ? widget.style.sliderThumbWidth
                      : widget.style.sliderThumbHeight,
                  height: isHorizontal
                      ? widget.style.sliderThumbHeight
                      : widget.style.sliderThumbWidth,
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
