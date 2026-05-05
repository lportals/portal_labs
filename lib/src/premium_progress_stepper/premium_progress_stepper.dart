import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'models/premium_progress_stepper_style.dart';

/// A premium progress stepper with physics-based animations (spring)
/// and a tactile feel.
///
/// Features:
/// - Smooth stretching pill animation between steps.
/// - Physics-based bounce on buttons.
/// - Dynamic back button visibility.
/// - Customizable text for the final step.
/// A premium progress indicator that can be used independently of the stepper actions.
/// Ideal for placing at the top of a [PageView] or in an [AppBar].
class PremiumProgressIndicator extends StatefulWidget {
  /// Creates a [PremiumProgressIndicator] with the given parameters.
  const PremiumProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.style = const PremiumProgressStepperStyle(),
  });

  /// Total number of steps in the sequence.
  final int totalSteps;

  /// The index of the current active step (0-indexed).
  final int currentStep;

  /// Visual configuration for the indicator.
  final PremiumProgressStepperStyle style;

  @override
  State<PremiumProgressIndicator> createState() =>
      _PremiumProgressIndicatorState();
}

class _PremiumProgressIndicatorState extends State<PremiumProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController.unbounded(
      vsync: this,
      value: widget.currentStep.toDouble(),
    );
  }

  @override
  void didUpdateWidget(PremiumProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      final simulation = SpringSimulation(
        SpringDescription(
          mass: widget.style.springMass,
          stiffness: widget.style.springStiffness,
          damping: widget.style.springDamping,
        ),
        _indicatorController.value,
        widget.currentStep.toDouble(),
        0,
      );
      _indicatorController.animateWith(simulation);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            (widget.totalSteps - 1) * widget.style.stepSpacing +
                widget.style.indicatorHeight,
            widget.style.indicatorHeight,
          ),
          painter: _StepperPainter(
            progress: _indicatorController.value,
            totalSteps: widget.totalSteps,
            style: widget.style,
          ),
        );
      },
    );
  }
}

/// A high-fidelity progress stepper that combines an indicator with action buttons.
///
/// This widget provides a complete onboarding/flow experience with:
/// - Physics-based spring animations for the progress track.
/// - Tactile bounce feedback on all buttons.
/// - Integrated validation logic via [canContinue].
/// - Automated "Back" button management.
class PremiumProgressStepper extends StatefulWidget {
  /// Creates a [PremiumProgressStepper] with the given configuration.
  const PremiumProgressStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.onStepChanged,
    this.onFinish,
    this.nextText = 'Continue',
    this.finishText = 'Finish',
    this.backText = 'Back',
    this.canContinue = true,
    this.showIndicator = true,
    this.showActions = true,
    this.style = const PremiumProgressStepperStyle(),
  }) : assert(totalSteps > 1, 'Total steps must be at least 2');

  /// Total number of steps in the sequence.
  final int totalSteps;

  /// The current active step (0-indexed).
  final int currentStep;

  /// Callback when the step changes.
  final ValueChanged<int>? onStepChanged;

  /// Callback when the final step is confirmed.
  final VoidCallback? onFinish;

  /// Text for the primary button when not on the last step.
  final String nextText;

  /// Text for the primary button on the last step.
  final String finishText;

  /// The text for the back button.
  final String backText;

  /// Whether the "Next" or "Finish" action is enabled.
  /// Use this to prevent navigation until validation (e.g. form fields) is complete.
  final bool canContinue;

  /// Whether to show the progress dots/bar.
  final bool showIndicator;

  /// Whether to show the back/next action buttons.
  final bool showActions;

  /// The style configuration for the stepper.
  final PremiumProgressStepperStyle style;

  @override
  State<PremiumProgressStepper> createState() => _PremiumProgressStepperState();
}

