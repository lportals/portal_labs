import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/bloom_color_picker_style.dart';

/// The internal states of the Bloom Color Picker.
enum BloomColorPickerState {
  /// The compact state showing only the selected color and hex pill.
  closed,

  /// The transition state where the bloom expands.
  expanding,

  /// The fully open state showing the color wheel and lightness slider.
  open,
}

/// A premium color picker with a "Bloom" expansion effect and physics-based interactions.
class BloomColorPicker extends StatefulWidget {
  /// Creates a new `BloomColorPicker`.
  const BloomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.style = const BloomColorPickerStyle(),
    this.colors,
  });

  /// The initially selected color.
  final Color initialColor;

  /// Callback fired when the selected color changes.
  final ValueChanged<Color> onColorChanged;

  /// The visual styling and layout properties.
  final BloomColorPickerStyle style;

  /// Optional list of preset colors to display in the color wheel.
  /// If not provided, a default aesthetic palette is generated.
  final List<Color>? colors;

  @override
  State<BloomColorPicker> createState() => _BloomColorPickerState();
}

class _BloomColorPickerState extends State<BloomColorPicker> with SingleTickerProviderStateMixin {
  late Color _currentColor;
  BloomColorPickerState _state = BloomColorPickerState.closed;

  // Animation controller for the bloom and scale effects.
  late AnimationController _controller;
  late Animation<double> _bloomScale;
  late Animation<double> _contentOpacity;

  // Gesture state variables
  bool _isPressed = false;
  bool _isEditingText = false;
  bool _isDraggingSlider = false;

  late List<Color> _wheelColors;
  double _lightness = 0.5; // 0.0 to 1.0

  late TextEditingController _hexController;
  late FocusNode _hexFocusNode;

  late Animation<double> _pillScale;
  late Animation<double> _pillOpacity;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    
    // Setup default colors if none provided
    _wheelColors = widget.colors ?? _generateDefaultPalette();

