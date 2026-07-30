import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'models/emotion_selector_style.dart';

/// A premium, physics-based emotion selector widget modeled after Apple Health State of Mind UI.
///
/// Built with a custom dynamic pushing layout engine that maintains exact gaps between all items,
/// pushing adjacent pills outwards as the selected pill expands.
class EmotionSelector extends StatefulWidget {
  /// The style configuration for the component.
  final EmotionSelectorStyle style;

  /// Callback fired when the final selection is submitted (via the UP arrow).
  final ValueChanged<int>? onSubmitted;

  /// Custom widget builder for the expanded content area (e.g. Emotions/Context).
  final Widget Function(BuildContext context, int selectedIndex)? expandedContentBuilder;

  /// Optional title displayed above the selector that morphs to match the active emotion's gradient.
  final String? title;

  /// Creates an [EmotionSelector].
  const EmotionSelector({
    super.key,
    this.style = const EmotionSelectorStyle(),
    this.onSubmitted,
    this.expandedContentBuilder,
    this.title,
  });

  @override
  State<EmotionSelector> createState() => _EmotionSelectorState();
}

class _EmotionSelectorState extends State<EmotionSelector> {
  int? _selectedIndex; // null when unselected / idle
  double _dragOffset = 0.0; // Manual scroll displacement during drag

