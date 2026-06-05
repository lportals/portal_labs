import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import '../common/premium_flip_counter.dart';
import 'models/score_gauge_style.dart';

/// An interactive, animated semicircular score gauge widget.
///
/// Displays a numerical score using an odometer rolling digit counter,
/// and a qualitative label that transitions into place once the calculation settles.
class ScoreGauge extends StatefulWidget {
  /// Creates a [ScoreGauge] component.
  const ScoreGauge({
    super.key,
    required this.value,
    this.min = 300.0,
    this.max = 850.0,
    required this.label,
    this.calculatingLabel = 'CALCULATING...',
    this.valueFormatter,
    this.style = const ScoreGaugeStyle(),
  })  : assert(min < max, 'min must be less than max'),
        assert(value >= min && value <= max, 'value must be between min and max');

  /// The current score value.
  final double value;

  /// The minimum possible score value (defaults to 300).
  final double min;

  /// The maximum possible score value (defaults to 850).
  final double max;

  /// The qualitative label shown below the value (e.g. "VERY GOOD", "POOR").
  final String label;

  /// The label displayed while the score is animating/calculating (defaults to "CALCULATING...").
  final String calculatingLabel;

  /// Custom formatter for the displayed value. Defaults to rounding to integer.
  final String Function(double value)? valueFormatter;

