import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/fractional_picker_style.dart';
import 'widgets/fractional_ruler_painter.dart';

/// A premium, minimalist fractional picker component.
///
/// Allows users to select values by scrolling a horizontal ruler.
/// Supports both integer and decimal increments with haptic feedback
/// and smooth snapping.
///
/// ## Performance architecture
/// The ruler repaints via [AnimatedBuilder] with the [ScrollController]'s
/// position as its [Listenable]. This means **zero `setState` calls** during
/// scrolling — only the [CustomPaint] subtree repaints, not the full widget
/// tree. The parent receives value callbacks only when the snapped value
/// actually changes across a step boundary.
class ModernFractionalPicker extends StatefulWidget {
  /// Creates a [ModernFractionalPicker] with the given configuration.
  const ModernFractionalPicker({
    super.key,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.initialValue = 18.0,
    this.decimalPlaces = 0,
    this.enableHaptics = true,
    required this.onValueChanged,
    this.height = 96,
    this.style,
  });

  /// The minimum scrollable value.
  final double minValue;

  /// The maximum scrollable value.
  final double maxValue;

  /// The initially selected value.
  final double initialValue;

  /// 0 = integer steps only, 1 = 0.1 decimal steps.
  final int decimalPlaces;

  /// Whether to trigger haptic feedback as values cross step boundaries.
  final bool enableHaptics;

  /// Callback fired when the selected value changes by at least one step.
  final ValueChanged<double> onValueChanged;

  /// Height of the picker container in logical pixels.
  final double height;

  /// Visual style override. Falls back to [FractionalPickerStyle] defaults.
  final FractionalPickerStyle? style;

  @override
  State<ModernFractionalPicker> createState() => _ModernFractionalPickerState();
}

class _ModernFractionalPickerState extends State<ModernFractionalPicker> {
  late final ScrollController _scrollController;

  /// Returns the visual density of the ruler based on the decimal precision.
  double get _pixelsPerUnit => widget.decimalPlaces == 0 ? 64.0 : 120.0;

  /// Last value reported to the caller — used to fire callbacks only on change.
  late double _lastReportedValue;

  @override
  void initState() {
    super.initState();
    _lastReportedValue = widget.initialValue;

    _scrollController = ScrollController(
      initialScrollOffset: (widget.initialValue - widget.minValue) * _pixelsPerUnit,
    );

    _scrollController.addListener(_onScrollPositionChanged);
  }

  /// Converts the raw scroll offset to a snapped value and fires callbacks.
  ///
  /// Called on every scroll event (up to 120 times per second on ProMotion
  /// devices). It does NOT call [setState] — the ruler repaints via
  /// [AnimatedBuilder] which listens to the controller directly.
  void _onScrollPositionChanged() {
    if (!_scrollController.hasClients) return;

    final double rawValue =
        (_scrollController.offset / _pixelsPerUnit) + widget.minValue;
    final double clamped = rawValue.clamp(widget.minValue, widget.maxValue);

    final double step = widget.decimalPlaces == 0 ? 1.0 : 0.1;
    // Round to the nearest step to determine which value we're "at".
    final double snapped =
        double.parse(((clamped / step).round() * step).toStringAsFixed(widget.decimalPlaces));

    if ((snapped - _lastReportedValue).abs() >= step * 0.99) {
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      _lastReportedValue = snapped;
      widget.onValueChanged(snapped);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollPositionChanged);
    _scrollController.dispose();
    super.dispose();
  }

