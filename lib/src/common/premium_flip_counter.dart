import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'portal_utils.dart';

/// A high-performance, odometer-style counter with motion blur.
/// 
/// It's designed to handle fast value changes by showing every intermediate
/// state with a dynamic blur effect, creating a "1 to 1" tactile feel.
class PremiumFlipCounter extends StatelessWidget {
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

  const PremiumFlipCounter({
    super.key,
    required this.value,
    required this.upward,
    required this.style,
    this.digitWidth,
    this.padWithZero = true,
  });

  @override
  Widget build(BuildContext context) {
    // Measure the widest possible digit ('8') to determine column width
    final Size textSize = PortalUtils.measureText('8', style);
    final double width = digitWidth ?? textSize.width;
    final double height = textSize.height;

    // String formatting logic
    final String strValue = padWithZero
        ? PortalUtils.padZero(value)
        : value.toString();
    final List<String> digits = strValue.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: digits.asMap().entries.map((entry) {
        final int index = entry.key;
        final String digitStr = entry.value;
        final int digit = int.tryParse(digitStr) ?? 0;
        
        // Calculate stable key by position from the right (Units = 1, Tens = 2, etc.)
        final int posFromRight = strValue.length - index;

        return _ReelDigit(
          key: ValueKey('reel_digit_$posFromRight'),
          digit: digit,
          style: style,
          width: width,
          height: height,
        );
      }).toList(),
    );
  }
}

/// A stateful widget that manages the vertical "reel" of a single digit.
class _ReelDigit extends StatefulWidget {
  final int digit;
  final TextStyle style;
  final double width;
  final double height;

  const _ReelDigit({
    super.key,
    required this.digit,
    required this.style,
    required this.width,
    required this.height,
  });

  @override
  State<_ReelDigit> createState() => _ReelDigitState();
}

class _ReelDigitState extends State<_ReelDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Internal continuous value (e.g., 25.0 means digit 5 in the 3rd cycle)
  double _currentValue = 0;
  double _lastFiredValue = 0;
  double _blurSigma = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.digit.toDouble();
    _lastFiredValue = _currentValue;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _controller.addListener(() {
      setState(() {
        // Calculate directional velocity for motion blur
        final double delta = (_controller.value - _lastFiredValue).abs();
        _blurSigma = (delta * 25).clamp(0, 12);
        _lastFiredValue = _controller.value;
      });
    });

    // Initialize as a static value
    _animation = AlwaysStoppedAnimation(_currentValue);
  }

  @override
  void didUpdateWidget(_ReelDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _startRotation(widget.digit);
    }
  }

  void _startRotation(int targetDigit) {
    final double start = _currentValue;
    double end = targetDigit.toDouble();

    // ODOMETER LOGIC: Find target value in the continuous space
    final double diff = (end - (start % 10)).remainder(10);
    final double shortestDiff = (diff > 5) ? diff - 10 : (diff < -5) ? diff + 10 : diff;
    
    end = start + shortestDiff;
    
    setState(() {
      _animation = Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _currentValue = end;
      _lastFiredValue = 0; // Reset for velocity calculation
    });

    _controller.forward(from: 0).then((_) {
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

    return SizedBox(
      width: widget.width,
      height: totalHeight,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0.0, 0.3, 0.7, 1.0], // Sharper center for better clarity
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: _blurSigma),
            child: Center(
              child: SizedBox(
                height: widget.height,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final double value = _animation.value;
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
    );
  }
}

/// A simple helper to draw a digit at a specific vertical offset.
class _DigitView extends StatelessWidget {
  final int digit;
  final TextStyle style;
  final double offset;
  final double height;

  const _DigitView({
    required this.digit,
    required this.style,
    required this.offset,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the tilt factor based on offset
    final double normalizedOffset = (offset / height).clamp(-1.0, 1.0);
    final double rotation = normalizedOffset * 0.8; // 3D tilt

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015) // Perspective
        ..translate(0.0, offset, 0.0)
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
              color: style.color?.withOpacity((1.0 - normalizedOffset.abs()).clamp(0.2, 1.0)),
            ),
          ),
        ),
      ),
    );
  }
}
