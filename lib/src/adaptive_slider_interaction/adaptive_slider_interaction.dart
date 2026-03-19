import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/premium_flip_counter.dart';
import 'models/adaptive_slider_style.dart';
import 'widgets/slider_track_painter.dart';

/// A premium, highly customizable [Slider] alternative.
/// 
/// This component features a dynamic design where the look and feel (gradients, thumb style)
/// adapts dynamically based on the current value. It includes a 3D odometer-style 
/// counter for the number display and a custom-painted track with decorative dots.
/// 
/// All values, dots, and colors are calculated dynamically based on the provided 
/// [min], [max], [step], and [dotCount] parameters.
class AdaptiveSliderInteraction extends StatefulWidget {
  /// The current value of the slider (between 0.0 and 1.0).
  final double value;

  /// The minimum value of the slider.
  final double min;

  /// The maximum value of the slider.
  final double max;

  /// Called when the user drags the slider thumb.
  final ValueChanged<double> onChanged;

  /// The title displayed at the top (e.g., "Calories").
  final String title;

  /// The unit displayed next to the value (e.g., "kCal").
  final String unit;

  /// The style configuration for the slider.
  final AdaptiveSliderStyle style;

  /// The number of decorative dots shown in the track. If null, it is calculated
  /// automatically based on [min], [max], and [step] to align with snap points.
  final int? dotCount;

  /// The increment by which the value snaps.
  final double step;

  const AdaptiveSliderInteraction({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 350.0,
    this.title = 'Calories',
    this.unit = 'kCal',
    this.style = const AdaptiveSliderStyle(),
    this.dotCount,
    this.step = 50.0,
  });

  @override
  State<AdaptiveSliderInteraction> createState() => _AdaptiveSliderInteractionState();
}

/// Internal state for [AdaptiveSliderInteraction] handling animations and gesture math.
class _AdaptiveSliderInteractionState extends State<AdaptiveSliderInteraction> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _thumbScaleAnimation;
  final GlobalKey _trackKey = GlobalKey();
  
  // Track previous value to determine flip direction
  double _lastReportedValue = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedValue = widget.value;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _thumbScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant AdaptiveSliderInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _lastReportedValue = oldWidget.value; // Store the old value for flip direction
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Calculates the proportional value (0.0 to 1.0) based on the min/max range.
  double get _normalizedValue => ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  /// Interpolates current colors based on the value.
  List<Color> _getCurrentColors() {
    final t = _normalizedValue;
    if (widget.style.colorSteps.isEmpty) return [Colors.orange, Colors.red];

    // Find the current and next color steps.
    AdaptiveColorStep lower = widget.style.colorSteps.first;
    AdaptiveColorStep upper = widget.style.colorSteps.last;

    for (int i = 0; i < widget.style.colorSteps.length - 1; i++) {
        if (t >= widget.style.colorSteps[i].threshold && t <= widget.style.colorSteps[i+1].threshold) {
            lower = widget.style.colorSteps[i];
            upper = widget.style.colorSteps[i+1];
            break;
        }
    }

    if (lower == upper) return lower.colors;

    final double rangeT = (t - lower.threshold) / (upper.threshold - lower.threshold);
    
    // Interpolate each color in the gradient.
    final List<Color> interpolated = [];
    for (int i = 0; i < lower.colors.length; i++) {
      interpolated.add(Color.lerp(lower.colors[i], upper.colors[i], rangeT)!);
    }
    return interpolated;
  }

  /// Handles touch interaction by mapping a local offset to a slider value.
  void _handleInteraction(Offset localOffset, double totalWidth) {
    final double trackHeight = widget.style.trackHeight;
    // The active range for the thumb center is [trackHeight/2] to [width - trackHeight/2].
    final double startX = trackHeight / 2;
    final double endX = totalWidth - trackHeight / 2;
    final double range = endX - startX;

    if (range <= 0) return;

    // Normalize t relative to the active range
    final double t = ((localOffset.dx - startX) / range).clamp(0.0, 1.0);
    double newValue = widget.min + (t * (widget.max - widget.min));
    
    // Snap to the defined step
    newValue = (newValue / widget.step).round() * widget.step;
    newValue = newValue.clamp(widget.min, widget.max);
    
    if (newValue != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getCurrentColors();
    final int effectiveDotCount = widget.dotCount ?? 
        ((widget.max - widget.min) / widget.step).round() + 1;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Title
          Text(
            widget.title,
            style: TextStyle(
              color: widget.style.titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          // 2. Value Display (Number + Unit)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Premium Flip Counter for the number
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: colors,
                ).createShader(bounds),
                child: PremiumFlipCounter(
                  value: widget.value.round(),
                  upward: widget.value >= _lastReportedValue,
                  padWithZero: false,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800, // Softer than w900 for a rounded look
                    color: Colors.white, // Masked by shader
                    letterSpacing: -1.5,
                    fontFamily: widget.style.fontFamily ?? 'SF Pro Rounded', // Use custom or default
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: widget.style.unitColor.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Compact spacing to allow more hit area

          // 3. Interactive Slider Track
          GestureDetector(
            onPanStart: (_) => _animationController.forward(),
            onPanEnd: (_) => _animationController.reverse(),
            onTapDown: (details) {
              _animationController.forward();
              final RenderBox? box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                _handleInteraction(box.globalToLocal(details.globalPosition), box.size.width);
              }
            },
            onTapUp: (_) => _animationController.reverse(),
            onPanUpdate: (details) {
              final RenderBox? box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                _handleInteraction(box.globalToLocal(details.globalPosition), box.size.width);
              }
            },
            child: Container(
              key: _trackKey,
              color: Colors.transparent, // Expand hit area
              // Massive hit area: 20px top + 32px bottom = 52px + track height
              // Bottom: 32px from the track center to the card edge for perfect symmetry
              padding: const EdgeInsets.only(top: 20, bottom: 32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double thumbSize = widget.style.thumbSize;
                  final double trackHeight = widget.style.trackHeight;
                  final double normalized = _normalizedValue;

                  // To be perfectly concentric, the filling is a stadium from 0 to [activeWidth].
                  // The thumb is centered at [activeWidth - trackHeight/2].
                  // activeWidth ranges from [trackHeight] to [width].
                  final double activeWidth = trackHeight + (normalized * (width - trackHeight));
                  final double thumbCenterX = activeWidth - (trackHeight / 2);

                  return SizedBox(
                    height: trackHeight,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Track and Overlay Dots (Fills the track)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SliderTrackPainter(
                              progress: normalized,
                              colors: colors,
                              inactiveColor: widget.style.inactiveColor,
                              borderRadius: widget.style.trackBorderRadius,
                              dotCount: effectiveDotCount,
                              activeDotColor: widget.style.activeDotColor,
                              inactiveDotColor: widget.style.inactiveDotColor,
                              thumbSize: thumbSize,
                              trackHeight: trackHeight,
                            ),
                          ),
                        ),

                        // 2. Thumb (Selector)
                        Positioned(
                          left: thumbCenterX - (thumbSize / 2),
                          child: ScaleTransition(
                            scale: _thumbScaleAnimation,
                            child: _SliderThumb(
                              size: thumbSize,
                              colors: colors,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The circular thumb of the slider with a white interior and thick colored border.
class _SliderThumb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _SliderThumb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          width: 5.0,
          color: colors.last.withValues(alpha: 0.8), // Dynamic border reflecting progress
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