  /// Returns the ruler value that corresponds to the current scroll position.
  ///
  /// This is computed inline inside [AnimatedBuilder] so it is always
  /// synchronised with the paint offset without any extra state.
  double get _currentRulerValue {
    if (!_scrollController.hasClients) return widget.initialValue;
    final double raw =
        (_scrollController.offset / _pixelsPerUnit) + widget.minValue;
    return raw.clamp(widget.minValue, widget.maxValue);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? const FractionalPickerStyle();
    final double stepWidth = widget.decimalPlaces == 0 ? _pixelsPerUnit : (_pixelsPerUnit / 10.0);

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.none, // Allow pointer to overflow
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── 1. Ruler ────────────────────────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(style.borderRadius),
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) => RepaintBoundary(
                    child: CustomPaint(
                      painter: FractionalRulerPainter(
                        currentValue: _currentRulerValue,
                        minValue: widget.minValue,
                        maxValue: widget.maxValue,
                        activeColor: style.activeColor,
                        inactiveColor: style.inactiveColor,
                        tickColor: style.tickColor,
                        pixelsPerUnit: _pixelsPerUnit,
                        decimalPlaces: widget.decimalPlaces,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Static pointer indicator ─────────────────────────────────────
          Positioned(
            top: -8, // Matches new rectHeight
            left: 0,
            right: 0,
            child: Center(
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(24, 26),
                  painter: _PointerPainter(style.pointerColor),
                ),
              ),
            ),
          ),

          // ── 3. Interaction layer ─────────────────────────────────────────────
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: Semantics(
                label: 'Fractional value picker',
                value: _currentRulerValue.toStringAsFixed(widget.decimalPlaces),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: _StepSnapScrollPhysics(
                    stepWidth: stepWidth,
                    friction: style.friction,
                    snapStiffness: style.snapStiffness,
                    parent: const ClampingScrollPhysics(),
                  ),
                  child: SizedBox(
                    width: (widget.maxValue - widget.minValue) * _pixelsPerUnit +
                        MediaQuery.sizeOf(context).width,
                    height: widget.height,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/// A custom [ScrollPhysics] that snaps the ruler to discrete step boundaries.
///
/// Uses [SpringDescription.withDampingRatio] with ratio > 1.0 to guarantee
/// a critically overdamped spring — meaning the scroll glides smoothly to
/// the target in one direction with **zero oscillation or rebound**.
class _StepSnapScrollPhysics extends ScrollPhysics {
  const _StepSnapScrollPhysics({
    required this.stepWidth,
    required this.friction,
    required this.snapStiffness,
    super.parent,
  });

  final double stepWidth;
  final double friction;
  final double snapStiffness;

  @override
  _StepSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _StepSnapScrollPhysics(
      stepWidth: stepWidth,
      friction: friction,
      snapStiffness: snapStiffness,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(ScrollMetrics position, double velocity, Tolerance tolerance) {
    double step = position.pixels / stepWidth;
    if (velocity < -tolerance.velocity) {
      step = step.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      step = step.ceilToDouble();
    } else {
      step = step.roundToDouble();
    }
    return step * stepWidth;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    
    // 1. Prediction based on customizable friction.
    final double finalPos = position.pixels + (velocity / (friction * 10.0));
    final double snappedTarget = (finalPos / stepWidth).round() * stepWidth;

    // 2. Snap with customizable stiffness.
    return ScrollSpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: snapStiffness,
        ratio: 1.0, 
      ),
      position.pixels,
      snappedTarget,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

class _PointerPainter extends CustomPainter {
  /// Creates a [_PointerPainter] with the given [color].
  _PointerPainter(this.color);

  /// The fill color of the pointer.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double rectHeight = 8.0;

    // 1. Draw rectangle with slightly more rounded top corners
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, rectHeight),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      ),
      paint,
    );

    // 2. Draw triangle starting EXACTLY from the bottom of the rectangle
    // This part will be inside the card
    final Path path = Path()
      ..moveTo(0, rectHeight) // Start from full width at border
      ..lineTo(size.width, rectHeight)
      ..lineTo(size.width / 2 + 2, size.height - 4)
      ..quadraticBezierTo(size.width / 2, size.height - 1, size.width / 2 - 2, size.height - 4)
      ..close();

    canvas.drawPath(path, paint);

    // 3. Small dot at the very tip for precision
    canvas.drawCircle(Offset(size.width / 2, size.height), 2.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
