import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'models/feedback_interaction_style.dart';
import '../common/portal_animations.dart';

/// A premium, high-fidelity feedback component that uses asymmetric spring physics to transition between selection states. Designed for high-fidelity tactile response and zero-latency interaction.
class FeedbackInteraction extends StatefulWidget {
  /// Creates a [FeedbackInteraction] with the given callbacks and configuration.
  const FeedbackInteraction({
    super.key,
    this.onFeedbackSubmitted,
    this.onUndo,
    this.message = 'Feedback Received',
    this.undoLabel = 'Undo',
    this.style = const FeedbackInteractionStyle(),
  });

  /// Callback triggered when feedback is submitted.
  final Function(bool isPositive)? onFeedbackSubmitted;

  /// Callback triggered when the feedback is undone.
  final VoidCallback? onUndo;

  /// The message displayed in the expanded pill.
  final String message;

  /// The label for the undo button.
  final String undoLabel;

  /// The style configuration for the widget.
  final FeedbackInteractionStyle style;

  @override
  State<FeedbackInteraction> createState() => _FeedbackInteractionState();
}

class _FeedbackInteractionState extends State<FeedbackInteraction>
    with SingleTickerProviderStateMixin {
  bool _isInteractivityLocked = false;
  bool? _isPositive;

  late final AnimationController _morphController;

  // Use physics-driven simulations for all transitions to ensure
  // smooth, interruptible motion.
  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      value: 0.0,
      lowerBound: -0.5,
      upperBound: 1.5,
    );
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  TickerFuture _runSpringAnimation({required double target}) {
    final style = widget.style;
    final bool isClosing = target == 0.0;

    // Physics-driven simulation using style-defined parameters.
    // We apply principled ratios to differentiate the "opening" energy
    // from the "magnetic" closing energy.
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: isClosing
          ? style.springStiffness * 1.1
          : style.springStiffness,
      damping: isClosing ? style.springDamping * 1.1 : style.springDamping,
    );

    final simulation = SpringSimulation(
      spring,
      _morphController.value,
      target,
      0.0,
    );

    return _morphController.animateWith(simulation);
  }

  void _handleFeedback(bool isPositive) {
    if (widget.style.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _isInteractivityLocked = true;
      _isPositive = isPositive;
    });

    _runSpringAnimation(target: 1.0);
    widget.onFeedbackSubmitted?.call(isPositive);
  }

  void _handleUndo() {
    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    _runSpringAnimation(target: 0.0).whenComplete(() {
      if (mounted) {
        setState(() {
          _isInteractivityLocked = false;
          _isPositive = null;
        });
      }
    });

    // Early interactivity restoration: allow clicking as soon as buttons are near home.
    void unlockListener() {
      if (_morphController.value < widget.style.settleThreshold) {
        _morphController.removeListener(unlockListener);
        if (mounted) {
          setState(() {
            _isInteractivityLocked = false;
          });
        }
      }
    }

    _morphController.addListener(unlockListener);
    widget.onUndo?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final totalIdleWidth = (style.buttonInitialWidth * 2) + style.spacing;
    final double expandedWidth = style.pillExpandedWidth;
    const double height = 60.0;

    return Center(
      child: AnimatedBuilder(
        animation: _morphController,
        builder: (context, child) {
          final double currentWidth = lerpDouble(
            totalIdleWidth,
            expandedWidth,
            _morphController.value,
          )!;

          // Construct buttons inside builder to ensure they use current animation values
          final List<Widget> children = [
            _buildAnimatedButton(
              isPositive: true,
              isSelected: _isPositive == true,
              totalIdleWidth: totalIdleWidth,
              expandedWidth: expandedWidth,
              height: height,
            ),
            _buildAnimatedButton(
              isPositive: false,
              isSelected: _isPositive == false,
              totalIdleWidth: totalIdleWidth,
              expandedWidth: expandedWidth,
              height: height,
            ),
          ];

          // Ensure selected button is always on top for z-index
          if (_isPositive == true) {
            final pos = children.removeAt(0);
            children.add(pos);
          }

          return SizedBox(
            width: currentWidth,
            height: height,
            child: Stack(clipBehavior: Clip.none, children: children),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedButton({
    required bool isPositive,
    required bool isSelected,
    required double totalIdleWidth,
    required double expandedWidth,
    required double height,
  }) {
    final style = widget.style;
    final bool isAnySelected = _isPositive != null;

    final double initialLeft = isPositive
        ? 0
        : (style.buttonInitialWidth + style.spacing);

    // Smoothly transition from individual slot to full pill
    final double currentLeft = isSelected
        ? lerpDouble(initialLeft, 0.0, _morphController.value)!
        : initialLeft;

    final double currentWidth = isSelected
        ? lerpDouble(
            style.buttonInitialWidth,
            expandedWidth,
            _morphController.value,
          )!
        : style.buttonInitialWidth;

    // To keep the icon perfectly centered in the growing container, we calculate
    // the delta between the pill's center and the button's center.
    // We multiply by the controller value to "decay" the offset as we return to
    // the idle state, ensuring a seamless landing in the original slot.
    final double currentContainerWidth = lerpDouble(
      totalIdleWidth,
      expandedWidth,
      _morphController.value,
    )!;
    final double containerCenter = currentContainerWidth / 2;
    final double buttonCenter = currentLeft + (currentWidth / 2);

    final double contentOffset = isSelected
        ? (containerCenter - buttonCenter) *
              _morphController.value.clamp(0.0, 1.0)
        : 0.0;

    double opacity = 1.0;
    double blur = 0.0;
    if (isAnySelected && !isSelected) {
      opacity = (1.0 - (_morphController.value * style.fadeVelocity)).clamp(
        0.0,
        1.0,
      );
      blur = _morphController.value.clamp(0.0, 1.0) * style.maxBlur;
    }

    return Positioned(
      left: currentLeft,
      width: currentWidth,
      height: height,
      child: IgnorePointer(
        ignoring: _isInteractivityLocked && !isSelected,
        child: Opacity(
          opacity: opacity,
          child: _BlurEffect(
            blur: blur,
            child: _FeedbackPressable(
              onTap: () => _handleFeedback(isPositive),
              isExpanded: _isInteractivityLocked,
              style: style,
              child: Transform.translate(
                offset: Offset(contentOffset, 0),
                child: _buildButtonContent(isPositive, isSelected),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isPositive, bool isSelected) {
    final style = widget.style;
    final icon = isPositive ? style.positiveIcon : style.negativeIcon;

    return Center(
      child: OverflowBox(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: style.foregroundColor),

            if (isSelected)
              SizeTransition(
                sizeFactor: _morphController,
                axis: Axis.horizontal,
                axisAlignment: -1.0,
                child: Opacity(
                  opacity: ((_morphController.value - 0.4) / 0.6).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        widget.message,
                        style:
                            style.messageTextStyle ??
                            TextStyle(
                              color: style.foregroundColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: -0.2,
                              height: 1.0,
                            ),
                      ),
                      const SizedBox(width: 10),
                      _buildUndoButton(style),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoButton(FeedbackInteractionStyle style) {
    return GestureDetector(
      onTap: _handleUndo,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: style.undoBackgroundColor,
          borderRadius: style.undoBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.undoIcon, color: style.foregroundColor, size: 12),
            const SizedBox(width: 4),
            Text(
              widget.undoLabel,
              style:
                  style.undoTextStyle ??
                  TextStyle(
                    color: style.foregroundColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurEffect extends StatelessWidget {
  const _BlurEffect({required this.blur, required this.child});
  final double blur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (blur <= 0.1) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child,
    );
  }
}

class _FeedbackPressable extends StatefulWidget {
  const _FeedbackPressable({
    required this.child,
    required this.onTap,
    required this.isExpanded,
    required this.style,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isExpanded;
  final FeedbackInteractionStyle style;

  @override
  State<_FeedbackPressable> createState() => _FeedbackPressableState();
}

class _FeedbackPressableState extends State<_FeedbackPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: const PortalSpringCurve()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isExpanded) {
          _controller.forward();
        }
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isExpanded ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: widget.style.borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: widget.child,
        ),
      ),
    );
  }
}
