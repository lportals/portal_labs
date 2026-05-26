import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/stacked_cards_style.dart';

export 'models/stacked_cards_style.dart';

/// Interaction states of the [StackedCards].
enum StackedCardsState {
  /// The cards are at rest and not being interacted with.
  idle,

  /// The user is dragging the cards horizontally.
  dragging,

  /// The cards are animating/snapping to a target index.
  animating,
}

/// A premium, gesture-driven stacked card carousel.
///
/// Displays a list of children cards where the active card is positioned in front,
/// and subsequent cards are stacked behind it, translated and optionally rotated.
/// Users can swipe horizontally to cycle through cards. Swiping left slides the
/// current card off the screen, revealing the stack underneath. Supports spring-based
/// snapping physics, page indicators, and haptic feedback.
class StackedCards extends StatefulWidget {
  /// Creates a [StackedCards] carousel.
  const StackedCards({
    super.key,
    required this.children,
    this.style = const StackedCardsStyle(),
    this.rotationEnabled = true,
    this.showsScrollIndicator = false,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.enableHaptics = true,
  });

  /// The list of widgets to display as cards in the stack.
  final List<Widget> children;

  /// Layout and visual configuration for the widget.
  final StackedCardsStyle style;

  /// Whether stacked cards underneath are slightly rotated clockwise to create a fan effect.
  final bool rotationEnabled;

  /// Whether to show a page indicator at the bottom of the card stack.
  final bool showsScrollIndicator;

  /// The initial card index to display.
  final int initialIndex;

  /// Callback triggered when the active card index changes.
  final ValueChanged<int>? onIndexChanged;

  /// Whether to trigger haptic feedback on card transitions.
  final bool enableHaptics;

  @override
  State<StackedCards> createState() => _StackedCardsState();
}