class _PremiumProgressStepperState extends State<PremiumProgressStepper>
    with TickerProviderStateMixin {
  late AnimationController _backButtonController;

  @override
  void initState() {
    super.initState();

    _backButtonController = AnimationController.unbounded(
      vsync: this,
      value: widget.currentStep > 0 ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(PremiumProgressStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _handleBackButtonVisibility();
    }
  }

  void _handleBackButtonVisibility() {
    final bool shouldShow = widget.currentStep > 0;
    final double target = shouldShow ? 1.0 : 0.0;
    
    final simulation = SpringSimulation(
      SpringDescription(
        mass: widget.style.springMass,
        stiffness: widget.style.springStiffness,
        damping: widget.style.springDamping,
      ),
      _backButtonController.value,
      target,
      0,
    );
    
    _backButtonController.animateWith(simulation);
  }


  @override
  void dispose() {
    _backButtonController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!widget.canContinue) return;

    if (widget.currentStep < widget.totalSteps - 1) {
      widget.onStepChanged?.call(widget.currentStep + 1);
      if (widget.style.enableHaptics) HapticFeedback.lightImpact();
    } else {
      widget.onFinish?.call();
      if (widget.style.enableHaptics) HapticFeedback.mediumImpact();
    }
  }

  void _handleBack() {
    if (widget.currentStep > 0) {
      widget.onStepChanged?.call(widget.currentStep - 1);
      if (widget.style.enableHaptics) HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = widget.currentStep == widget.totalSteps - 1;
    final String buttonText = isLastStep ? widget.finishText : widget.nextText;

    return Container(
      padding: widget.style.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIndicator) ...[
            PremiumProgressIndicator(
              totalSteps: widget.totalSteps,
              currentStep: widget.currentStep,
              style: widget.style,
            ),
            SizedBox(height: widget.style.stepSpacing),
          ],
          if (widget.showActions)
            Row(
              children: [
                // Back Button
                Semantics(
                  button: true,
                  label: widget.backText,
                  hint: 'Goes to the previous step',
                  child: SizeTransition(
                    sizeFactor: _backButtonController,
                    axis: Axis.horizontal,
                    child: FadeTransition(
                      opacity: _backButtonController,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _BounceButton(
                          onPressed: _handleBack,
                          backgroundColor: widget.style.secondaryButtonColor,
                          borderRadius: widget.style.buttonBorderRadius,
                          height: widget.style.buttonHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Text(
                                widget.backText,
                                style: widget.style.buttonTextStyle?.copyWith(
                                      color: widget.style.secondaryButtonTextColor,
                                    ) ??
                                    TextStyle(
                                      color: widget.style.secondaryButtonTextColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Next/Finish Button
                Expanded(
                  child: Semantics(
                    button: true,
                    label: buttonText,
                    enabled: widget.canContinue,
                    hint: isLastStep
                        ? 'Completes the onboarding'
                        : 'Continues to the next step',
                    child: AnimatedBuilder(
                      animation: _backButtonController,
                      builder: (context, child) {
                        final double backVal =
                            _backButtonController.value.clamp(0.0, 1.0);
                        final double expansionPop =
                            (1.0 - backVal) * (1.0 - backVal) * backVal * 0.12;
                        final double scale = 1.0 + expansionPop;

                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: _BounceButton(
                        onPressed: _handleNext,
                        isEnabled: widget.canContinue,
                        onDisabledTap: () {
                          if (widget.style.enableHaptics) {
                            HapticFeedback.vibrate();
                          }
                        },
                        backgroundColor: !widget.canContinue
                            ? widget.style.disabledButtonColor
                            : isLastStep
                                ? (widget.style.finishButtonColor ??
                                    widget.style.primaryButtonColor)
                                : widget.style.primaryButtonColor,
                        borderRadius: widget.style.buttonBorderRadius,
                        height: widget.style.buttonHeight,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Row(
                              key: ValueKey(buttonText),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              if (isLastStep && widget.style.showFinishIcon) ...[
                                if (widget.style.finishIcon != null)
                                  widget.style.finishIcon!
                                else
                                  TweenAnimationBuilder<Color?>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: ColorTween(
                                      begin: widget.canContinue
                                          ? Colors.white
                                          : widget.style.disabledButtonTextColor,
                                      end: widget.canContinue
                                          ? Colors.white
                                          : widget.style.disabledButtonTextColor,
                                    ),
                                    builder: (context, color, _) {
                                      return Icon(
                                        Icons.check_circle_outline,
                                        color: color,
                                        size: 20,
                                      );
                                    },
                                  ),
                                const SizedBox(width: 8),
                              ],
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: widget.style.buttonTextStyle?.copyWith(
                                        color: widget.canContinue
                                            ? widget.style.primaryButtonTextColor
                                            : widget
                                                .style.disabledButtonTextColor,
                                      ) ??
                                      TextStyle(
                                        color: widget.canContinue
                                            ? widget.style.primaryButtonTextColor
                                            : widget
                                                .style.disabledButtonTextColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                  child: Text(buttonText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepperPainter extends CustomPainter {
  _StepperPainter({
    required this.progress,
    required this.totalSteps,
    required this.style,
  });

  final double progress;
  final int totalSteps;
  final PremiumProgressStepperStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final double radius = style.indicatorHeight / 2;
    final double centerY = size.height / 2;

    // Draw background dots
    paint.color = style.inactiveColor;
    for (int i = 0; i < totalSteps; i++) {
      final double x = radius + i * style.stepSpacing;
      canvas.drawCircle(Offset(x, centerY), style.dotSize / 2, paint);
    }

    // Draw stretching pill
    // The pill starts at the first dot and ends at the 'progress' position
    paint.color = style.activeColor;
    
    // We want a pill that covers from 0 to 'progress'
    // But it should look like it's connecting the dots.
    final double startX = radius;
    final double endX = radius + progress * style.stepSpacing;

    final Rect pillRect = Rect.fromLTRB(
      startX - radius,
      centerY - radius,
      endX + radius,
      centerY + radius,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(radius)),
      paint,
    );

    // Draw white dots on active steps
    paint.color = style.dotColor;
    for (int i = 0; i < totalSteps; i++) {
      final double x = radius + i * style.stepSpacing;
      // Calculate how much the dot should be visible based on progress
      // If progress is at i, dotScale is 1.0. If progress is at i-1, dotScale is 0.0.
      final double dotScale = (progress - i + 1.0).clamp(0.0, 1.0);
      
      if (dotScale > 0) {
        canvas.drawCircle(
          Offset(x, centerY), 
          (style.dotSize / 2) * dotScale, 
          paint..color = style.dotColor.withValues(alpha: dotScale),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StepperPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.totalSteps != totalSteps;
}

class _BounceButton extends StatefulWidget {
  const _BounceButton({
    required this.child,
    this.onPressed,
    this.onDisabledTap,
    this.isEnabled = true,
    required this.backgroundColor,
    this.borderRadius = 40,
    this.height = 56,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onDisabledTap;
  final bool isEnabled;
  final Color backgroundColor;
  final double borderRadius;
  final double height;

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isEnabled) {
      widget.onPressed?.call();
    } else {
      widget.onDisabledTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
