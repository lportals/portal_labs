import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import '../common/premium_flip_counter.dart';
import 'models/premium_stepper_style.dart';

/// A minimalist tactile stepper component with mechanical flip animations.
class PremiumStepper extends StatefulWidget {
  /// Creates a [PremiumStepper] widget.
  const PremiumStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.style = const PremiumStepperStyle(),
    this.enableHaptics = true,
    this.minusIcon = Icons.remove,
    this.plusIcon = Icons.add,
  });

  /// The current value of the stepper.
  final int value;

  /// The minimum allowed value.
  final int min;

  /// The maximum allowed value.
  final int max;

  /// Callback when the value changes.
  final ValueChanged<int> onChanged;

  /// Visual configuration for the stepper.
  final PremiumStepperStyle style;

  /// Whether to enable haptic feedback on change.
  final bool enableHaptics;

  /// Custom icon for the decrement button.
  final IconData minusIcon;

  /// Custom icon for the increment button.
  final IconData plusIcon;

  @override
  State<PremiumStepper> createState() => _PremiumStepperState();
}

class _PremiumStepperState extends State<PremiumStepper> {
  bool _upward = true;

  void _handleIncrement() {
    if (widget.value < widget.max) {
      setState(() => _upward = true);
      widget.onChanged(widget.value + 1);
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleDecrement() {
    if (widget.value > widget.min) {
      setState(() => _upward = false);
      widget.onChanged(widget.value - 1);
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.style.padding,
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
        border: Border.all(color: widget.style.borderColor, width: widget.style.borderWidth),
        boxShadow: widget.style.shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            key: const ValueKey('stepper_minus'),
            icon: widget.minusIcon,
            onPressed: _handleDecrement,
            enabled: widget.value > widget.min,
            style: widget.style,
            label: 'Decrement',
          ),
          SizedBox(
            width: widget.style.valueWidth, 
            height: widget.style.buttonSize, 
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: PremiumFlipCounter(
                value: widget.value,
                upward: _upward,
                style: widget.style.textStyle,
                padWithZero: false,
                maxDigits: widget.style.maxDigits,
              ),
            ),
          ),
          _StepperButton(
            key: const ValueKey('stepper_plus'),
            icon: widget.plusIcon,
            onPressed: _handleIncrement,
            enabled: widget.value < widget.max,
            style: widget.style,
            label: 'Increment',
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  /// Creates a [_StepperButton] widget.
  const _StepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.enabled,
    required this.style,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final PremiumStepperStyle style;
  final String label;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: PortalSpringCurve()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActuallyEnabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: isActuallyEnabled,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: isActuallyEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: isActuallyEnabled ? (_) => _controller.forward() : null,
          onTapUp: isActuallyEnabled ? (_) => _controller.reverse() : null,
          onTapCancel: isActuallyEnabled ? () => _controller.reverse() : null,
          onTap: isActuallyEnabled ? widget.onPressed : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.style.buttonSize,
              height: widget.style.buttonSize,
              decoration: BoxDecoration(
                shape: widget.style.buttonBorderRadius == null ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: widget.style.buttonBorderRadius != null 
                    ? BorderRadius.circular(widget.style.buttonBorderRadius!) 
                    : null,
                color: isActuallyEnabled
                    ? (_isHovered
                        ? widget.style.buttonColor.withValues(alpha: 0.8)
                        : widget.style.buttonColor)
                    : widget.style.buttonColor.withValues(alpha: 0.3),
              ),
              child: Icon(
                widget.icon,
                color: isActuallyEnabled
                    ? widget.style.iconColor
                    : widget.style.iconColor.withValues(alpha: 0.3),
                size: widget.style.iconSize ?? (widget.style.buttonSize * 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