  /// Style configuration for this widget.
  final ScoreGaugeStyle style;

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;
  bool _isMovingUp = true;
  double _animationStartFraction = 0.0;
  double _animationEndFraction = 0.0;
  bool _isCalculationFinished = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );

    final double targetFraction = _getValueFraction(widget.value);
    _animationStartFraction = targetFraction;
    _animationEndFraction = targetFraction;
    _isCalculationFinished = true;

    _animation = Tween<double>(
      begin: targetFraction,
      end: targetFraction,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const PortalSpringCurve(stiffness: 120, damping: 18),
    ));

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _arrowAnimation = CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeOutCubic,
    );

    // Starts fully visible since it's already settled at target on load
    _arrowController.value = 1.0;

    _controller.addListener(() {
      if (!_isCalculationFinished && _controller.value >= 0.85) {
        setState(() {
          _isCalculationFinished = true;
        });
        _arrowController.forward();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isCalculationFinished) {
          setState(() {
            _isCalculationFinished = true;
          });
          _arrowController.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max ||
        oldWidget.style.animationDuration != widget.style.animationDuration) {
      final double targetFraction = _getValueFraction(widget.value);
      _isMovingUp = targetFraction >= _animation.value;

      if (widget.style.enableHaptics && oldWidget.value != widget.value) {
        HapticFeedback.lightImpact();
      }

      // Hide the arrow immediately on value change/recalculation
      _arrowController.value = 0.0;

      setState(() {
        _isCalculationFinished = false;
      });

      _animationStartFraction = _animation.value;
      _animationEndFraction = targetFraction;

      _controller.duration = widget.style.animationDuration;
      _animation = Tween<double>(
        begin: _animation.value,
        end: targetFraction,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const PortalSpringCurve(stiffness: 120, damping: 18),
      ));

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  double _getValueFraction(double val) {
    final double range = widget.max - widget.min;
    if (range == 0) return 0.0;
    return ((val - widget.min) / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final String Function(double) formatter =
        widget.valueFormatter ?? (val) => val.round().toString();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation, _arrowAnimation]),
        builder: (context, child) {
          final double animatedValue =
              widget.min + _animation.value * (widget.max - widget.min);

          final double denominator = _animationEndFraction - _animationStartFraction;
          final double progress = denominator == 0.0
              ? 1.0
              : ((_animation.value - _animationStartFraction) / denominator).clamp(-0.2, 1.2);

          final String currentLabel = _isCalculationFinished ? widget.label : widget.calculatingLabel;

          return ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 220.0,
              minHeight: 200.0,
            ),
            child: CustomPaint(
              painter: _ScoreGaugePainter(
                valueFraction: _animation.value,
                animationProgress: progress,
                arrowAnimationValue: _arrowAnimation.value,
                style: widget.style,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth.isFinite ? constraints.maxWidth : 220.0;
                  final double height = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
                  final double outerRadius = math.min(width, height) / 2;

                  // Compute dynamic scale factor relative to reference outerRadius (120.0)
                  final double scaleFactor = outerRadius / 120.0;

                  // Scale layout geometry proportions
                  final double trackThickness = widget.style.trackThickness * scaleFactor;
                  final double tickLength = widget.style.tickLength * scaleFactor;
                  final double tickGap = widget.style.tickGap * scaleFactor;

                  // Compute the exact radius of the arc track
                  final double radius = outerRadius - math.max(
                    tickLength + tickGap,
                    trackThickness / 2,
                  );

                  // Compute the inner radius of the track where text can safely render
                  final double innerRadius = radius - trackThickness / 2;
                  final double innerWidth = 2 * innerRadius;

                  // Dynamically scale text sizes and gaps
                  final TextStyle dynamicValueStyle = widget.style.valueTextStyle.copyWith(
                    fontSize: (widget.style.valueTextStyle.fontSize ?? 64.0) * scaleFactor,
                  );
                  final TextStyle dynamicLabelStyle = widget.style.labelTextStyle.copyWith(
                    fontSize: (widget.style.labelTextStyle.fontSize ?? 14.0) * scaleFactor,
                  );
                  final double dynamicLabelGap = widget.style.labelGap * scaleFactor;

                  return Center(
                    child: Transform.translate(
                      offset: Offset(0.0, outerRadius * 0.18),
                      child: SizedBox(
                        width: innerWidth,
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Odometer Flip Counter for score digits
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: PremiumFlipCounter(
                              value: formatter(animatedValue),
                              upward: _isMovingUp,
                              style: dynamicValueStyle,
                              padWithZero: false,
                            ),
                          ),
                          SizedBox(height: dynamicLabelGap),
                          // Animated label drops from sky/persiana style
                          SizedBox(
                            width: innerWidth * 0.68, // Constrain to leave generous clearance from the gauge walls
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    // ignore: use_null_aware_elements
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                final inAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, -1.2), // Drops from the sky
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ));

                                final outAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 1.2), // Slides down
                                  end: Offset.zero,
                                 ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeIn,
                                ));

                                final bool isCurrentLabel = child.key == ValueKey(currentLabel);
                                return ClipRect(
                                  child: SlideTransition(
                                    position: isCurrentLabel ? inAnimation : outAnimation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: FittedBox(
                                key: ValueKey(currentLabel),
                                fit: BoxFit.scaleDown,
                                child: _isCalculationFinished
                                    ? Text(
                                        currentLabel,
                                        style: dynamicLabelStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      )
                                    : _PulsingLabel(
                                        text: currentLabel,
                                        style: dynamicLabelStyle,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  _ScoreGaugePainter({
    required this.valueFraction,
    required this.animationProgress,
    required this.arrowAnimationValue,
    required this.style,
  });

  final double valueFraction;
  final double animationProgress;
  final double arrowAnimationValue;
  final ScoreGaugeStyle style;

  /// Interpolates a color dynamically along the trackGradientColors spectrum.
  Color _getSpectrumColor(double fraction) {
    final double f = fraction.clamp(0.0, 1.0);
    final List<Color> colors = style.trackGradientColors;
    if (colors.isEmpty) {
      return const Color(0xFF5AC8FA); // Fallback to blue
    }
    if (colors.length == 1) {
      return colors.first;
    }

    final int segments = colors.length - 1;
    final int index = (f * segments).floor().clamp(0, segments - 1);
    final double startFraction = index / segments;
    final double endFraction = (index + 1) / segments;
    final double localFraction = (f - startFraction) / (endFraction - startFraction);

    return Color.lerp(colors[index], colors[index + 1], localFraction.clamp(0.0, 1.0))!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double outerRadius = math.min(size.width, size.height) / 2;
    // Shift the circle center down by 18% of outerRadius to balance the semicircle visual weight
    final double centerY = size.height / 2 + (outerRadius * 0.18);

    // Compute dynamic scale factor relative to reference outerRadius (120.0)
    final double scaleFactor = outerRadius / 120.0;

    // Scale drawing geometry proportions
    final double trackThickness = style.trackThickness * scaleFactor;
    final double tickThickness = style.tickThickness * scaleFactor;
    final double tickLength = style.tickLength * scaleFactor;
    final double tickGap = style.tickGap * scaleFactor;
    final double indicatorSize = style.indicatorSize * scaleFactor;
    final double indicatorGap = style.indicatorGap * scaleFactor;

    // Compute exact radius of the arc track
    final double radius = outerRadius - math.max(tickLength + tickGap, trackThickness / 2);

    final double startAngleRad = _degToRad(style.startAngleDegrees);
    final double sweepAngleRad = _degToRad(style.sweepAngleDegrees);

    final Offset center = Offset(centerX, centerY);
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    // Resolve color of the active arc end (dynamic traffic light solid shift)
    final Color activeColor = _getSpectrumColor(valueFraction);

    // 1. Draw a soft, beautiful central glow matching the active category color
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          activeColor.withValues(alpha: 0.08),
          activeColor.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - trackThickness / 2, glowPaint);

    // 2. Draw the entire track filled with the dynamically shifting color (color no se mueve de longitud, solo cambia)
    final Paint trackPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackThickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      startAngleRad,
      sweepAngleRad,
      false,
      trackPaint,
    );

    // 3. Draw tick marks as alternating segment separators that rotate and grow
    if (style.showTicks && style.tickCount > 1) {
      final Paint tickPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = tickThickness;

      // Animate rotation offset of the ticks based on calculation progress to spin them while calculating
      final double ticksRotationOffset = (1.0 - animationProgress) * -3.0 * math.pi;

      final double stepAngleRad = sweepAngleRad / (style.tickCount - 1);
      final double patternPeriodRad = 2 * stepAngleRad;
      final double currentOffset = ticksRotationOffset % patternPeriodRad;
      final int centerIndex = (style.tickCount - 1) ~/ 2;

      // Loop over a wider range to ensure ticks cover the full sweep angle during rotation
      for (int i = -2; i < style.tickCount + 2; i++) {
        final double angle = startAngleRad + (i * stepAngleRad) + currentOffset;

        // CUT: Clip/skip ticks that fall below the start/end angles of the gauge arc (bottom open area)
        final double diff = (angle - startAngleRad) % (2 * math.pi);
        if (diff > sweepAngleRad) {
          continue;
        }

        // Alternating pattern: even ticks are large (longTickLengthScale), odd ticks are small (shortTickLengthScale)
        // Ensured the center tick is always a long tick
        final bool isLongTick = (i - centerIndex) % 2 == 0;
        final double tickLengthScale = isLongTick
            ? style.longTickLengthScale
            : style.shortTickLengthScale;

        final double cosAngle = math.cos(angle);
        final double sinAngle = math.sin(angle);

        // Position of the ticks centered within the track thickness
        final double centerRadius = radius;
        final double currentTickLength = trackThickness * tickLengthScale;
        final double scaledStart = centerRadius - currentTickLength / 2;
        final double scaledEnd = centerRadius + currentTickLength / 2;

        final Offset pStart = Offset(
          centerX + scaledStart * cosAngle,
          centerY + scaledStart * sinAngle,
        );
        final Offset pEnd = Offset(
          centerX + scaledEnd * cosAngle,
          centerY + scaledEnd * sinAngle,
        );

        canvas.drawLine(pStart, pEnd, tickPaint);
      }
    }

    // 4. Draw static centered arrow indicator pointing straight UP (at 270 degrees / 12 o'clock)
    // Animates with a fade + slide up transition once the calculation settles
    if (arrowAnimationValue > 0.0) {
      final double indicatorRadius = radius - (trackThickness / 2) - indicatorGap;

      // Adjust height and base width to make the arrow thicker, larger, and less pointy
      final double arrowHeight = indicatorSize * 1.15;
      final double halfBase = indicatorSize * 0.85;
      final double baseRadius = indicatorRadius - arrowHeight;

      // Slide offset (moves up as animation goes to 1.0)
      final double slideOffset = (1.0 - arrowAnimationValue) * 14.0 * scaleFactor;

      final double tipY = centerY - indicatorRadius + slideOffset;
      final double baseLeftY = centerY - baseRadius + slideOffset;
      final double baseRightY = centerY - baseRadius + slideOffset;

      final Offset A = Offset(centerX, tipY);
      final Offset B = Offset(centerX - halfBase, baseLeftY);
      final Offset C = Offset(centerX + halfBase, baseRightY);

      // Height of the triangle
      final double height = arrowHeight;
      final double L = math.sqrt(halfBase * halfBase + height * height);

      // Corner offset distance for rounding
      final double d = indicatorSize * 0.22;

      // Unit vectors
      final Offset vCA = Offset(-halfBase / L, -height / L);
      final Offset vAC = Offset(halfBase / L, height / L);
      final Offset vAB = Offset(-halfBase / L, height / L);
      final Offset vBA = Offset(halfBase / L, -height / L);

      // Points around B
      final Offset bNext = Offset(B.dx + d, B.dy);
      final Offset bPrev = B + vBA * d;

      // Points around C
      final Offset cPrev = Offset(C.dx - d, C.dy);
      final Offset cNext = C + vCA * d;

      // Points around A
      final Offset aPrev = A + vAC * d;
      final Offset aNext = A + vAB * d;

      final Path roundedTrianglePath = Path()
        ..moveTo(bNext.dx, bNext.dy)
        ..lineTo(cPrev.dx, cPrev.dy)
        ..quadraticBezierTo(C.dx, C.dy, cNext.dx, cNext.dy)
        ..lineTo(aPrev.dx, aPrev.dy)
        ..quadraticBezierTo(A.dx, A.dy, aNext.dx, aNext.dy)
        ..lineTo(bPrev.dx, bPrev.dy)
        ..quadraticBezierTo(B.dx, B.dy, bNext.dx, bNext.dy)
        ..close();

      final Paint indicatorPaint = Paint()
        ..color = activeColor.withValues(alpha: arrowAnimationValue)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawPath(roundedTrianglePath, indicatorPaint);
    }
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.valueFraction != valueFraction ||
        oldDelegate.arrowAnimationValue != arrowAnimationValue ||
        oldDelegate.style != style;
  }
}

/// A helper widget that pulses its opacity to indicate active calculation.
class _PulsingLabel extends StatefulWidget {
  /// Creates a [_PulsingLabel] widget.
  const _PulsingLabel({
    super.key,
    required this.text,
    required this.style,
  });

  /// The text to display.
  final String text;

  /// The text style to apply.
  final TextStyle style;

  @override
  State<_PulsingLabel> createState() => _PulsingLabelState();
}

class _PulsingLabelState extends State<_PulsingLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + (_controller.value * 0.6),
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
