import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/premium_flip_counter.dart';
import 'models/knob_slider_style.dart';

/// A premium, interactive circular knob slider.
///
/// Features:
/// - **Gesture Interaction:** Rotating the knob updates the value with a natural feel.
/// - **Aesthetic Design:** Sleek outer ring with dynamic ticks and a 3D flip counter.
/// - **Plug and Play:** Highly configurable with style and range settings.
/// - **Tactile Feedback:** Built-in haptic vibrations when values change.
class KnobSlider extends StatefulWidget {
  /// The current value of the slider.
  final double value;

  /// The minimum possible value.
  final double min;

  /// The maximum possible value.
  final double max;

  /// The step size for the value change.
  final double step;

  /// Called when the value changes during interaction.
  final ValueChanged<double> onChanged;

  /// Style configuration for the component.
  final KnobSliderStyle style;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  /// The size of the widget. If null, it will try to expand to fit
  /// constraints, or fallback to a default size.
  final double? size;

  const KnobSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    required this.onChanged,
    this.style = const KnobSliderStyle(),
    this.enableHaptics = true,
    this.size,
  });

  @override
  State<KnobSlider> createState() => _KnobSliderState();
}

class _KnobSliderState extends State<KnobSlider> {
  late double _currentValue;
  bool _isIncreasing = true;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
  }

  @override
  void didUpdateWidget(KnobSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isIncreasing = widget.value >= _currentValue;
      _currentValue = widget.value.clamp(widget.min, widget.max);
    }
  }

  double? _lastAngle;

  void _handleStart(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final vector = localPosition - center;
    _lastAngle = math.atan2(vector.dy, vector.dx);
  }

  void _handleUpdate(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final vector = localPosition - center;
    final double currentAngle = math.atan2(vector.dy, vector.dx);

    if (_lastAngle != null) {
      double deltaAngle = currentAngle - _lastAngle!;

      // Handle the wrap-around jump at the PI / -PI boundary
      if (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
      if (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

      // Map the angular rotation delta to the value range
      // A full circle (2PI) represents the entire value range
      final double deltaValue =
          (deltaAngle / (2 * math.pi)) * (widget.max - widget.min);
      final double newValue = (_currentValue + deltaValue).clamp(
        widget.min,
        widget.max,
      );

      if (newValue != _currentValue) {
        // Snapped value for the numeric readout and onChanged
        final double snappedValue =
            (newValue / widget.step).roundToDouble() * widget.step;

        if (snappedValue.round() != _currentValue.round() &&
            widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }

        setState(() {
          _isIncreasing = newValue > _currentValue;
          _currentValue = newValue;
        });

        // Only fire onChanged if we actually cross a step boundary
        final double lastSnapped =
            (_currentValue / widget.step).roundToDouble() * widget.step;
        if (snappedValue != lastSnapped ||
            newValue == widget.min ||
            newValue == widget.max) {
          widget.onChanged(snappedValue);
        }
      }
    }

    _lastAngle = currentAngle;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sizing logic:
        // 1. Use widget.size if provided.
        // 2. Otherwise, use the minimum of available width/height.
        // Fallback to 220.0 (smaller default size)
        double size =
            widget.size ??
            math.min(
              constraints.maxWidth.isFinite ? constraints.maxWidth : 220.0,
              constraints.maxHeight.isFinite ? constraints.maxHeight : 220.0,
            );

        return GestureDetector(
          onPanStart: (details) =>
              _handleStart(details.localPosition, Size(size, size)),
          onPanUpdate: (details) =>
              _handleUpdate(details.localPosition, Size(size, size)),
          onPanEnd: (_) => _lastAngle = null,
          child: Container(
            width: size,
            height: size,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. External Glow/Shadow Effect (from image)
                Container(
                  width: size * 0.95,
                  height: size * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.style.shadowColor.withValues(alpha: 0.05),
                        blurRadius: size * 0.1,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // 2. Outer Ring & Ticks (Custom Painted)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _KnobRingPainter(
                      value: _currentValue,
                      min: widget.min,
                      max: widget.max,
                      style: widget.style,
                    ),
                  ),
                ),

                // 3. Central Knob
                Container(
                  width: size * widget.style.knobScale,
                  height: size * widget.style.knobScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.style.borderColor,
                      width: 1,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFF9F9F9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.style.shadowColor.withValues(alpha: 0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: PremiumFlipCounter(
                      value: _currentValue.round(),
                      upward: _isIncreasing,
                      style: widget.style.valueTextStyle,
                      padWithZero: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KnobRingPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final KnobSliderStyle style;

  _KnobRingPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const startAngle = -math.pi / 2;
    const sweepAngle = 2 * math.pi;
    final percentage = (value - min) / (max - min);

    // 0. Base Outer Ring (Smooth white circle with shadow)
    final baseWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final baseShadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(
      baseShadowPath,
      Colors.black.withValues(alpha: 0.05),
      10,
      true,
    );
    canvas.drawCircle(center, radius, baseWhitePaint);

    // Border: 1px Black (from style)
    final borderPaint = Paint()
      ..color = style.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, borderPaint);

    // 1. Middle Track Ring (Where the ticks sit)
    final middleRingRadius = radius * 0.95;
    final middleRingPaint = Paint()
      ..color = style.trackColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, middleRingRadius, middleRingPaint);

    // 2. Draw Ticks (Centered between the knob and outer ring)
    final knobRadius = radius * style.knobScale;
    final tickAreaCenter = (radius + knobRadius) / 2;

    for (int i = 0; i < style.totalTicks; i++) {
      // FIX: Use i / style.totalTicks for closed-loop spacing (prevents advance error)
      final tickPercent = i / style.totalTicks;
      final tickAngle = startAngle + (tickPercent * sweepAngle);

      final isTickActive = tickPercent <= percentage;
      final tickColor = isTickActive
          ? style.activeTickColor
          : style.inactiveTickColor.withValues(alpha: 0.3);

      final tickPaint = Paint()
        ..color = tickColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.tickWidth
        ..strokeCap = StrokeCap.round;

      final currentTickLength = style.tickLength;

      // Position ticks symmetrically around the tickAreaCenter
      final outerR = tickAreaCenter + (currentTickLength / 2);
      final innerR = tickAreaCenter - (currentTickLength / 2);

      final p1 = Offset(
        center.dx + innerR * math.cos(tickAngle),
        center.dy + innerR * math.sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(tickAngle),
        center.dy + outerR * math.sin(tickAngle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Draw Indicator Handle (More precise, shorter and rounded)
    final handleAngle = startAngle + (percentage * sweepAngle);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(handleAngle);

    final handlePaint = Paint()
      ..color = style.handleColor
      ..style = PaintingStyle.fill;

    // Even Fatter Rounded Pointer (Cone style)
    const tipLength = 12.0;
    final pointerPath = Path()
      ..moveTo(knobRadius - 2, -12) // Even wider base
      ..lineTo(knobRadius + tipLength - 4, -6)
      ..quadraticBezierTo(
        knobRadius + tipLength,
        0,
        knobRadius + tipLength - 4,
        6,
      )
      ..lineTo(knobRadius - 2, 12)
      ..close();

    // Subtle centered shadow to avoid angular shift perception
    canvas.drawShadow(
      pointerPath,
      Colors.black.withValues(alpha: 0.3),
      3,
      true,
    );
    canvas.drawPath(pointerPath, handlePaint);

    // Subtle white dot on the pointer handle
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(knobRadius + tipLength / 2, 0), 1.5, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KnobRingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.style != style;
  }
}
