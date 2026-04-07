import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/split_to_edit_style.dart';

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

class _SplitToEditDurationState extends State<SplitToEditDuration> {
  bool _isEditing = false;
  
  late TextEditingController _leftController;
  late TextEditingController _rightController;
  
  final FocusNode _leftFocusNode = FocusNode();
  final FocusNode _rightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController(text: '${widget.hours}');
    _rightController = TextEditingController(text: '${widget.minutes}');
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

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _leftFocusNode.dispose();
    _rightFocusNode.dispose();
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
    } else {
      // UX Enhancement: Auto-focus the first field when opening
      _leftFocusNode.requestFocus();
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
    
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    // Reverted specifically to Colors.white to ensure the premium, clean aesthetic
    // is not ruined by Material 3 default surface tints.
    final bgColor = widget.style.backgroundColor ?? Colors.white;
    final borderRadius = widget.style.borderRadius ?? 20.0;
    
    const baseSpacing = 16.0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      curve: const ElasticOutCurve(0.6),
      tween: Tween<double>(begin: 0.0, end: _isEditing ? 1.0 : 0.0),
      builder: (context, splitProgress, child) {
        final clampedProgress = splitProgress.clamp(0.0, 1.0);
        
        final double expansionShift = splitProgress * baseSpacing;
        final double overlapCorrection = -2.5 * (1.0 - clampedProgress);

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
                offset: Offset(-expansionShift - overlapCorrection, 0),
                child: _SegmentWrapper(
                  isEditing: _isEditing,
                  splitProgress: splitProgress,
                  borderRadius: borderRadius,
                  bgColor: bgColor,
                  position: _SegmentPosition.left,
                  onTap: () {
                    if (_isEditing) _leftFocusNode.requestFocus();
                  },
                  child: _EditableValueUnit(
                    controller: _leftController,
                    focusNode: _leftFocusNode,
                    unit: widget.leftUnitLabel,
                    isEditing: _isEditing,
                    style: widget.style,
                  ),
                ),
              ),

              // 2. Right Segment (Anchor at Center - NO SHIFT)
              _SegmentWrapper(
                isEditing: _isEditing,
                splitProgress: splitProgress,
                borderRadius: borderRadius,
                bgColor: bgColor,
                position: _SegmentPosition.middle,
                onTap: () {
                  if (_isEditing) _rightFocusNode.requestFocus();
                },
                child: _EditableValueUnit(
                  controller: _rightController,
                  focusNode: _rightFocusNode,
                  unit: widget.rightUnitLabel,
                  isEditing: _isEditing,
                  style: widget.style,
                ),
              ),

              // 3. Action Segment (Moves RIGHT)
              Transform.translate(
                offset: Offset(expansionShift + overlapCorrection, 0),
                child: _SegmentWrapper(
                  isEditing: _isEditing,
                  splitProgress: splitProgress,
                  borderRadius: borderRadius,
                  bgColor: bgColor,
                  position: _SegmentPosition.right,
                  onTap: _toggleEdit,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          final blurAmount = (1.0 - animation.value) * 5.0;
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
                                scale: animation,
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
                      color: _isEditing ? Colors.black : Colors.black54,
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

class _SegmentWrapper extends StatelessWidget {
  const _SegmentWrapper({
    required this.child,
    required this.isEditing,
    required this.splitProgress,
    required this.borderRadius,
    required this.bgColor,
    required this.position,
    required this.onTap,
  });

  final Widget child;
  final bool isEditing;
  final double splitProgress;
  final double borderRadius;
  final Color bgColor;
  final _SegmentPosition position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAction = position == _SegmentPosition.right;
    final clampedProgress = splitProgress.clamp(0.0, 1.0);
    
    final lerpRadius = BorderRadius.circular(borderRadius);
    BorderRadius mergedRadius;
    switch (position) {
      case _SegmentPosition.left:
        mergedRadius = BorderRadius.horizontal(left: Radius.circular(borderRadius));
      case _SegmentPosition.middle:
        mergedRadius = BorderRadius.zero;
      case _SegmentPosition.right:
        mergedRadius = BorderRadius.horizontal(right: Radius.circular(borderRadius));
    }

    final currentRadius = BorderRadius.lerp(mergedRadius, lerpRadius, clampedProgress)!;

    // Tighter closed state, generous padded expanded state
    final hPadding = isAction ? 0.0 : (4.0 + (22.0 * clampedProgress));
    final minWidth = isAction ? 64.0 : (55.0 + (65.0 * clampedProgress));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        width: isAction ? 64 : null,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        decoration: BoxDecoration(
          color: bgColor,
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
          child: Center(child: child),
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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String unit;
  final bool isEditing;
  final SplitToEditStyle style;

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

    final dynamicWidth = 32.0; 

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: dynamicWidth,
          child: TextField(
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
          ),
        ),
        const SizedBox(width: 4),
        Text(unit, style: unitStyle),
      ],
    );
  }
}
