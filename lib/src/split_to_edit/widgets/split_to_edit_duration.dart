import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/split_to_edit_style.dart';
import '../../common/portal_animations.dart';

/// A premium, highly interactive dual-value picker that "splits" to edit.
///
/// Features a smooth, calm bounce transition when expanding/collapsing,
/// and a cinematic blurred icon transition. Fully responsive to external state
/// updates and highly customizable for any pair of numeric values.
class SplitToEditDuration extends StatefulWidget {
  /// Creates a [SplitToEditDuration] with the given configuration.
  const SplitToEditDuration({
    super.key,
    required this.hours,
    required this.minutes,
    this.onChanged,
    this.style = const SplitToEditStyle(),
    this.leftUnitLabel = 'Hr.',
    this.rightUnitLabel = 'Min.',
    this.maxLeftValue = 23,
    this.maxRightValue = 59,
  });

  /// The initial left value (usually hours).
  final int hours;

  /// The initial right value (usually minutes).
  final int minutes;

  /// The label for the left segment. Defaults to 'Hr.'.
  final String leftUnitLabel;

  /// The label for the right segment. Defaults to 'Min.'.
  final String rightUnitLabel;

  /// The maximum allowed value for the left segment. Defaults to 23.
  final int maxLeftValue;

  /// The maximum allowed value for the right segment. Defaults to 59.
  final int maxRightValue;

  /// Callback when the values change and the component is closed.
  final void Function(int leftValue, int rightValue)? onChanged;

  /// Style configuration for the component.
  final SplitToEditStyle style;

  @override
  State<SplitToEditDuration> createState() => _SplitToEditDurationState();
}