  void _handleSelect(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
      _dragOffset = 0.0; // Reset drag when snapping
    });
  }

  void _handleDeselect() {
    if (_selectedIndex != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = null;
        _dragOffset = 0.0;
      });
    }
  }

  void _handleSubmit(int index) {
    HapticFeedback.mediumImpact();
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(index);
    }
    _handleDeselect();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_selectedIndex == null) return;
    
    double newOffset = _dragOffset + details.delta.dx;
    
    // Add physical friction (resistance) if dragging past the first or last item
    if ((_selectedIndex == 0 && newOffset > 0) || 
        (_selectedIndex == widget.style.emotionStyles.length - 1 && newOffset < 0)) {
      newOffset = _dragOffset + (details.delta.dx * 0.25); // 75% friction at edges
    }

    setState(() {
      _dragOffset = newOffset;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_selectedIndex == null) return;

    final double velocity = details.primaryVelocity ?? 0;
    
    // Velocity based swipe
    if (velocity < -300 && _selectedIndex! < widget.style.emotionStyles.length - 1) {
      _handleSelect(_selectedIndex! + 1);
      return;
    } else if (velocity > 300 && _selectedIndex! > 0) {
      _handleSelect(_selectedIndex! - 1);
      return;
    }

    // Distance based swipe (lowered threshold from 60 to 40 for responsiveness)
    if (_dragOffset < -40 && _selectedIndex! < widget.style.emotionStyles.length - 1) {
      _handleSelect(_selectedIndex! + 1);
    } else if (_dragOffset > 40 && _selectedIndex! > 0) {
      _handleSelect(_selectedIndex! - 1);
    } else {
      // Snap back to center
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectedMode = _selectedIndex != null;
    final int activeIndex = _selectedIndex ?? 2;

    const Duration springDuration = Duration(milliseconds: 850);
    final Curve springCurve = SpringCurve(
      mass: 1.0,
      stiffness: 100.0, // Greatly reduced stiffness for a softer, 'lazy' pull
      damping: 12.0,    // Adjusted to keep a subtle 9% bounce
      durationSecs: 0.85,
    );

    Widget selectorLayout = LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        const double totalHeight = 350.0;
        const double gap = 8.0;

        // Dynamic width calculations per item
        double getItemWidth(int index) {
          if (!isSelectedMode) return 62.0; // Idle equal width
          return (index == _selectedIndex) ? 130.0 : 48.0; // Active expanded vs Inactive compact
        }

        // Dynamic height calculations per item
        double getItemHeight(int index) {
          if (!isSelectedMode) return 120.0; // Idle equal height (reduced)
          return (index == _selectedIndex) ? 250.0 : 64.0; // Active expanded vs Inactive compact (reduced)
        }

        // Calculate total row width
        double totalRowWidth = 0.0;
        for (int i = 0; i < widget.style.emotionStyles.length; i++) {
          totalRowWidth += getItemWidth(i);
        }
        totalRowWidth += (widget.style.emotionStyles.length - 1) * gap;

        // Calculate starting X offset
        double startX;
        if (!isSelectedMode) {
          // Center the entire 5-pill cluster on screen
          startX = (totalWidth - totalRowWidth) / 2;
        } else {
          // Center the active item precisely in the middle of the screen
          double activeItemCenterOffset = 0.0;
          for (int i = 0; i < activeIndex; i++) {
            activeItemCenterOffset += getItemWidth(i) + gap;
          }
          activeItemCenterOffset += getItemWidth(activeIndex) / 2;
          
          startX = (totalWidth / 2) - activeItemCenterOffset;
          // Apply manual drag offset
          startX += _dragOffset;
        }

        // Get exact X position for item index
        double getItemX(int targetIndex) {
          double x = startX;
          for (int i = 0; i < targetIndex; i++) {
            x += getItemWidth(i) + gap;
          }
          return x;
        }

        return GestureDetector(
          onTap: _handleDeselect, // Tap outside deselects and returns to 5 solid color row
          onHorizontalDragUpdate: _handleDragUpdate, // Smooth manual dragging
          onHorizontalDragEnd: _handleDragEnd, // Snaps to next/prev or bounces back
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: totalHeight,
            width: totalWidth,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Dreamy Radial Background Glow
                AnimatedPositioned(
                  duration: _dragOffset != 0.0 ? Duration.zero : springDuration,
                  curve: springCurve,
                  left: isSelectedMode 
                      ? getItemX(activeIndex) + (getItemWidth(activeIndex) / 2) - 250 
                      : (totalWidth / 2) - 250,
                  top: (totalHeight - 500) / 2,
                  width: 500,
                  height: 500,
                  child: AnimatedOpacity(
                    opacity: isSelectedMode ? 0.15 : 0.0, // Reduced from 0.35 to 0.15 for a much more subtle, elegant ambient glow
                    duration: const Duration(milliseconds: 500),
                    child: AnimatedContainer(
                      duration: springDuration,
                      curve: springCurve,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.style.emotionStyles[activeIndex].color,
                            widget.style.emotionStyles[activeIndex].color.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Render all 5 pills with dynamic pushing AnimatedPositioned
                ...List.generate(widget.style.emotionStyles.length, (index) {
                  final bool isThisSelected = isSelectedMode && (index == _selectedIndex);
                  final double w = getItemWidth(index);
                  final double h = getItemHeight(index);
                  final double x = getItemX(index);
                  final double y = (totalHeight - h) / 2;

                  final EmotionStyle itemStyle = widget.style.emotionStyles[index];

                  final Color bubbleColor = !isSelectedMode
                      ? itemStyle.color
                      : isThisSelected
                          ? itemStyle.color
                          : Colors.white.withValues(alpha: 0.08); // Glass silhouette

                  final Border? border = (isSelectedMode && !isThisSelected)
                      ? Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.0)
                      : null;

                  final double glowAlpha = isThisSelected ? 0.60 : 0.0;
                  final double borderRadius = isThisSelected ? 65.0 : 31.0; // 130 / 2 = 65 for perfect pill

                  return AnimatedPositioned(
                    key: ValueKey('pill_$index'),
                    duration: _dragOffset != 0.0 
                        ? Duration.zero // Instant follow while dragging
                        : springDuration, // Physical spring physics!
                    curve: springCurve,
                    left: x,
                    top: y,
                    width: w,
                    height: h,
                    child: GestureDetector(
                      onTap: () => _handleSelect(index),
                      child: _PressableBubble(
                        width: w,
                        height: h,
                        borderRadius: borderRadius,
                        color: bubbleColor,
                        border: border,
                        glowAlpha: glowAlpha,
                        springCurve: springCurve,
                        springDuration: springDuration,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Organic shape icon (translates to top when selected)
                            AnimatedAlign(
                              duration: springDuration,
                              curve: springCurve,
                              alignment: Alignment(0, isThisSelected ? -0.786 : 0.0), // -0.786 precisely places the top edge at 24px, giving it more breathing room from the border
                              child: CustomPaint(
                                size: const Size(26, 26),
                                painter: EmotionShapePainter(index: index),
                              ),
                            ),

                            // Expanded controls (Emotions/Context + Submit arrow)
                            if (isThisSelected)
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic), // Fades in ONLY after pill expands
                                builder: (context, value, child) {
                                  return Opacity(
                                    // Clamp opacity to 0.99 to prevent Flutter's compositing layer from 
                                    // being abruptly removed at 1.0, which causes BackdropFilters to "snap" or blink.
                                    opacity: value >= 0.99 ? 0.99 : value,
                                    child: Transform.scale(
                                      scale: 0.95 + (0.05 * value), // Subtle pop
                                      child: child,
                                    ),
                                  );
                                },
                                child: _ExpandedContent(
                                  style: itemStyle,
                                  expandedContent: widget.expandedContentBuilder != null
                                      ? widget.expandedContentBuilder!(context, index)
                                      : const SizedBox.shrink(),
                                  onSubmit: () => _handleSubmit(index),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Header title text (Animated gradient & position)
                if (widget.title != null)
                  AnimatedPositioned(
                    duration: springDuration,
                    curve: springCurve,
                    top: isSelectedMode ? 0.0 : 60.0, // Stays close to idle pills, moves up when expanding
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: Colors.white,
                          end: isSelectedMode ? widget.style.emotionStyles[activeIndex].color : Colors.white,
                        ),
                        duration: springDuration,
                        curve: springCurve,
                        builder: (context, color, child) {
                          final Color baseColor = color ?? Colors.white;
                          return ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _lighten(baseColor, 0.15), // Much lighter top to match the pill's top highlight
                                  _lighten(baseColor, 0.02), // Subtly lighter bottom to prevent looking muddy
                                ],
                              ).createShader(bounds);
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: Text(
                                isSelectedMode
                                    ? widget.style.emotionStyles[activeIndex].label
                                    : widget.title!,
                                key: ValueKey(isSelectedMode ? activeIndex : -1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );

    return selectorLayout;
  }
}

/// CustomPainter that renders all Apple Health State of Mind shape icons with rounded tips.
class EmotionShapePainter extends CustomPainter {
  final int index;

  const EmotionShapePainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.70),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    final path = Path();

    switch (index) {
      case 0: // Very Unpleasant: 8 rounded tips with deeper inner grooves
        _drawRoundedFlower(path, center, petals: 8, maxRadius: maxRadius, innerRadiusRatio: 0.42);
        break;

      case 1: // Unpleasant: 8 rounded tips with softer inner grooves
        _drawRoundedFlower(path, center, petals: 8, maxRadius: maxRadius, innerRadiusRatio: 0.58);
        break;

      case 2: // Neutral: Clean smooth circle
        canvas.drawCircle(center, maxRadius * 0.75, paint);
        return;

      case 3: // Pleasant: 5 rounded tips (star style)
        _drawRoundedFlower(path, center, petals: 5, maxRadius: maxRadius, innerRadiusRatio: 0.60);
        break;

      case 4: // Very Pleasant: 6 plump flower petals
      default:
        _drawRoundedFlower(path, center, petals: 6, maxRadius: maxRadius, innerRadiusRatio: 0.68);
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawRoundedFlower(Path path, Offset center, {required int petals, required double maxRadius, required double innerRadiusRatio}) {
    const int totalPoints = 120;
    final List<Offset> points = [];

    for (int i = 0; i <= totalPoints; i++) {
      final angle = (i / totalPoints) * 2 * math.pi;
      final r = maxRadius * (innerRadiusRatio + (1 - innerRadiusRatio) * (math.cos(angle * petals) + 1) / 2);
      
      // Rotate by -90 degrees (-pi/2) so the first peak points straight up
      final drawAngle = angle - (math.pi / 2);
      
      final x = center.dx + r * math.cos(drawAngle);
      final y = center.dy + r * math.sin(drawAngle);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
    }
    path.close();
  }

  @override
  bool shouldRepaint(EmotionShapePainter oldDelegate) => oldDelegate.index != index;
}

class _PressableBubble extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final Border? border;
  final double glowAlpha;
  final Curve springCurve;
  final Duration springDuration;
  final Widget child;

  const _PressableBubble({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
    this.border,
    required this.glowAlpha,
    required this.springCurve,
    required this.springDuration,
    required this.child,
  });

  @override
  State<_PressableBubble> createState() => _PressableBubbleState();
}

class _PressableBubbleState extends State<_PressableBubble> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: widget.springDuration,
          curve: widget.springCurve,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _lighten(widget.color, 0.05), // Softer/lighter at top
                _darken(widget.color, 0.08),  // Harder/darker at bottom
              ],
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border,
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final EmotionStyle style;
  final Widget expandedContent;
  final VoidCallback onSubmit;

  const _ExpandedContent({
    required this.style,
    required this.expandedContent,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Force the inner content to ALWAYS be the exact expanded size (130x230).
    // This prevents ANY layout recalculations or RenderFlex overflows during the animation.
    // The parent AnimatedContainer handles clipping (clipBehavior: Clip.antiAlias).
    return OverflowBox(
      minWidth: 130,
      maxWidth: 130,
      minHeight: 250,
      maxHeight: 250,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0, bottom: 24.0, left: 10.0, right: 10.0), // top: 50.0 matches EXACTLY the bottom edge of the top organic icon
        child: Column(
          children: [
            const Spacer(), // Distributes empty space equally above the glass card
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 108), // Caps max height
              child: expandedContent,
            ),
            const Spacer(), // Distributes empty space equally below the glass card
            GestureDetector(
              onTap: onSubmit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.lerp(Colors.white, style.color, 0.35) ?? Colors.white, // Stronger tint at the bottom so the gradient is clearly visible
                      Colors.white, // Pure white at the top
                    ],
                  ),
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: style.color,
                  size: 28, // Smaller size inside the circle, keeping the bold weight
                  weight: 800, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _darken(Color color, [double amount = 0.1]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color _lighten(Color color, [double amount = 0.1]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// A custom mathematical curve using Flutter's actual Physics engine (SpringSimulation)
/// This creates the authentic physical "resorte" bounce Emil Kowalski advocates for.
class SpringCurve extends Curve {
  final SpringSimulation _sim;
  final double _durationSecs;

  SpringCurve({
    double mass = 1.0,
    double stiffness = 150.0,
    double damping = 14.0,
    double durationSecs = 0.5,
  })  : _durationSecs = durationSecs,
        _sim = SpringSimulation(
          SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
          0.0, // Initial position
          1.0, // Final position
          0.0, // Initial velocity
        );

  @override
  double transformInternal(double t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    // t is 0..1, mapping to real time in seconds based on our assumed duration.
    return _sim.x(t * _durationSecs);
  }
}