class _StackedCardsState extends State<StackedCards>
    with SingleTickerProviderStateMixin {
  late double _scrollOffset;
  late AnimationController _animationController;
  late int _currentIndex;

  double _scrollStartValue = 0.0;
  double _scrollTargetValue = 0.0;
  StackedCardsState _state = StackedCardsState.idle;
  int _lastTriggeredHapticIndex = -1;
  bool _hasDragged = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.children.length - 1);
    _scrollOffset = _currentIndex.toDouble();
    _lastTriggeredHapticIndex = _currentIndex;

    _animationController = AnimationController(vsync: this);
    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (mounted && _state == StackedCardsState.animating) {
          setState(() {
            _scrollOffset = _scrollTargetValue;
            _state = StackedCardsState.idle;
          });
          _updateActiveIndex();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationTick() {
    setState(() {
      _scrollOffset = lerpDouble(
        _scrollStartValue,
        _scrollTargetValue,
        widget.style.snapCurve.transform(_animationController.value),
      )!;
      _updateActiveIndex();
    });
  }

  void _updateActiveIndex() {
    final int newIndex = _scrollOffset.round().clamp(0, widget.children.length - 1);
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      widget.onIndexChanged?.call(_currentIndex);
    }

    if (widget.enableHaptics && newIndex != _lastTriggeredHapticIndex) {
      HapticFeedback.lightImpact();
      _lastTriggeredHapticIndex = newIndex;
    }
  }

  /// Animates the stack to a specific card index.
  void _animateToPage(int page) {
    final double target = page.toDouble().clamp(0.0, (widget.children.length - 1).toDouble());

    // If we are already at the target page, immediately settle to idle to avoid
    // starting a redundant animation that triggers visual jumps/flickers.
    if (_scrollOffset == target) {
      setState(() => _state = StackedCardsState.idle);
      return;
    }

    if (_state == StackedCardsState.animating && _scrollTargetValue == target) {
      return;
    }

    _animationController.stop();
    _scrollStartValue = _scrollOffset;
    _scrollTargetValue = target;
 
    setState(() => _state = StackedCardsState.animating);

    // Calculate a dynamic duration based on the distance to travel.
    final double distance = (_scrollTargetValue - _scrollStartValue).abs();
    final int durationMs = (distance <= 1.0)
        ? 450
        : (350 + (distance * 100).round()).clamp(450, 750);

    _animationController.duration = Duration(milliseconds: durationMs);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _animationController.stop();
                _hasDragged = false;
              },
              onHorizontalDragUpdate: (details) {
                // Use the exact card width as the divisor for a perfect 1:1 tracking feel.
                final double delta = -details.primaryDelta! / widget.style.cardWidth;
                setState(() {
                  if (!_hasDragged) {
                    _hasDragged = true;
                    _state = StackedCardsState.dragging;
                  }
                  _scrollOffset = (_scrollOffset + delta).clamp(
                    0.0,
                    (widget.children.length - 1).toDouble(),
                  );
                  _updateActiveIndex();
                });
              },
              onHorizontalDragEnd: (details) {
                if (!_hasDragged) {
                  setState(() => _state = StackedCardsState.idle);
                  return;
                }
                final double velocity = details.primaryVelocity ?? 0.0;
                int target;
                if (velocity.abs() > 300) {
                  // A swift flick advances or goes back by exactly one card.
                  if (velocity < 0) {
                    target = (_scrollOffset.floor() + 1).clamp(0, widget.children.length - 1);
                  } else {
                    target = (_scrollOffset.ceil() - 1).clamp(0, widget.children.length - 1);
                  }
                } else {
                  // Standard snap to nearest card.
                  target = _scrollOffset.round();
                }
                _animateToPage(target);
              },
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: widget.rotationEnabled ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, rotationFactor, child) {
                  return SizedBox(
                    height: widget.style.cardHeight,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _buildStackedCards(constraints.maxWidth, rotationFactor),
                    ),
                  );
                },
              ),
            ),
            if (widget.showsScrollIndicator) ...[
              const SizedBox(height: 24),
              _buildPageIndicator(),
            ],
          ],
        );
      },
    );
  }

  /// Builds and layers cards from back to front using descending index order.
  List<Widget> _buildStackedCards(double maxWidth, double rotationFactor) {
    final double remainingCards = (widget.children.length - _scrollOffset).clamp(1.0, widget.style.maxStackedItems.toDouble());
    final double actualStackExtension =
        (remainingCards - 1.0) * widget.style.horizontalOffset * (1.0 - rotationFactor);
    final double centerX = (maxWidth - widget.style.cardWidth - actualStackExtension) / 2;

    final List<int> sortedIndices = List<int>.generate(widget.children.length, (i) => i);
    // Sort descending so smaller indices (front / swiped items) are painted last
    sortedIndices.sort((a, b) => b.compareTo(a));

    return sortedIndices.map((index) {
      final double diff = index - _scrollOffset;

      double translationX = 0.0;
      double scale = 1.0;
      double rotation = 0.0;
      double opacity = 1.0;

      // Determine if this card is considered swiped away.
      // During animation, we freeze this classification to the target index to prevent
      // spring overshoot oscillations from toggling the layout formulas and causing jitters.
      final bool isSwipedAway = _state == StackedCardsState.animating
          ? index < _scrollTargetValue
          : index < _scrollOffset;

      if (isSwipedAway) {
        // Card is swiped away to the left. We use a linear exit translation with a 60px
        // safety buffer to keep the speed uniform and prevent aggressive acceleration.
        final double exitFactor = widget.style.cardWidth + centerX + 60.0;
        translationX = diff * exitFactor;
        scale = 1.0;
        rotation = 0.0;
        opacity = diff <= -1.0 ? 0.0 : 1.0;
      } else {
        // Card is active or stacked in the background.
        // We smoothly interpolate the translation based on the rotationFactor to create a stunning transition:
        // - When rotation is disabled (rotationFactor = 0.0), cards have standard depth translation offset.
        // - When rotation is enabled (rotationFactor = 1.0), cards pivot from the bottom-right corner with 0.0 translation.
        final double clampedDiff = diff.clamp(0.0, widget.style.maxStackedItems.toDouble() - 1);
        translationX = clampedDiff * widget.style.horizontalOffset * (1.0 - rotationFactor);
        scale = 1.0 - (clampedDiff * widget.style.scaleDelta);
        rotation = clampedDiff * widget.style.rotationAngle * rotationFactor;
        // Cards exceeding the max stacked limit are clamped to the last visible slot
        // and kept fully opaque (opacity = 1.0) to create a premium overlapping stack reveal effect.
        opacity = 1.0;
      }

      final Alignment alignment = Alignment.lerp(
        Alignment.center,
        widget.style.alignment,
        rotationFactor,
      ) ?? Alignment.center;

      if (opacity <= 0.0) {
        return const Positioned(child: SizedBox.shrink());
      }

      return Positioned(
        left: centerX + translationX,
        top: 0,
        width: widget.style.cardWidth,
        height: widget.style.cardHeight,
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: alignment,
            transform: Matrix4.identity()
              ..rotateZ(rotation)
              // ignore: deprecated_member_use
            ..scale(scale),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.style.borderRadius),
                boxShadow: widget.style.shadows ??
                    [
                      BoxShadow(
                        color: widget.style.shadowColor,
                        blurRadius: widget.style.shadowBlurRadius,
                        offset: widget.style.shadowOffset,
                      ),
                    ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.style.borderRadius),
                child: widget.children[index],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Builds a smooth, morphing dot indicator.
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.children.length, (index) {
        final double diff = (index - _scrollOffset).abs();
        final double activePercentage = (1.0 - diff).clamp(0.0, 1.0);

        final double width = lerpDouble(
          widget.style.indicatorSize,
          widget.style.indicatorSize * 2.5,
          activePercentage,
        )!;

        final Color color = Color.lerp(
          widget.style.indicatorInactiveColor,
          widget.style.indicatorActiveColor,
          activePercentage,
        )!;

        return Container(
          width: width,
          height: widget.style.indicatorSize,
          margin: EdgeInsets.symmetric(horizontal: widget.style.indicatorSpacing / 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.style.indicatorSize / 2),
          ),
        );
      }),
    );
  }
}