    _hexController = TextEditingController(text: _colorToHex(_currentColor));
    _hexFocusNode = FocusNode();
    _hexFocusNode.addListener(_handleFocusChange);

    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );

    _bloomScale = Tween<double>(
      begin: 1.0, 
      end: widget.style.bloomRadius / widget.style.closedRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.style.animationCurve,
      ),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _pillScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _pillOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    _hexFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<Color> _generateDefaultPalette() {
    return const [
      Color(0xFFE57373), Color(0xFFF06292), Color(0xFFBA68C8),
      Color(0xFF9575CD), Color(0xFF7986CB), Color(0xFF64B5F6),
      Color(0xFF4FC3F7), Color(0xFF4DD0E1), Color(0xFF4DB6AC),
      Color(0xFF81C784), Color(0xFFAED581), Color(0xFFFFD54F),
      Color(0xFFFFB74D), Color(0xFFFF8A65), Color(0xFFA1887F),
    ];
  }

  void _toggleState() {
    if (widget.style.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _state = switch (_state) {
        BloomColorPickerState.closed => BloomColorPickerState.open,
        BloomColorPickerState.open || BloomColorPickerState.expanding => BloomColorPickerState.closed,
      };
    });

    if (_state == BloomColorPickerState.open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handlePressDown(TapDownDetails details) {
    if (_state == BloomColorPickerState.closed) {
      setState(() => _isPressed = true);
    }
  }

  void _handlePressUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _toggleState();
    }
  }

  void _handlePressCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  Color? _parseHex(String text) {
    final cleanText = text.replaceAll('#', '').trim();
    if (cleanText.length == 6) {
      final intVal = int.tryParse(cleanText, radix: 16);
      if (intVal != null) {
        return Color(0xFF000000 | intVal);
      }
    } else if (cleanText.length == 3) {
      final r = cleanText[0];
      final g = cleanText[1];
      final b = cleanText[2];
      final intVal = int.tryParse('$r$r$g$g$b$b', radix: 16);
      if (intVal != null) {
        return Color(0xFF000000 | intVal);
      }
    }
    return null;
  }

  void _handleFocusChange() {
    setState(() {
      _isEditingText = _hexFocusNode.hasFocus;
    });
    if (!_hexFocusNode.hasFocus) {
      final parsed = _parseHex(_hexController.text);
      if (parsed == null) {
        setState(() {
          _currentColor = Colors.white;
          _hexController.text = '#FFFFFF';
        });
        widget.onColorChanged(Colors.white);
      } else {
        setState(() {
          _currentColor = parsed;
          _hexController.text = _colorToHex(parsed);
        });
        widget.onColorChanged(parsed);
      }
    }
  }

  void _handleHexChanged(String value) {
    final parsed = _parseHex(value);
    if (parsed != null) {
      setState(() {
        _currentColor = parsed;
      });
      widget.onColorChanged(parsed);
    }
  }

  void _updateHexController() {
    if (!_hexFocusNode.hasFocus) {
      _hexController.text = _colorToHex(_currentColor);
    }
  }

  void _selectColor(Color color) {
    if (widget.style.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    
    // Extract lightness from current color and apply to new color base
    final hsl = HSLColor.fromColor(color);
    _lightness = hsl.lightness;

    setState(() {
      _currentColor = color;
      _updateHexController();
    });
    widget.onColorChanged(color);
    _toggleState();
  }

  @override
  Widget build(BuildContext context) {
    final double closedSize = widget.style.closedRadius * 2;
    final double bloomSize = widget.style.bloomRadius * 2;
    final bool isOpen = _state == BloomColorPickerState.open || _controller.isAnimating;

    // Calculate dynamic stack width relative to the configured bloom radius
    final double sliderRadius = widget.style.bloomRadius + 12.0;
    final double sliderMaxHorizontal = sliderRadius + (widget.style.sliderWidth / 2) + 6.0;
    final double stackWidthOpen = sliderMaxHorizontal * 2;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double height = lerpDouble(closedSize, bloomSize, _controller.value)! + 24;
          return SizedBox(
            height: height,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color Picker Stack
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double width = lerpDouble(closedSize, stackWidthOpen, _controller.value)!;
                  final double height = lerpDouble(closedSize, bloomSize, _controller.value)!;
                  return SizedBox(
                    width: width,
                    height: height,
                    child: child,
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Expanded Background (Bloom)
                    if (isOpen)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _bloomScale.value,
                            child: Container(
                              width: closedSize,
                              height: closedSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentColor.withValues(alpha: 0.15),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Morphing Circle (Base indicator / Background Ring)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final double size = lerpDouble(closedSize, bloomSize - (widget.style.closedRadius * 2 - 4.0), _controller.value)!;
                        
                        // Interpolate colors
                        final Color fillColor = Color.lerp(_currentColor, const Color(0xFFF5F3EF), _controller.value)!;
                        final Color borderColor = Color.lerp(Colors.white, _currentColor, _controller.value)!;
                        final double borderWidth = lerpDouble(3.0, 8.0, _controller.value)!;
                        
                        return AnimatedScale(
                          scale: _isPressed && !isOpen ? 0.88 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          child: GestureDetector(
                            onTapDown: _handlePressDown,
                            onTapUp: _handlePressUp,
                            onTapCancel: _handlePressCancel,
                            child: Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: fillColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: borderWidth,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: lerpDouble(0.08, 0.06, _controller.value)!),
                                    blurRadius: lerpDouble(8.0, 12.0, _controller.value)!,
                                    offset: Offset(0, lerpDouble(4.0, 4.0, _controller.value)!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Open State Content (Color Wheel + Slider)
                    if (isOpen)
                      FadeTransition(
                        opacity: _contentOpacity,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final double w = lerpDouble(closedSize, stackWidthOpen, _controller.value)!;
                            final double h = lerpDouble(closedSize, bloomSize, _controller.value)! + 24;
                            return _buildOpenContent(w, h, bloomSize);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              
              // Smooth slide and fade transitions for the pill
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_pillScale.value == 0.0 || !widget.style.showHexPill) {
                    return const SizedBox.shrink();
                  }
                  final double targetWidth = _isEditingText ? 200.0 : 157.0;
                  return AnimatedContainer(
                    duration: _controller.isAnimating 
                        ? Duration.zero 
                        : const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: targetWidth * _pillScale.value,
                    child: FadeTransition(
                      opacity: _pillOpacity,
                      child: OverflowBox(
                        minWidth: 0.0,
                        maxWidth: 250.0,
                        alignment: Alignment.centerLeft,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      height: closedSize,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.style.pillBackgroundColor,
                        borderRadius: BorderRadius.circular(closedSize / 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: _isEditingText ? 120 : 85,
                            child: TextField(
                              controller: _hexController,
                              focusNode: _hexFocusNode,
                              textAlignVertical: TextAlignVertical.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(7),
                                FilteringTextInputFormatter.allow(RegExp(r'[#a-fA-F0-9]')),
                              ],
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              style: widget.style.textStyle ??
                                  TextStyle(
                                    color: widget.style.pillTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                              onChanged: _handleHexChanged,
                              onSubmitted: (_) => _hexFocusNode.unfocus(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, _) {
                                  final double blur = (1.0 - animation.value) * 4.0;
                                  if (blur <= 0.05) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  }
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: blur,
                                        sigmaY: blur,
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                              );
                            },
                            child: _isEditingText
                                ? GestureDetector(
                                    key: const ValueKey('check'),
                                    onTap: () => _hexFocusNode.unfocus(),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    key: const ValueKey('edit'),
                                    onTap: () => _hexFocusNode.requestFocus(),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: widget.style.iconColor,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenContent(double width, double height, double bloomSize) {
    final double circleSize = widget.style.closedRadius * 2 - 4.0;
    
    // Distribute inner and outer rings proportionally to the configured bloom radius
    final double outerRadiusOffset = widget.style.bloomRadius * 0.48;
    final double innerRadiusOffset = widget.style.bloomRadius * 0.25;

    // Outer wheel color list
    final List<Color> defaultOuterColors = [
      const Color(0xFFF7C13F), // Yellow-orange
      const Color(0xFFF58A3F), // Orange
      const Color(0xFFEF4D3D), // Red
      const Color(0xFFE03D72), // Pink
      const Color(0xFF9E36B3), // Purple
      const Color(0xFF5D4BB8), // Violet-blue
      const Color(0xFF3B7BBF), // Blue
      const Color(0xFF38A1C5), // Sky Blue
      const Color(0xFF3BBFA7), // Turquoise
      const Color(0xFF4DBB5A), // Green
      const Color(0xFF89C63C), // Light green
      const Color(0xFFCBD63C), // Lime
    ];

    // Inner wheel color list
    final List<Color> defaultInnerColors = [
      const Color(0xFFFBE4A1), // Light Yellow
      const Color(0xFFFBCBB1), // Light Orange
      const Color(0xFFF9B8B5), // Light Red/Pink
      const Color(0xFFDCBBE7), // Light Purple
      const Color(0xFFB4CDEB), // Light Blue
      const Color(0xFFC4E8C2), // Light Green
    ];

    final List<Color> outerColors = (_wheelColors.length >= 12) 
        ? _wheelColors.sublist(0, 12)
        : defaultOuterColors;

    final List<Color> innerColors = (_wheelColors.length >= 18)
        ? _wheelColors.sublist(12, 18)
        : defaultInnerColors;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gradient Slider (Arc)
          _buildLightnessSlider(width, height),
          
          // 12 Outer Ring Colors
          ...List.generate(12, (index) {
            final double angle = (index / 12) * 2 * math.pi - math.pi / 2; // start from top
            final double dx = outerRadiusOffset * math.cos(angle);
            final double dy = outerRadiusOffset * math.sin(angle);
            final Color color = outerColors[index % outerColors.length];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double start = 0.2 + (index / 12) * 0.3;
                final double end = (start + 0.3).clamp(0.0, 1.0);
                final Animation<double> scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(start, end, curve: Curves.easeOutBack),
                  ),
                );

                return Transform.translate(
                  offset: Offset(dx * scaleAnim.value, dy * scaleAnim.value),
                  child: Transform.scale(
                    scale: scaleAnim.value,
                    child: GestureDetector(
                      onTap: () => _selectColor(color),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 6 Inner Ring Colors (lighter, pastel versions)
          ...List.generate(6, (index) {
            final double angle = (index / 6) * 2 * math.pi - math.pi / 2; // start from top
            final double dx = innerRadiusOffset * math.cos(angle);
            final double dy = innerRadiusOffset * math.sin(angle);
            final Color color = innerColors[index % innerColors.length];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double start = 0.4 + (index / 6) * 0.3;
                final double end = (start + 0.3).clamp(0.0, 1.0);
                final Animation<double> scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(start, end, curve: Curves.easeOutBack),
                  ),
                );

                return Transform.translate(
                  offset: Offset(dx * scaleAnim.value, dy * scaleAnim.value),
                  child: Transform.scale(
                    scale: scaleAnim.value,
                    child: GestureDetector(
                      onTap: () => _selectColor(color),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Center white circle to close
          GestureDetector(
            onTap: _toggleState,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightnessSlider(double width, double height) {
    final double sliderRadius = widget.style.bloomRadius + 12.0;
    final double strokeWidth = widget.style.sliderWidth;
    final double arcAngle = math.pi / 5;

    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onPanUpdate: (details) {
          _handleArcDrag(details.localPosition, width, height, sliderRadius, arcAngle);
        },
        onPanDown: (details) {
          if (widget.style.hapticFeedback) HapticFeedback.lightImpact();
          setState(() {
            _isDraggingSlider = true;
          });
          _handleArcDrag(details.localPosition, width, height, sliderRadius, arcAngle);
        },
        onPanEnd: (details) {
          setState(() {
            _isDraggingSlider = false;
          });
          _toggleState();
        },
        onPanCancel: () {
          setState(() {
            _isDraggingSlider = false;
          });
          _toggleState();
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1.0, end: _isDraggingSlider ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return CustomPaint(
              size: Size(width, height),
              painter: ArcSliderPainter(
                currentColor: _currentColor,
                lightness: _lightness,
                radius: sliderRadius,
                strokeWidth: strokeWidth,
                arcAngle: arcAngle,
                thumbScale: scale,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleArcDrag(Offset localPosition, double width, double height, double sliderRadius, double arcAngle) {
    final center = Offset(width / 2, height / 2);
    final localOffset = localPosition - center;
    double angle = math.atan2(localOffset.dy, localOffset.dx);
    
    angle = angle.clamp(-arcAngle, arcAngle);
    
    final double pct = (angle - (-arcAngle)) / (2 * arcAngle);
    final double targetLightness = (1.0 - pct).clamp(0.05, 0.95);
    
    setState(() {
      _lightness = targetLightness;
      final hsl = HSLColor.fromColor(_currentColor);
      _currentColor = hsl.withLightness(_lightness).toColor();
      _updateHexController();
    });
    widget.onColorChanged(_currentColor);
  }
}

/// A custom painter that draws the curved lightness slider.
class ArcSliderPainter extends CustomPainter {
  /// Creates a new `ArcSliderPainter`.
  ArcSliderPainter({
    required this.currentColor,
    required this.lightness,
    required this.radius,
    required this.strokeWidth,
    required this.arcAngle,
    required this.thumbScale,
  });

  /// The active color used to generate the gradient.
  final Color currentColor;

  /// The lightness factor.
  final double lightness;

  /// The radial offset of the slider.
  final double radius;

  /// The thickness of the slider arc.
  final double strokeWidth;

  /// The sweep boundary angle.
  final double arcAngle;

  /// The active scale multiplier for the thumb handle.
  final double thumbScale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-arcAngle - 0.2);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    final Rect localRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    
    final HSLColor hsl = HSLColor.fromColor(currentColor);
    final Color topColor = hsl.withLightness(0.95).toColor();
    final Color bottomColor = hsl.withLightness(0.05).toColor();
    
    final double totalSpan = 2 * arcAngle + 0.4;
    paint.shader = SweepGradient(
      colors: [topColor, currentColor, bottomColor],
      stops: [
        0.2 / totalSpan,
        (arcAngle + 0.2) / totalSpan,
        (2 * arcAngle + 0.2) / totalSpan,
      ],
      endAngle: totalSpan,
    ).createShader(localRect);
    
    canvas.drawArc(localRect, 0.2, 2 * arcAngle, false, paint);
    canvas.restore();
    
    // Draw Thumb
    final double thumbTheta = -arcAngle + (1.0 - lightness) * (2 * arcAngle);
    final Offset thumbCenter = center + Offset(radius * math.cos(thumbTheta), radius * math.sin(thumbTheta));
    final double baseRadius = strokeWidth / 2;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, (baseRadius + 4) * thumbScale, shadowPaint);
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, (baseRadius + 2) * thumbScale, borderPaint);
    
    final HSLColor thumbHsl = HSLColor.fromColor(currentColor).withLightness(lightness);
    final innerPaint = Paint()
      ..color = thumbHsl.toColor()
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, (baseRadius - 1) * thumbScale, innerPaint);
  }

  @override
  bool shouldRepaint(covariant ArcSliderPainter oldDelegate) {
    return oldDelegate.currentColor != currentColor ||
        oldDelegate.lightness != lightness ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.arcAngle != arcAngle ||
        oldDelegate.thumbScale != thumbScale;
  }
}
