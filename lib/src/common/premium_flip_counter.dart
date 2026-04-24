import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'portal_utils.dart';

/// A high-performance, odometer-style counter with motion blur.
///
/// It's designed to handle fast value changes by showing every intermediate
/// state with a dynamic blur effect, creating a "1 to 1" tactile feel.
class PremiumFlipCounter extends StatelessWidget {

  /// Creates a [PremiumFlipCounter] with a [value], direction, and [style].
  const PremiumFlipCounter({
    super.key,
    required this.value,
    required this.upward,
    required this.style,
    this.digitWidth,
    this.padWithZero = true,
    this.maxDigits,
  });
  /// The integer value to be displayed.
  final int value;

  /// Determines the visual "gravity" of the flip.
  /// (Maintained for backward compatibility, now follows odometer logic).
  final bool upward;

  /// The font styling for the digits.
  final TextStyle style;

  /// Optional fixed width for each digit.
  final double? digitWidth;

  /// Whether to pad single digits with a leading zero.
  final bool padWithZero;

  /// Optional fixed number of digits to display.
  /// If provided, the counter will always occupy this many slots.
  final int? maxDigits;

  @override
  Widget build(BuildContext context) {
    // Measure the widest possible digit ('8') to determine column width
    final Size textSize = PortalUtils.measureText('8', style);
    final double width = digitWidth ?? textSize.width;
    final double height = textSize.height;

    // String formatting logic
    String strValue = padWithZero
        ? PortalUtils.padZero(value)
        : value.toString();
    
    if (maxDigits != null && strValue.length < maxDigits!) {
      strValue = strValue.padLeft(maxDigits!, ' ');
    }
    
    final List<String> digits = strValue.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.asMap().entries.map((entry) {
        final int index = entry.key;
        final String digitStr = entry.value;
        final int? digit = int.tryParse(digitStr);

        // Calculate stable position from the right
        final int posFromRight = strValue.length - index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuint,
          width: digit == null ? 0.0 : width,
          color: Colors.transparent, // Required for clipBehavior
          clipBehavior: Clip.hardEdge,
          child: _ReelDigit(
            key: ValueKey('reel_digit_$posFromRight'),
            digit: digit,
            style: style,
            width: width,
            height: height,
          ),
        );
      }).toList(),
    );
  }
}

/// A stateful widget that manages the vertical "reel" of a single digit.
class _ReelDigit extends StatefulWidget {

  const _ReelDigit({
    super.key,
    required this.digit,
    required this.style,
    required this.width,
    required this.height,
  });
  final int? digit;
  final TextStyle style;
  final double width;
  final double height;

  @override
  State<_ReelDigit> createState() => _ReelDigitState();
}

class _ReelDigitState extends State<_ReelDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Internal continuous value (e.g., 25.0 means digit 5 in the 3rd cycle)
  double _currentValue = 0;
  double _lastFiredValue = 0;
  double _blurSigma = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.digit?.toDouble() ?? 0.0;
    _lastFiredValue = _currentValue;
    
    // Set bounds to infinity to allow the odometer to spin continuously
    _controller = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          final double delta = (_controller.value - _lastFiredValue).abs();
          _blurSigma = (delta * 15).clamp(0, 8);
          _lastFiredValue = _controller.value;
        });
      }
    });

    _controller.value = _currentValue;

    // Initialize as a static value
    _animation = AlwaysStoppedAnimation(_currentValue);
  }

  @override
  void didUpdateWidget(_ReelDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      if (oldWidget.digit == null && widget.digit != null) {
        // If the digit is appearing for the first time, don't spin it from zero.
        // It should just fade/slide in as its final value.
        _currentValue = widget.digit!.toDouble();
        _lastFiredValue = _currentValue; // Update immediately to prevent ghost blur
        _controller.value = _currentValue;
        setState(() {
          _blurSigma = 0;
        });
      } else {
        _startRotation(widget.digit);
      }
    }
  }

  void _startRotation(int? targetDigit) {
    if (targetDigit == null) return;

    // Capture the CURRENT position even if mid-animation
    final double start = _controller.value;
    double end = targetDigit.toDouble();

    // ODOMETER LOGIC: Find target value based on the closest lane in the desired direction
    final double diff = (end - (start % 10)).remainder(10);
    final double shortestDiff = (diff > 5)
        ? diff - 10
        : (diff < -5)
        ? diff + 10
        : diff;

    end = start + shortestDiff;

    // Update _currentValue immediately so next tap starts from here
    _currentValue = end;

    final SpringSimulation simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 300, 
        damping: 25, 
      ),
      start,
      end,
      _controller.velocity, // Inherit velocity for a fluid transition
    );

    _controller.animateWith(simulation).then((_) {
      if (mounted) {
        setState(() {
          _blurSigma = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We increase the total height (1.6x) to create a "window" where the
    // active digit stays sharp while others fade.
    final double totalHeight = widget.height * 1.6;

    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: widget.digit == null ? 0.8 : 1.0,
      curve: Curves.easeOutQuint,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: widget.digit == null ? 0.0 : 1.0,
        curve: Curves.easeOutQuint,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 400),
          alignment: widget.digit == null ? Alignment.centerRight : Alignment.center,
          curve: Curves.easeOutQuint,
          child: SizedBox(
            width: widget.width,
            height: totalHeight,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Center(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaY: _blurSigma),
                  child: SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final double value = _controller.value;
                        final int mainDigit = value.floor() % 10;
                        final double fraction = value - value.floor();

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _DigitView(
                              digit: mainDigit,
                              style: widget.style,
                              offset: -fraction * widget.height,
                              height: widget.height,
                            ),
                            if (fraction > 0.01) // Only show the next digit if we are actually flipping
                              _DigitView(
                                digit: (mainDigit + 1) % 10,
                                style: widget.style,
                                offset: (1.0 - fraction) * widget.height,
                                height: widget.height,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple helper to draw a digit at a specific vertical offset.
class _DigitView extends StatelessWidget {

  const _DigitView({
    required this.digit,
    required this.style,
    required this.offset,
    required this.height,
  });
  final int digit;
  final TextStyle style;
  final double offset;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Determine the tilt factor based on offset
    final double normalizedOffset = (offset / height).clamp(-1.0, 1.0);
    final double rotation = normalizedOffset * 0.8; // 3D tilt

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015) // Perspective
        ..translateByDouble(0.0, offset, 0.0, 1.0)
        ..rotateX(rotation),
      alignment: Alignment.center,
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(
            digit.toString(),
            style: style.copyWith(
              // Force height to 1.0 to eliminate internal font padding
              height: 1.0,
              // Fade out numbers as they "recede" into the 3D depth
              color: style.color?.withValues(alpha: 
                (1.0 - normalizedOffset.abs()).clamp(0.2, 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
