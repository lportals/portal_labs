import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/slider_control_style.dart';

export 'models/slider_control_style.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Internal state machine
// ─────────────────────────────────────────────────────────────────────────────

sealed class _SliderState {}

/// The slider is at rest — no active gesture.
class _Idle extends _SliderState {}

/// The user is actively dragging the slider.
class _Dragging extends _SliderState {
  _Dragging(this.fraction);

  /// Normalised drag position [0.0 = bottom, 1.0 = top].
  final double fraction;
}

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// A premium vertical slider with a pill-shaped track, a gradient fill, and a
/// floating value badge.
///
/// Inspired by smart-thermostat UIs, this component provides an expressive way
/// to select a numerical value within a bounded range by dragging vertically.
///
/// Features:
/// - **Gradient fill**: The filled track blends from [SliderControlStyle.lowColor]
///   at the minimum to [SliderControlStyle.highColor] at the maximum.
/// - **Floating badge**: A circular value badge floats alongside the thumb
///   position, fading in during drag and fading out after the gesture ends.
/// - **Tick marks**: Optional evenly-spaced ticks appear beside the track,
///   optionally coloured by position using the same gradient.
/// - **Spring snap**: Values snap to the nearest step using a spring-physics
///   settle after the drag ends.
/// - **Press feedback**: The pill scales down slightly on touch (Emil principle).
/// - **Haptics**: [HapticFeedback.selectionClick] fires at each step crossing.
class SliderControl extends StatefulWidget {
  /// Creates a [SliderControl].
  const SliderControl({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    required this.onChanged,
    this.onChangeEnd,
    this.style = const SliderControlStyle(),
    this.height,
  });

  /// The current value. Must be within [min]..[max].
  final double value;

  /// The minimum selectable value.
  final double min;

  /// The maximum selectable value.
  final double max;

  /// The snap increment. Values reported via [onChanged] are always multiples
  /// of this within the [min]..[max] range.
  final double step;

  /// Called whenever the value changes during or after interaction.
  final ValueChanged<double> onChanged;

  /// Called when the user has finished dragging and released the touch gesture.
  final ValueChanged<double>? onChangeEnd;

  /// Visual configuration for the component.
  final SliderControlStyle style;

  /// Explicit height of the pill track. Defaults to filling available height
  /// up to a maximum of 320 dp.
  final double? height;

