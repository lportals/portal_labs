import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'portal_utils.dart';

/// A high-performance, odometer-style counter with motion blur.
/// Supports strings for currency formatting and handles mechanical flipping directions.
class PremiumFlipCounter extends StatelessWidget {
  /// Creates a [PremiumFlipCounter].
  const PremiumFlipCounter({
    super.key,
    required this.value,
    required this.upward,
    required this.style,
    this.digitWidth,
    this.padWithZero = true,
    this.maxDigits,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  /// The value to be displayed (supports int, double, or String).
  final dynamic value;

  /// Determines the visual direction of the flip.
  /// If true, digits will flip "upwards" (incrementing feel).
  final bool upward;

  /// The font styling for the digits.
  final TextStyle style;

  /// Optional fixed width for each digit.
  final double? digitWidth;

  /// Whether to pad single digits with a leading zero.
  final bool padWithZero;

  /// Optional fixed number of digits to display.
  final int? maxDigits;

  /// The alignment of the counter segments.
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final Size textSize = PortalUtils.measureText('8', style);
    final double width = digitWidth ?? (textSize.width + (style.letterSpacing ?? 0));
    final double height = textSize.height;

    String strValue;
    if (padWithZero && value is int) {
      strValue = PortalUtils.padZero(value as int);
    } else {
      strValue = value.toString();
    }

    if (maxDigits != null && strValue.length < maxDigits!) {
      strValue = strValue.padLeft(maxDigits!);
    }
    
    final List<String> segments = strValue.split('');
    final int dotIndex = strValue.indexOf('.');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: segments.asMap().entries.map((entry) {
        final int index = entry.key;
        final String char = entry.value;
        final int? digit = int.tryParse(char);

        if (digit == null) {
          return Text(char, style: style);
        }

        // Align keys relative to the decimal point for stable animations.
        // Digits to the left of the dot get positive power (1 for units, 2 for tens...).
        // Digits to the right get negative power (-1 for tenths, -2 for hundredths...).
        // If no dot exists, we align from the right as a fallback.
        final int powerOfTen;
        if (dotIndex != -1) {
          powerOfTen = dotIndex - index;
        } else {
          powerOfTen = strValue.length - index;
        }

        return AnimatedContainer(
          key: ValueKey('reel_digit_container_$powerOfTen'),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          width: width,
          height: height,
          color: Colors.transparent, 
          clipBehavior: Clip.hardEdge,
          child: _ReelDigit(
            digit: digit,
            upward: upward,
            style: style,
            width: width,
            height: height,
          ),
        );
      }).toList(),
    );
  }
}

class _ReelDigit extends StatefulWidget {
  const _ReelDigit({
    super.key,
    required this.digit,
    required this.upward,
    required this.style,
    required this.width,
    required this.height,
  });
  final int digit;
  final bool upward;
  final TextStyle style;
  final double width;
  final double height;

  @override
  State<_ReelDigit> createState() => _ReelDigitState();
}

class _ReelDigitState extends State<_ReelDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _lastFiredValue = 0;
  double _blurSigma = 0;

  @override
  void initState() {
    super.initState();
    _lastFiredValue = widget.digit.toDouble();
    
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

    _controller.value = widget.digit.toDouble();
  }

  @override
  void didUpdateWidget(_ReelDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _startRotation(widget.digit);
    }
  }

  void _startRotation(int targetDigit) {
    final double start = _controller.value;
    double end = targetDigit.toDouble();

    // MECHANICAL ODOMETER LOGIC:
    // We want the digit to flip in the direction specified by 'upward'.
    // If upward is true, we always move to the next higher occurrence of targetDigit.
    // If upward is false, we always move to the next lower occurrence.
    
    final double currentMod = start % 10;
    double diff;
    
    if (widget.upward) {
      diff = (targetDigit - currentMod) % 10;
      if (diff < 0) diff += 10;
    } else {
      diff = (targetDigit - currentMod) % 10;
      if (diff > 0) diff -= 10;
    }

    end = start + diff;

    final SpringSimulation simulation = SpringSimulation(
      const SpringDescription(
        mass: 1.2, // Slightly heavier feel
        stiffness: 200, // More relaxed
        damping: 25, 
      ),
      start,
      end,
      _controller.velocity,
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
    final double totalHeight = widget.height * 2.0;

    return SizedBox(
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
            stops: [0.0, 0.15, 0.85, 1.0],
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
                      if (fraction > 0.01)
                        _DigitView(
                          digit: (mainDigit + 1) % 10,
                          style: widget.style,
                          offset: (1.0 - fraction) * widget.height,
                          height: widget.height,
                        ),
                      if (fraction < -0.01)
                        _DigitView(
                          digit: (mainDigit - 1 + 10) % 10,
                          style: widget.style,
                          offset: (-1.0 - fraction) * widget.height,
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
    );
  }
}

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
    final double normalizedOffset = (offset / height).clamp(-1.0, 1.0);
    final double rotation = normalizedOffset * 0.8;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..translateByDouble(0.0, offset, 0.0, 1.0)
        ..rotateX(rotation),
      alignment: Alignment.center,
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(
            digit.toString(),
            style: style.copyWith(
              height: 1.0,
              color: style.color?.withValues(alpha: 
                (1.0 - normalizedOffset.abs().clamp(0.0, 1.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