class _SplitToEditDurationState extends State<SplitToEditDuration>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;

  late TextEditingController _leftController;
  late TextEditingController _rightController;

  final FocusNode _leftFocusNode = FocusNode();
  final FocusNode _rightFocusNode = FocusNode();

  late final AnimationController _controller;
  
  // High-fidelity staggered animations
  late final Animation<double> _leftAnimation;
  late final Animation<double> _rightAnimation;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController(text: '${widget.hours}');
    _rightController = TextEditingController(text: '${widget.minutes}');

    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );

    // Listen to changes to update dynamic widths while typing
    _leftController.addListener(_onTextChanged);
    _rightController.addListener(_onTextChanged);

    // Opening curves from style or generated from physics parameters
    final openingCurve = widget.style.bounceCurve ?? 
        PortalSpringCurve(
          stiffness: widget.style.stiffness,
          damping: widget.style.damping,
          mass: widget.style.mass,
        );
        
    final closingCurve = widget.style.closeCurve?.flipped ?? 
        PortalSpringCurve(
          stiffness: widget.style.stiffness * 0.8, // Slightly softer closing
          damping: widget.style.damping * 1.4,     // More damped closing for fluidity
          mass: widget.style.mass,
        ).flipped;

    // Symmetrical staggering: Left starts first when opening, 
    // Right starts first when closing for a natural "pulling" feel.
    _leftAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.75, curve: openingCurve),
      reverseCurve: Interval(0.2, 0.95, curve: closingCurve),
    );

    _rightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.02, 0.77, curve: openingCurve),
      reverseCurve: Interval(0.22, 1.0, curve: closingCurve),
    );
  }

  @override
  void didUpdateWidget(covariant SplitToEditDuration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hours != widget.hours && !_isEditing) {
      _leftController.text = '${widget.hours}';
    }
    if (oldWidget.minutes != widget.minutes && !_isEditing) {
      _rightController.text = '${widget.minutes}';
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _leftController.removeListener(_onTextChanged);
    _rightController.removeListener(_onTextChanged);
    _leftController.dispose();
    _rightController.dispose();
    _leftFocusNode.dispose();
    _rightFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // 1. Validate Left Value
      int l = int.tryParse(_leftController.text) ?? widget.hours;
      l = l.clamp(0, widget.maxLeftValue);
      _leftController.text = l.toString();

      // 2. Validate Right Value
      int r = int.tryParse(_rightController.text) ?? widget.minutes;
      r = r.clamp(0, widget.maxRightValue);
      _rightController.text = r.toString();

      // 3. Commit changes & close keyboard
      widget.onChanged?.call(l, r);
      FocusScope.of(context).unfocus();
      _controller.reverse();
    } else {
      _controller.forward();
    }

    setState(() {
      _isEditing = !_isEditing;
    });

    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.style.backgroundColor ?? Colors.white;
    final borderRadius = widget.style.borderRadius ?? 20.0;
    final spacing = widget.style.spacing;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final leftVal = _leftAnimation.value;
        final rightVal = _rightAnimation.value;
        
        // Use the average for unified visual properties like shadow/radius
        final unifiedProgress = (leftVal + rightVal) / 2;
        final clampedProgress = unifiedProgress.clamp(0.0, 1.0);

        final double leftShift = leftVal * spacing;
        final double rightShift = rightVal * spacing;
        
        // No overlap correction needed when widths are tight
        const double overlapCorrection = 0.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08 * (1.0 - clampedProgress).clamp(0.0, 1.0),
                ),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Left Segment (Moves LEFT)
              Transform.translate(
                offset: Offset(-leftShift - overlapCorrection, 0),
                child: _SegmentWrapper(
                  isEditing: _isEditing,
                  splitProgress: leftVal,
                  borderRadius: borderRadius,
                  bgColor: bgColor,
                  position: _SegmentPosition.left,
                  style: widget.style,
                  onTap: () {
                    if (_isEditing) _leftFocusNode.requestFocus();
                  },
                  child: _EditableValueUnit(
                    controller: _leftController,
                    focusNode: _leftFocusNode,
                    unit: widget.leftUnitLabel,
                    isEditing: _isEditing,
                    style: widget.style,
                    progress: leftVal,
                  ),
                ),
              ),

              // 2. Middle Segment (Stationary / Reveal)
              _SegmentWrapper(
                isEditing: _isEditing,
                splitProgress: unifiedProgress,
                borderRadius: borderRadius,
                bgColor: bgColor,
                position: _SegmentPosition.middle,
                style: widget.style,
                onTap: () {
                  if (_isEditing) _rightFocusNode.requestFocus();
                },
                child: _EditableValueUnit(
                  controller: _rightController,
                  focusNode: _rightFocusNode,
                  unit: widget.rightUnitLabel,
                  isEditing: _isEditing,
                  style: widget.style,
                  progress: unifiedProgress,
                ),
              ),

              // 3. Action Segment (Moves RIGHT) - THE TRIGGER
              Transform.translate(
                offset: Offset(rightShift + overlapCorrection, 0),
                child: _SegmentWrapper(
                  isEditing: _isEditing,
                  splitProgress: rightVal,
                  borderRadius: borderRadius,
                  bgColor: bgColor,
                  position: _SegmentPosition.right,
                  style: widget.style,
                  onTap: _toggleEdit, // Always active as it's the trigger
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          final blurAmount = (1.0 - animation.value) * 6.0;
                          if (blurAmount < 0.05) {
                            return FadeTransition(opacity: animation, child: child);
                          }
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: blurAmount,
                              sigmaY: blurAmount,
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                                ),
                                child: child,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      key: ValueKey(_isEditing),
                      color: _isEditing ? Colors.black : Colors.black.withValues(alpha: 0.54),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _SegmentPosition { left, middle, right }

class _SegmentWrapper extends StatefulWidget {
  const _SegmentWrapper({
    required this.child,
    required this.isEditing,
    required this.splitProgress,
    required this.borderRadius,
    required this.bgColor,
    required this.position,
    required this.onTap,
    required this.style,
  });

  final Widget child;
  final bool isEditing;
  final double splitProgress;
  final double borderRadius;
  final Color bgColor;
  final _SegmentPosition position;
  final VoidCallback onTap;
  final SplitToEditStyle style;

  @override
  State<_SegmentWrapper> createState() => _SegmentWrapperState();
}

class _SegmentWrapperState extends State<_SegmentWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isAction = widget.position == _SegmentPosition.right;
    final clampedProgress = widget.splitProgress.clamp(0.0, 1.0);

    final lerpRadius = BorderRadius.circular(widget.borderRadius);
    BorderRadius mergedRadius;
    switch (widget.position) {
      case _SegmentPosition.left:
        mergedRadius = BorderRadius.horizontal(left: Radius.circular(widget.borderRadius));
      case _SegmentPosition.middle:
        mergedRadius = BorderRadius.zero;
      case _SegmentPosition.right:
        mergedRadius = BorderRadius.horizontal(right: Radius.circular(widget.borderRadius));
    }

    final currentRadius = BorderRadius.lerp(mergedRadius, lerpRadius, clampedProgress)!;

    // Use internal padding from style
    final basePadding = widget.style.padding as EdgeInsets;

    // Asymmetric padding logic using style tokens to squeeze internal gaps while protecting outer edges
    double leftPadding = basePadding.left;
    double rightPadding = basePadding.right;

    if (!widget.isEditing) {
      // 1. LEFT SEGMENT: Protect outer left, squeeze inner right
      if (widget.position == _SegmentPosition.left) {
        rightPadding = lerpDouble(widget.style.innerSpacing, basePadding.right, clampedProgress)!;
      }
      // 2. MIDDLE SEGMENT: Squeeze both sides to stay tight
      if (widget.position == _SegmentPosition.middle) {
        leftPadding = lerpDouble(widget.style.innerSpacing, basePadding.left, clampedProgress)!;
        rightPadding = lerpDouble(0.0, basePadding.right, clampedProgress)!;
      }
      // 3. ACTION SEGMENT: Squeeze inner left, protect outer right
      if (isAction) {
        leftPadding = lerpDouble(0.0, basePadding.left, clampedProgress)!;
        rightPadding = basePadding.right; // Maintain outer edge
      }
    }

    // Dynamic width using style tokens
    final actionWidth = lerpDouble(
      widget.style.actionWidthClosed, 
      widget.style.actionWidthExpanded, 
      clampedProgress,
    )!;
    
    final minWidth = isAction 
      ? actionWidth 
      : lerpDouble(0.0, 120.0, clampedProgress)!;

    return GestureDetector(
      // Only handle taps and pulse if expanded OR if it's the action button
      onTapDown: !widget.isEditing && !isAction ? null : (_) => setState(() => _isPressed = true),
      onTapUp: !widget.isEditing && !isAction ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: !widget.isEditing && !isAction ? null : () => setState(() => _isPressed = false),
      onTap: !widget.isEditing && !isAction ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed && (widget.isEditing || isAction) ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: PortalSpringCurve(
          stiffness: widget.style.stiffness,
          damping: widget.style.damping,
          mass: widget.style.mass,
        ),
        child: Container(
          height: 64,
          width: isAction ? actionWidth : null,
          constraints: BoxConstraints(minWidth: minWidth),
          padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: currentRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08 * clampedProgress,
                ),
                blurRadius: 40,
                offset: Offset(0, 8 * clampedProgress),
              ),
            ],
          ),
          child: ClipRect(
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _EditableValueUnit extends StatelessWidget {
  const _EditableValueUnit({
    required this.controller,
    required this.focusNode,
    required this.unit,
    required this.isEditing,
    required this.style,
    required this.progress,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String unit;
  final bool isEditing;
  final SplitToEditStyle style;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textStyle = style.textStyle ??
        const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -1.0,
        );

    final unitStyle = style.unitStyle ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.4),
          letterSpacing: -0.5,
        );

    // Calculate natural width of the text to enable perfectly fluid width transitions
    final textPainter = TextPainter(
      text: TextSpan(text: controller.text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    
    final naturalWidth = textPainter.width;
    
    // Use a dynamic target width: natural width plus a small editing buffer (12px)
    // when expanded. This makes the component feel "alive" and tailored to its content.
    final targetWidth = naturalWidth + (style.fieldWidth - 24.0).clamp(8.0, 16.0);
    
    final currentFieldWidth = lerpDouble(naturalWidth, targetWidth, progress)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: currentFieldWidth,
          child: isEditing
              ? TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: isEditing,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  cursorColor: Colors.black,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style: textStyle,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    counterText: '',
                  ),
                )
              : Text(
                  controller.text,
                  style: textStyle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                ),
        ),
        const SizedBox(width: 4),
        Text(unit, style: unitStyle),
      ],
    );
  }
}