  @override
  State<SliderControl> createState() => _SliderControlState();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _SliderControlState extends State<SliderControl>
    with TickerProviderStateMixin {
  // Fraction representing the current fill level: 0.0 = min, 1.0 = max.
  late double _fraction;

  // The last snapped integer value, used for haptic step detection.
  late double _lastSnapped;

  // State machine tracking idle vs. dragging phase.
  _SliderState _state = _Idle();

  // Locked direction indicating if fill should grow from top (HI) downwards or bottom (LO) upwards.
  bool _fillFromTop = false;

  // ── Animation controllers ─────────────────────────────────────────────────

  // Controls the interaction state (opacity of ticks, scale of badge).
  late final AnimationController _badgeOpacityCtrl;
  late final Animation<double> _ticksOpacity;
  late final Animation<double> _ticksScale;
  late final Animation<double> _badgeScale;

  // Controls the press scale on the entire pill (0.97 on press, 1.0 on release).
  late final AnimationController _pressScaleCtrl;
  late final Animation<double> _pressScale;

  // Drives the spring-settle animation from live drag fraction → snapped step.
  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnimation;

  // Badge fade-out timer, reset on every drag update.
  Timer? _badgeTimer;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fraction = _valueToFraction(widget.value);
    _lastSnapped = _snap(_fraction);
    _fillFromTop = _fraction > 0.5;

    _badgeOpacityCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _ticksOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeOpacityCtrl,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        reverseCurve: Curves.easeIn,
      ),
    );
    _ticksScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeOpacityCtrl,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        reverseCurve: Curves.easeIn,
      ),
    );
    _badgeScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _badgeOpacityCtrl,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        reverseCurve: Curves.easeIn,
      ),
    );

    _pressScaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressScaleCtrl, curve: Curves.easeOut),
    );

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _snapAnimation = Tween<double>(
      begin: _fraction,
      end: _fraction,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: const _SpringSettle()));
  }

  @override
  void didUpdateWidget(SliderControl old) {
    super.didUpdateWidget(old);
    // Sync external value changes when not dragging.
    if (old.value != widget.value && _state is _Idle) {
      final target = _valueToFraction(widget.value);
      _fillFromTop = target > 0.5;
      _animateSnapTo(target);
    }
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    _badgeOpacityCtrl.dispose();
    _pressScaleCtrl.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double _valueToFraction(double v) =>
      ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double _fractionToValue(double f) =>
      widget.min + f * (widget.max - widget.min);

  /// Returns the nearest step-snapped value for a given fraction.
  double _snap(double f) {
    final raw = _fractionToValue(f);
    return ((raw / widget.step).roundToDouble() * widget.step)
        .clamp(widget.min, widget.max);
  }

  void _animateSnapTo(double targetFraction) {
    final start = _fraction;
    _snapAnimation = Tween<double>(begin: start, end: targetFraction).animate(
      CurvedAnimation(parent: _snapCtrl, curve: const _SpringSettle()),
    );
    _snapCtrl
      ..removeListener(_onSnapTick)
      ..reset()
      ..addListener(_onSnapTick)
      ..forward();
  }

  void _onSnapTick() {
    if (mounted) {
      setState(() => _fraction = _snapAnimation.value);
    }
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details, double trackHeight) {
    _snapCtrl.stop();
    _pressScaleCtrl.forward();
    _badgeOpacityCtrl.forward();

    final s = widget.style;
    if (trackHeight > 0) {
      final double localY = details.localPosition.dy.clamp(0.0, trackHeight);

      // Check if touch is inside the current badge vertical bounds (to avoid jumping when starting a drag from the handle)
      const double badgePadding = 4.0;
      final double currentBadgeTop = badgePadding +
          (trackHeight - s.badgeSize - 2 * badgePadding) * (1.0 - _fraction);
      final bool touchedHandle = localY >= currentBadgeTop &&
          localY <= currentBadgeTop + s.badgeSize;

      if (touchedHandle) {
        // Just start dragging from the current fraction without seeking
        setState(() {
          _fillFromTop = _fraction > 0.5;
          _state = _Dragging(_fraction);
        });
      } else {
        // Tap-to-seek to the tapped position on the track
        final double targetFraction = 1.0 - (localY / trackHeight);
        final snapped = _snap(targetFraction);
        if (s.enableHaptics && snapped != _lastSnapped) {
          HapticFeedback.selectionClick();
          widget.onChanged(snapped);
        }
        _lastSnapped = snapped;

        setState(() {
          _fraction = targetFraction;
          _fillFromTop = _fraction > 0.5;
          _state = _Dragging(_fraction);
        });
      }
    } else {
      setState(() {
        _fillFromTop = _fraction > 0.5;
        _state = _Dragging(_fraction);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double trackHeight) {
    if (trackHeight <= 0) return;

    // dy is positive downward → invert to get upward-positive delta.
    final delta = -details.delta.dy / trackHeight;
    // Allow slight overhang past the track bounds (from -0.15 to 1.15)
    final newFraction = (_fraction + delta).clamp(-0.15, 1.15);

    final snapped = _snap(newFraction.clamp(0.0, 1.0));
    if (widget.style.enableHaptics && snapped != _lastSnapped) {
      HapticFeedback.selectionClick();
      widget.onChanged(snapped);
    }
    _lastSnapped = snapped;

    setState(() {
      _fraction = newFraction;
      _state = _Dragging(newFraction);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _pressScaleCtrl.reverse();

    final finalSnappedVal = _snap(_fraction.clamp(0.0, 1.0));
    final snappedFraction = _valueToFraction(finalSnappedVal);
    widget.onChanged(finalSnappedVal);
    widget.onChangeEnd?.call(finalSnappedVal);

    // Spring-settle back within the correct track boundaries
    _animateSnapTo(snappedFraction);

    setState(() => _state = _Idle());

    // Fade badge out after 1.5 s of inactivity.
    _scheduleBadgeFade();
  }

  void _scheduleBadgeFade() {
    _badgeTimer?.cancel();
    _badgeTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_state is _Idle) {
        _badgeOpacityCtrl.reverse();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = widget.style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackHeight = widget.height ??
            math.min(
              constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0,
              320.0,
            );

        // Define columns layout metrics
        final double ticksColWidth = s.showTicks ? (s.tickWidth * 3.8 + 12.0) : 0.0;
        final double totalWidth = ticksColWidth + s.badgeGap + s.trackWidth;

        // Position coordinates based on the badgeAnchor configuration
        final double pillLeft = s.badgeAnchor == BadgeAnchor.right
            ? ticksColWidth + s.badgeGap
            : 0.0;
        final double ticksLeft = s.badgeAnchor == BadgeAnchor.right
            ? 0.0
            : s.trackWidth + s.badgeGap;

        // The badge is mathematically centered horizontally inside the pill track
        final double badgeLeft = pillLeft + (s.trackWidth - s.badgeSize) / 2;
        const double badgePadding = 4.0;
        final double badgeTop = badgePadding +
            (trackHeight - s.badgeSize - 2 * badgePadding) * (1.0 - _fraction);

        final int displayValue = _snap(_fraction.clamp(0.0, 1.0)).round();

        return Semantics(
          label: 'Vertical adjustment slider',
          value: '$displayValue${s.valueSuffix}',
          slider: true,
          increasedValue: '${math.min(widget.max, widget.value + widget.step).round()}${s.valueSuffix}',
          decreasedValue: '${math.max(widget.min, widget.value - widget.step).round()}${s.valueSuffix}',
          onIncrease: () {
            final newVal = (widget.value + widget.step).clamp(widget.min, widget.max);
            widget.onChanged(newVal);
            if (s.enableHaptics) HapticFeedback.selectionClick();
          },
          onDecrease: () {
            final newVal = (widget.value - widget.step).clamp(widget.min, widget.max);
            widget.onChanged(newVal);
            if (s.enableHaptics) HapticFeedback.selectionClick();
          },
          child: SizedBox(
            width: totalWidth,
            height: trackHeight + (s.bottomIcon != null ? s.bottomIconSize + 16.0 : 0.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Tick marks (separate progress column, fades out dynamically when idle) ──
                if (s.showTicks)
                  Positioned(
                    left: ticksLeft,
                    top: 0,
                    width: ticksColWidth,
                    height: trackHeight,
                    child: IgnorePointer(
                      child: FadeTransition(
                        opacity: _ticksOpacity,
                        child: ScaleTransition(
                          scale: _ticksScale,
                          alignment: s.badgeAnchor == BadgeAnchor.right
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: CustomPaint(
                            painter: _LeftTicksPainter(
                              fraction: _fraction.clamp(0.0, 1.0),
                              style: s,
                              fillFromTop: _fillFromTop,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Pill track ─────────────────────────────────────────────
                Positioned(
                  left: pillLeft,
                  top: 0,
                  width: s.trackWidth,
                  height: trackHeight,
                  child: ScaleTransition(
                    scale: _pressScale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) => _onPanStart(d, trackHeight),
                      onPanUpdate: (d) => _onPanUpdate(d, trackHeight),
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _TrackPainter(
                          fraction: _fraction.clamp(0.0, 1.0),
                          style: s,
                        ),
                        size: Size(s.trackWidth, trackHeight),
                      ),
                    ),
                  ),
                ),

                // ── Bottom Icon (rendered below the pill track, not inside) ──
                if (s.bottomIcon != null)
                  Positioned(
                    left: pillLeft + (s.trackWidth - s.bottomIconSize) / 2,
                    top: trackHeight + 12.0,
                    width: s.bottomIconSize,
                    height: s.bottomIconSize,
                    child: Icon(
                      s.bottomIcon,
                      color: s.bottomIconColor,
                      size: s.bottomIconSize,
                    ),
                  ),

                // ── Value badge (centered thumb handle, always visible and active) ──────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOut,
                  top: badgeTop,
                  left: badgeLeft,
                  width: s.badgeSize,
                  height: s.badgeSize,
                  child: IgnorePointer(
                    child: ScaleTransition(
                      scale: _pressScale,
                      child: ScaleTransition(
                        scale: _badgeScale,
                        child: Stack(
                          children: [
                            // 1. Solid circular handle background
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.badgeBackgroundColor == Colors.transparent
                                    ? (s.trackBackgroundColor.computeLuminance() < 0.5
                                        ? const Color(0xFF2C2C2E)
                                        : Colors.white)
                                    : s.badgeBackgroundColor,
                              ),
                            ),
                            // 2. Active progress ring and text digits (always visible)
                            CustomPaint(
                              painter: _BadgePainter(
                                fraction: _fraction.clamp(0.0, 1.0),
                                style: s,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$displayValue',
                                      style: s.valueTextStyle,
                                    ),
                                    if (s.valueSuffix.isNotEmpty)
                                      Text(
                                        s.valueSuffix,
                                        style: s.suffixTextStyle,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

/// Paints the pill-shaped track background.
class _TrackPainter extends CustomPainter {
  _TrackPainter({required this.fraction, required this.style});

  final double fraction;
  final SliderControlStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final s = style;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(s.trackBorderRadius),
    );

    // 1. Dark pill background.
    final bgPaint = Paint()..color = s.trackBackgroundColor;
    canvas.drawRRect(rr, bgPaint);

    // 2. Subtle pill border.
    if (s.trackBorderWidth > 0 && s.trackBorderColor != Colors.transparent) {
      final borderPaint = Paint()
        ..color = s.trackBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.trackBorderWidth;
      canvas.drawRRect(rr, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.fraction != fraction || old.style != style;
}

/// Paints the vertical tick marks progress column to the left of the track.
class _LeftTicksPainter extends CustomPainter {
  _LeftTicksPainter({
    required this.fraction,
    required this.style,
    required this.fillFromTop,
  });

  final double fraction;
  final SliderControlStyle style;
  final bool fillFromTop;

  @override
  void paint(Canvas canvas, Size size) {
    final s = style;
    if (s.tickCount <= 0) return;

    final double luminance = s.trackBackgroundColor.computeLuminance();
    final bool isDarkBg = luminance < 0.5;

    final Color labelColor = isDarkBg
        ? Colors.white.withValues(alpha: 0.8)
        : const Color(0xFF1C1C1E).withValues(alpha: 0.8);
    final Color arrowColor = s.arrowColor ??
        (isDarkBg ? Colors.white : const Color(0xFF1C1C1E));
    final Color lineStrokeColor =
        isDarkBg ? Colors.white.withValues(alpha: 0.3) : const Color(0x2B000000);
    final Color inactiveTickColor =
        isDarkBg ? Colors.white.withValues(alpha: 0.2) : const Color(0x24000000);

    final bool isTopActive = fillFromTop || fraction == 1.0;
    final bool isBottomActive = (!fillFromTop && fraction > 0.0) || fraction == 0.0;

    final Color hiTextColor = isTopActive ? s.highColor : labelColor;
    final Color loTextColor = isBottomActive ? s.lowColor : labelColor;

    final double hiFontSize = math.max(8.0, s.tickWidth * 1.2);
    final double loFontSize = math.max(8.0, s.tickWidth * 1.2);

    final hiPainter = TextPainter(
      text: TextSpan(
        text: s.topLabel,
        style: TextStyle(
          fontSize: hiFontSize,
          fontWeight: FontWeight.w800,
          color: hiTextColor,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final loPainter = TextPainter(
      text: TextSpan(
        text: s.bottomLabel,
        style: TextStyle(
          fontSize: loFontSize,
          fontWeight: FontWeight.w800,
          color: loTextColor,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double labelWidth = math.max(hiPainter.width, loPainter.width);

    final bool alignToRight = s.badgeAnchor == BadgeAnchor.right;
    final double hiLabelX = alignToRight ? 0.0 : size.width - hiPainter.width;
    final double loLabelX = alignToRight ? 0.0 : size.width - loPainter.width;

    // Define tick limits to align with the center of the badge at extremes (accounting for 4px padding)
    const double badgePadding = 4.0;
    final double ticksTop = badgePadding + s.badgeSize / 2;
    final double ticksBottom = size.height - badgePadding - s.badgeSize / 2;
    final double ticksHeight = ticksBottom - ticksTop;

    // Paint limit labels centered vertically with the extreme ticks
    hiPainter.paint(canvas, Offset(hiLabelX, ticksTop - hiPainter.height / 2));
    loPainter.paint(canvas, Offset(loLabelX, ticksBottom - loPainter.height / 2));

    final double inactiveWidth = s.tickWidth;
    final double activeWidthMax = s.tickWidth * 1.5;
    final double limitLineWidth = s.tickWidth * 1.8;
    final double inactiveThickness = s.tickThickness;
    final double segmentGap = s.tickGap / 2;

    final Color topLimitColor = isTopActive ? s.highColor : lineStrokeColor;
    final Color bottomLimitColor = isBottomActive ? s.lowColor : lineStrokeColor;

    final double basePinX = alignToRight ? size.width : 0.0;
    final double limitEndX = alignToRight ? size.width - limitLineWidth : limitLineWidth;
    final double textLinkEndX = alignToRight ? labelWidth + 6.0 : size.width - labelWidth - 6.0;
    final double textLinkStartX =
        alignToRight ? size.width - limitLineWidth - 4.0 : limitLineWidth + 4.0;

    canvas.drawLine(
      Offset(limitEndX, ticksTop),
      Offset(basePinX, ticksTop),
      Paint()
        ..color = topLimitColor
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      Offset(limitEndX, ticksBottom),
      Offset(basePinX, ticksBottom),
      Paint()
        ..color = bottomLimitColor
        ..strokeWidth = 2.0,
    );

    if (alignToRight) {
      if (textLinkEndX < textLinkStartX) {
        canvas.drawLine(
          Offset(textLinkEndX, ticksTop),
          Offset(textLinkStartX, ticksTop),
          Paint()
            ..color = lineStrokeColor.withValues(alpha: lineStrokeColor.a / 2)
            ..strokeWidth = 1.0,
        );
        canvas.drawLine(
          Offset(textLinkEndX, ticksBottom),
          Offset(textLinkStartX, ticksBottom),
          Paint()
            ..color = lineStrokeColor.withValues(alpha: lineStrokeColor.a / 2)
            ..strokeWidth = 1.0,
        );
      }
    } else {
      if (textLinkEndX > textLinkStartX) {
        canvas.drawLine(
          Offset(textLinkEndX, ticksTop),
          Offset(textLinkStartX, ticksTop),
          Paint()
            ..color = lineStrokeColor.withValues(alpha: lineStrokeColor.a / 2)
            ..strokeWidth = 1.0,
        );
        canvas.drawLine(
          Offset(textLinkEndX, ticksBottom),
          Offset(textLinkStartX, ticksBottom),
          Paint()
            ..color = lineStrokeColor.withValues(alpha: lineStrokeColor.a / 2)
            ..strokeWidth = 1.0,
        );
      }
    }

    final int count = s.tickCount;
    final double blockHeight = (ticksHeight - (count - 1) * segmentGap) / count;
    final gradientShader = ui.Gradient.linear(
      Offset(alignToRight ? size.width - s.tickWidth / 2 : s.tickWidth / 2, ticksBottom),
      Offset(alignToRight ? size.width - s.tickWidth / 2 : s.tickWidth / 2, ticksTop),
      [s.lowColor, s.highColor],
    );

    final double rangeSize = 1.0 / count;
    for (int i = 0; i < count; i++) {
      final double y = ticksTop + i * (blockHeight + segmentGap);
      final double yCenter = y + blockHeight / 2;
      final double startFraction = (count - 1 - i) * rangeSize;
      final double endFraction = (count - i) * rangeSize;

      final double localFraction;
      if (fillFromTop) {
        if (fraction >= endFraction) {
          localFraction = 0.0;
        } else if (fraction <= startFraction) {
          localFraction = 1.0;
        } else {
          localFraction = (endFraction - fraction) / rangeSize;
        }
      } else {
        if (fraction <= startFraction) {
          localFraction = 0.0;
        } else if (fraction >= endFraction) {
          localFraction = 1.0;
        } else {
          localFraction = (fraction - startFraction) / rangeSize;
        }
      }

      if (localFraction == 0.0) {
        final double xStart = alignToRight ? size.width - inactiveWidth : 0.0;
        final double xEnd = alignToRight ? size.width : inactiveWidth;
        canvas.drawLine(
          Offset(xStart, yCenter),
          Offset(xEnd, yCenter),
          Paint()
            ..color = inactiveTickColor
            ..strokeWidth = inactiveThickness,
        );
      } else {
        final double w = inactiveWidth + (activeWidthMax - inactiveWidth) * localFraction;
        final double h = inactiveThickness + (blockHeight - inactiveThickness) * localFraction;
        final double x = alignToRight ? size.width - w : 0.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, yCenter - h / 2, w, h),
            const Radius.circular(2.0),
          ),
          Paint()..shader = gradientShader,
        );
      }
    }

    final double arrowY = ticksTop + (1.0 - fraction) * ticksHeight;
    final double arrowWidth = s.tickWidth * 0.6;
    final double arrowHalfHeight = s.tickWidth * 0.45;

    final double arrowTipX = alignToRight ? size.width - limitLineWidth : limitLineWidth;
    final double arrowBaseX = alignToRight
        ? math.max(labelWidth + 6.0, size.width - limitLineWidth - arrowWidth)
        : math.min(size.width - labelWidth - 6.0, limitLineWidth + arrowWidth);

    canvas.drawPath(
      Path()
        ..moveTo(arrowBaseX, arrowY - arrowHalfHeight)
        ..lineTo(arrowTipX, arrowY)
        ..lineTo(arrowBaseX, arrowY + arrowHalfHeight)
        ..close(),
      Paint()
        ..color = arrowColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LeftTicksPainter old) =>
      old.fraction != fraction || old.style != style || old.fillFromTop != fillFromTop;
}

/// Paints the circular value badge with a vertically-split progress ring outline.
///
/// The circular outline is split by a horizontal line that moves vertically based
/// on the progress fraction:
/// - Lower portion: colored using [SliderControlStyle.lowColor].
/// - Upper portion: colored using [SliderControlStyle.highColor].
class _BadgePainter extends CustomPainter {
  _BadgePainter({required this.fraction, required this.style});

  final double fraction;
  final SliderControlStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final s = style;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - s.badgeBorderWidth) / 2;

    final double luminance = s.trackBackgroundColor.computeLuminance();
    final bool isDarkBg = luminance < 0.5;

    final Color circleBgColor = s.badgeBackgroundColor == Colors.transparent
        ? (isDarkBg ? const Color(0xFF2C2C2E) : Colors.white)
        : s.badgeBackgroundColor;

    // 1. Draw solid background for the circle to obscure the track underneath
    final bgPaint = Paint()
      ..color = circleBgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, bgPaint);

    // 2. Draw the symmetrical progress arcs with gaps at top/bottom and rounded ends
    final activePaint = Paint()
      ..color = s.highColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.badgeBorderWidth
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = s.lowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.badgeBorderWidth
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Maintain a constant gap angle of 0.08 radians (~4.5 degrees) for all values,
    // scaling down to 0 only at the absolute limits (0.0 and 1.0) using a 4% edge threshold.
    final double baseGap = 0.08;
    final double edgeThreshold = 0.04;
    final double gapScale;
    if (fraction <= 0.0 || fraction >= 1.0) {
      gapScale = 0.0;
    } else if (fraction < edgeThreshold) {
      gapScale = fraction / edgeThreshold;
    } else if (fraction > 1.0 - edgeThreshold) {
      gapScale = (1.0 - fraction) / edgeThreshold;
    } else {
      gapScale = 1.0;
    }
    final double gapAngle = baseGap * gapScale;

    // Calculate sweep angles dynamically for both segments
    final double activeSweep = (2 * math.pi * fraction) - (2 * gapAngle);
    final double inactiveSweep = (2 * math.pi * (1.0 - fraction)) - (2 * gapAngle);

    // ── ACTIVE ARC (Red, top-centered continuous arch) ──
    if (activeSweep > 0) {
      final double activeStart = -math.pi / 2 - (math.pi * fraction) + gapAngle;
      canvas.drawArc(arcRect, activeStart, activeSweep, false, activePaint);
    }

    // ── INACTIVE ARC (Blue, bottom-centered continuous arch) ──
    if (inactiveSweep > 0) {
      final double inactiveStart = math.pi / 2 - (math.pi * (1.0 - fraction)) + gapAngle;
      canvas.drawArc(arcRect, inactiveStart, inactiveSweep, false, inactivePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BadgePainter old) =>
      old.fraction != fraction || old.style != style;
}

// ─────────────────────────────────────────────────────────────────────────────
// Spring settle curve
// ─────────────────────────────────────────────────────────────────────────────

/// An overdamped spring curve used to settle the fill after a drag.
///
/// Simulates a physical spring that decelerates quickly without oscillation,
/// giving the snap a natural, physicsy feel rather than a linear ease.
class _SpringSettle extends Curve {
  const _SpringSettle();

  static const double _stiffness = 180;
  static const double _damping = 22;
  static const double _settlingTime = 1.0;

  @override
  double transformInternal(double t) {
    // Manual spring simulation: x(t) = 1 - e^(-damping*t) * cos(ω*t)
    // Approximated inline to avoid importing physics package.
    final double ratio = _damping / (2 * math.sqrt(_stiffness));
    if (ratio >= 1) {
      // Overdamped: no oscillation.
      final double r1 = -_damping / 2 +
          math.sqrt(_damping * _damping / 4 - _stiffness);
      final double r2 = -_damping / 2 -
          math.sqrt(_damping * _damping / 4 - _stiffness);
      final double tt = t * _settlingTime;
      final double c2 = (r1) / (r1 - r2);
      final double c1 = 1 - c2;
      return 1 - (c1 * math.exp(r1 * tt) + c2 * math.exp(r2 * tt)).clamp(-0.1, 1.1);
    } else {
      // Underdamped: slight oscillation.
      final double wd =
          math.sqrt(_stiffness - _damping * _damping / 4);
      final double tt = t * _settlingTime;
      return (1 -
              math.exp(-_damping / 2 * tt) *
                  (math.cos(wd * tt) +
                      (_damping / (2 * wd)) * math.sin(wd * tt)))
          .clamp(0.0, 1.0);
    }
  }
}
