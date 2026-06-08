import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/bloom_color_picker_style.dart';

/// The internal states of the Bloom Color Picker.
enum BloomColorPickerState {
  /// The compact state showing only the selected color and hex pill.
  closed,

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

  // Animation controller and curve for the bloom and scale effects.
  late AnimationController _controller;
  late Animation<double> _bloomProgress;
  late Animation<double> _contentOpacity;
  late Animation<double> _pillOpacity;

  // Layer link to position overlay relative to target
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Gesture state variables
  bool _isPressed = false;
  bool _isEditingText = false;
  bool _isDraggingSlider = false;

  late List<Color> _wheelColors;
  double _lightness = 0.5; // 0.0 to 1.0

  late TextEditingController _hexController;
  late FocusNode _hexFocusNode;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    
    // Setup default colors if none provided
    _wheelColors = widget.colors ?? [];

    _hexController = TextEditingController(text: _colorToHex(_currentColor));
    _hexFocusNode = FocusNode();
    _hexFocusNode.addListener(_handleFocusChange);

    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
      reverseDuration: widget.style.animationDuration,
    )..addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        setState(() {});
      } else if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    _initAnimations();
  }

  void _initAnimations() {
    // Bloom progress: normalized 0.0 to 1.0 progress for concentric growth and peeling.
    // Employs a custom BloomOvershootCurve for an organic, liquid-burst expansion.
    _bloomProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: BloomOvershootCurve()),
        reverseCurve: const Interval(0.15, 1.0, curve: Curves.easeInCubic),
      ),
    );

    // Stage 2: Content (dots + slider + center) fades in after bloom starts expanding.
    // Starts early at 0.10 and ends at 0.85 to open in unison with the bloom background.
    // On reverse (close), the content fades out in lock-step with the bloom between 1.0 and 0.15.
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.85, curve: Curves.easeOut),
        reverseCurve: const Interval(0.15, 1.0, curve: Curves.easeInCubic),
      ),
    );

    // The hex pill fades out quickly during open, and only fades back in at the very end
    // of close (below t = 0.15) when the morphing ring has completely closed to prevent overlap.
    _pillOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
        reverseCurve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(BloomColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style.animationCurve != oldWidget.style.animationCurve ||
        widget.style.bloomRadius != oldWidget.style.bloomRadius ||
        widget.style.closedRadius != oldWidget.style.closedRadius) {
      _initAnimations();
    }
    if (widget.colors != oldWidget.colors) {
      _wheelColors = widget.colors ?? [];
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    _hexFocusNode.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.dispose();
    super.dispose();
  }

  void _toggleState() {
    if (widget.style.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _state = switch (_state) {
        BloomColorPickerState.closed => BloomColorPickerState.open,
        BloomColorPickerState.open => BloomColorPickerState.closed,
      };
    });

    if (_state == BloomColorPickerState.open) {
      // Reset to the very start of the animation, then insert the overlay.
      // We must NOT call forward() yet — the CompositedTransformFollower needs
      // at least one frame to attach to the LayerLink and compute its position.
      // Calling forward() immediately causes the follower to start at (0,0)
      // then jump to the correct position mid-animation (the displacement bug).
      _controller.value = 0.0;
      _showOverlay();
      // Wait one frame for the overlay to lay out and anchor, then animate.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _state == BloomColorPickerState.open) {
          _controller.forward();
        }
      });
    } else {
      _controller.reverse();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final OverlayState overlayState = Overlay.of(context);
    final double bloomSize = widget.style.bloomRadius * 2;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap outside detector — covers the full screen.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleState,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            // Follower stays ANCHORED to the circle's center at all times.
            // The bloom expands radially from that point.
            // Near screen edges the bloom will naturally clip — this is the
            // correct behavior for a radial bloom; shifting breaks the effect.
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.center,
              followerAnchor: Alignment.center,
              child: SizedBox(
                width: bloomSize * 2,
                height: bloomSize * 2,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Expanded Background (Bloom)
                    AnimatedBuilder(
                      animation: _bloomProgress,
                      builder: (context, child) {
                        final double progress = _bloomProgress.value;
                        final double progressClamped = progress.clamp(0.0, 1.0);
                        final double blurSigma = progressClamped * 12.0; // Tighter, cleaner blur containment
                        final double bgOpacity = progressClamped * 0.92; // 92% opaque base card to prevent bleed-through
                        final double tintOpacity = progressClamped * 0.06; // Subtle color tint matching the selected color
                        final double scale = lerpDouble(0.3, 1.0, progress)!;

                        // Align background blur size to the outer ring size (radius 98.0)
                        // instead of the giant bloomSize (240.0). This makes the glow
                        // fade out perfectly right at the lightness slider.
                        final double targetOuterRadius = widget.style.bloomRadius - (widget.style.closedRadius - 2.0);
                        final double targetBgSize = targetOuterRadius * 2;

                        final surfaceColor = Theme.of(context).colorScheme.surface;

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: targetBgSize,
                            height: targetBgSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor.withValues(alpha: bgOpacity),
                              boxShadow: [
                                BoxShadow(
                                  color: _currentColor.withValues(alpha: progressClamped * 0.15),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Inner color tint layer
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentColor.withValues(alpha: tintOpacity),
                                  ),
                                ),
                                if (blurSigma > 0.1)
                                  ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Morphing Ring — the core opening animation.
                    //
                    // Starts as a fully FILLED circle matching the closed button's visual properties
                    // (color, white border, and black drop shadow). As the animation progresses:
                    //   • The outer diameter grows from closedRadius → targetOuterRadius
                    //   • The inner hole peels open concentrically from the center (0.0 radius)
                    //     using Curves.easeInCubic, ensuring it starts as a filled disc and the fill
                    //     "peels" back to reveal a thin outer ring at progress=1.0.
                    //   • The white border and initial black shadow fade out within the first 50%
                    //     of the transition, while a colored glow fades out as the ring opens.
                    AnimatedBuilder(
                      animation: _bloomProgress,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(bloomSize, bloomSize),
                          painter: MorphingRingPainter(
                            progress: _bloomProgress.value,
                            color: _currentColor,
                            closedRadius: widget.style.closedRadius,
                            targetOuterRadius: widget.style.bloomRadius - (widget.style.closedRadius - 2.0),
                            endBorderWidth: 12.0, // Wider ring thickness for a cleaner solid presence
                          ),
                        );
                      },
                    ),

                    // Open State Content (Color Wheel + Slider).
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Builder(
                        builder: (context) {
                          final double sliderRadius = widget.style.bloomRadius + 12.0;
                          final double sliderMaxHorizontal = sliderRadius + (widget.style.sliderWidth / 2) + 6.0;
                          final double w = sliderMaxHorizontal * 2;
                          final double h = bloomSize + 24.0;
                          return _buildOpenContent(w, h, bloomSize);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(_overlayEntry!);
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
          _hexController.text = _colorToHex(_currentColor);
        });
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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _selectColor(Color color, {bool shouldClose = true}) {
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
    if (shouldClose) {
      _toggleState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double closedSize = widget.style.closedRadius * 2;

    final circleWidget = SizedBox(
      width: closedSize,
      height: closedSize,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: AnimatedScale(
          // Emil: press feedback should be subtle (0.95–0.97), not dramatic.
          scale: _isPressed && _state == BloomColorPickerState.closed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTapDown: _handlePressDown,
            onTapUp: _handlePressUp,
            onTapCancel: _handlePressCancel,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentColor,
                border: Border.all(
                  color: Colors.white,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final pillWidget = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // CRITICAL: Never collapse the pill's layout space during animation.
        // Shrinking the pill width shifts the Row, which moves the circle,
        // which moves the LayerLink anchor — causing the overlay to displace.
        // Visibility(maintainSize) fades the pill visually while keeping its
        // layout footprint fixed so the circle never changes position.
        if (!widget.style.showHexPill) {
          return const SizedBox.shrink();
        }
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 157.0,
            end: _isEditingText ? 200.0 : 157.0,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, editingWidth, innerChild) {
            return SizedBox(
              width: editingWidth,
              height: closedSize,
              child: Visibility(
                visible: _pillOpacity.value > 0.0,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: FadeTransition(
                  opacity: _pillOpacity,
                  child: OverflowBox(
                    minWidth: 0.0,
                    maxWidth: 250.0,
                    minHeight: 0.0,
                    maxHeight: closedSize,
                    alignment: widget.style.alignment == BloomColorPickerAlignment.circleRight
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: innerChild,
                  ),
                ),
              ),
            );
          },
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.style.alignment == BloomColorPickerAlignment.circleLeft)
            const SizedBox(width: 16),
          Container(
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
          if (widget.style.alignment == BloomColorPickerAlignment.circleRight)
            const SizedBox(width: 16),
        ],
      ),
    );


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.style.alignment == BloomColorPickerAlignment.circleRight
            ? [pillWidget, circleWidget]
            : [circleWidget, pillWidget],
      ),
    );
  }

  Widget _buildOpenContent(double width, double height, double bloomSize) {
    final double circleSize = widget.style.closedRadius * 2 - 8.0;
    
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

    final List<Color> outerColors = _wheelColors.isNotEmpty
        ? List.generate(12, (i) => _wheelColors[i % _wheelColors.length])
        : defaultOuterColors;

    // The 6 inner colors are derived by taking every second outer color
    // and shifting its lightness up to make it a solid, faint/pastel variant.
    // This ensures they are aligned with their outer counterparts and retain
    // their solid original hue instead of using transparency (alpha).
    final List<Color> innerColors = List.generate(6, (i) {
      final Color baseColor = outerColors[i * 2];
      final HSLColor hsl = HSLColor.fromColor(baseColor);
      return hsl.withLightness((hsl.lightness + 0.25).clamp(0.1, 0.95)).toColor();
    });

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gradient Slider (Arc)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final bool isReversing = _controller.status == AnimationStatus.reverse;
              final double scale;
              final double translationProgress;
              if (isReversing) {
                // Collapse and disappear faster in reverse (completed by 0.55) to not linger on screen.
                // Use Curves.easeInCubic for a smooth closing transition.
                scale = const Interval(0.55, 1.0, curve: Curves.easeInCubic).transform(_controller.value);
                translationProgress = scale;
              } else {
                scale = const Interval(0.10, 0.85, curve: Curves.easeOutCubic).transform(_controller.value);
                translationProgress = const Interval(0.10, 0.85, curve: BloomSpringCurve()).transform(_controller.value);
              }
              final double visualScale = lerpDouble(0.85, 1.0, scale)!;
              final double sliderRadius = widget.style.bloomRadius + 12.0;
              final double translationX = (translationProgress - 1.0) * sliderRadius;

              return Opacity(
                opacity: scale,
                child: Transform.translate(
                  offset: Offset(translationX, 0.0),
                  child: Transform.scale(
                    scale: visualScale,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildLightnessSlider(width, height),
          ),

          // 12 Outer Ring Colors
          ...List.generate(12, (index) {
            final double angle = (index / 12) * 2 * math.pi - math.pi / 2; // start from top
            final double dx = outerRadiusOffset * math.cos(angle);
            final double dy = outerRadiusOffset * math.sin(angle);
            final Color color = outerColors[index % outerColors.length];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final bool isReversing = _controller.status == AnimationStatus.reverse;
                final double start = 0.10 + (index / 12) * 0.45;
                final double end = (start + 0.30).clamp(0.0, 1.0);
                final double scale;
                if (isReversing) {
                  // Shift by +0.15 for reverse transition to fit inside the [0.15, 1.0] closing window,
                  // and use Curves.easeInCubic for smooth reverse scaling.
                  final double reverseStart = start + 0.15;
                  final double reverseEnd = (end + 0.15).clamp(0.0, 1.0);
                  scale = Interval(reverseStart, reverseEnd, curve: Curves.easeInCubic).transform(_controller.value);
                } else {
                  scale = Interval(start, end, curve: Curves.easeOutCubic).transform(_controller.value);
                }

                final double opacity = scale;
                // Shrink and collapse all the way to 0.0 in sync with the shrinking background circle (_bloomProgress.value)
                final double visualScale = isReversing
                    ? scale * _bloomProgress.value
                    : lerpDouble(0.7, 1.0, scale)!;
                final double translationFactor = isReversing
                    ? scale * _bloomProgress.value
                    : lerpDouble(0.7, 1.0, scale)!;

                return Transform.translate(
                  offset: Offset(dx * translationFactor, dy * translationFactor),
                  child: Transform.scale(
                    scale: visualScale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectColor(color),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: opacity),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.30 * opacity),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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

          // 6 Inner Ring Colors
          ...List.generate(6, (index) {
            final double angle = (index / 6) * 2 * math.pi - math.pi / 2; // start from top
            final double dx = innerRadiusOffset * math.cos(angle);
            final double dy = innerRadiusOffset * math.sin(angle);
            final Color color = innerColors[index % innerColors.length];

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final bool isReversing = _controller.status == AnimationStatus.reverse;
                final double start = 0.20 + (index / 6) * 0.35;
                final double end = (start + 0.30).clamp(0.0, 1.0);
                final double scale;
                if (isReversing) {
                  // Shift by +0.15 for reverse transition to fit inside the [0.15, 1.0] closing window,
                  // and use Curves.easeInCubic for smooth reverse scaling.
                  final double reverseStart = start + 0.15;
                  final double reverseEnd = (end + 0.15).clamp(0.0, 1.0);
                  scale = Interval(reverseStart, reverseEnd, curve: Curves.easeInCubic).transform(_controller.value);
                } else {
                  scale = Interval(start, end, curve: Curves.easeOutCubic).transform(_controller.value);
                }

                final double opacity = scale;
                // Shrink and collapse all the way to 0.0 in sync with the shrinking background circle (_bloomProgress.value)
                final double visualScale = isReversing
                    ? scale * _bloomProgress.value
                    : lerpDouble(0.7, 1.0, scale)!;
                final double translationFactor = isReversing
                    ? scale * _bloomProgress.value
                    : lerpDouble(0.7, 1.0, scale)!;

                return Transform.translate(
                  offset: Offset(dx * translationFactor, dy * translationFactor),
                  child: Transform.scale(
                    scale: visualScale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectColor(color),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: opacity),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.20 * opacity),
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

          // Center close button — plain white circle. Tapping closes the picker.
          // No icon: the white disc reads as a neutral "done" target, and it's
          // always visible regardless of which color is selected.
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final bool isReversing = _controller.status == AnimationStatus.reverse;
              final double scale;
              if (isReversing) {
                // Shift by +0.15 for reverse transition to fit inside the [0.15, 1.0] closing window,
                // and use Curves.easeInCubic for smooth reverse scaling.
                scale = const Interval(0.25, 0.95, curve: Curves.easeInCubic).transform(_controller.value);
              } else {
                scale = const Interval(0.10, 0.80, curve: Curves.easeOutCubic).transform(_controller.value);
              }
              final double opacity = scale;
              final double visualScale = lerpDouble(0.7, 1.0, scale)!;

              return Transform.scale(
                scale: visualScale,
                child: GestureDetector(
                  onTap: () => _selectColor(Colors.white),
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: opacity),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10 * opacity),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLightnessSlider(double width, double height) {
    final double sliderRadius = widget.style.bloomRadius + 12.0;
    final double strokeWidth = widget.style.sliderWidth;
    final double arcAngle = math.pi / 6;

    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onPanDown: (details) {
          final center = Offset(width / 2, height / 2);
          final localOffset = details.localPosition - center;
          final double distance = localOffset.distance;
          final double angle = math.atan2(localOffset.dy, localOffset.dx);

          // Restrict gesture detection to be near the slider arc.
          // Allow 24px radial padding on each side and 0.15 radians of angular padding.
          final bool isWithinRadius = (distance - sliderRadius).abs() <= (strokeWidth / 2 + 24.0);
          final bool isWithinAngle = angle >= -arcAngle - 0.15 && angle <= arcAngle + 0.15;

          if (isWithinRadius && isWithinAngle) {
            if (widget.style.hapticFeedback) HapticFeedback.lightImpact();
            setState(() {
              _isDraggingSlider = true;
            });
            _handleArcDrag(details.localPosition, width, height, sliderRadius, arcAngle);
          }
        },
        onPanUpdate: (details) {
          if (!_isDraggingSlider) return;
          _handleArcDrag(details.localPosition, width, height, sliderRadius, arcAngle);
        },
        // Close the picker when the user finishes adjusting/selecting the lightness.
        onPanEnd: (details) {
          if (!_isDraggingSlider) return;
          setState(() {
            _isDraggingSlider = false;
          });
          _toggleState();
        },
        onPanCancel: () {
          if (!_isDraggingSlider) return;
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
    
    // Draw ambient shadow (tighter and shifted down to prevent top-tip bleed)
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    
    // Slight vertical offset for the shadow, calculated before rotation
    canvas.save();
    // Revert the rotation to apply a strict vertical offset
    canvas.rotate(arcAngle + 0.2); 
    canvas.translate(0, 3.5);
    canvas.rotate(-arcAngle - 0.2);
    canvas.drawArc(localRect, 0.2, 2 * arcAngle, false, shadowPaint);
    canvas.restore();

    canvas.drawArc(localRect, 0.2, 2 * arcAngle, false, paint);
    canvas.restore();
    
    // Draw Thumb
    final double thumbTheta = -arcAngle + (1.0 - lightness) * (2 * arcAngle);
    final Offset thumbCenter = center + Offset(radius * math.cos(thumbTheta), radius * math.sin(thumbTheta));
    final double baseRadius = strokeWidth / 2;
    
    final thumbShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, (baseRadius + 4) * thumbScale, thumbShadowPaint);
    
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



/// A custom curve that simulates a liquid burst or overshoot effect.
/// It scales up beyond 1.0 (reaching up to 1.15) during the first half of the animation,
/// and then smoothly contracts back to 1.0 at the end.
class BloomOvershootCurve extends Curve {
  /// Creates a new `BloomOvershootCurve`.
  const BloomOvershootCurve();

  @override
  double transformInternal(double t) {
    if (t < 0.55) {
      // Scale up rapidly: map 0.0 -> 0.55 to 0.0 -> 1.15
      final double x = t / 0.55;
      final double easeOutVal = 1.0 - math.pow(1.0 - x, 3).toDouble();
      return easeOutVal * 1.15;
    } else {
      // Contract and settle: map 0.55 -> 1.0 to 1.15 -> 1.0
      final double x = (t - 0.55) / 0.45;
      final double easeInOutVal = x < 0.5
          ? 4 * x * x * x
          : 1.0 - math.pow(-2 * x + 2, 3).toDouble() / 2;
      return 1.15 - (easeInOutVal * 0.15);
    }
  }
}

/// A custom spring curve based on damped harmonic motion.
/// It overshoots its target value slightly and bounces back to settle at 1.0.
class BloomSpringCurve extends Curve {
  /// Creates a new `BloomSpringCurve`.
  const BloomSpringCurve();

  @override
  double transformInternal(double t) {
    if (t >= 0.99) return 1.0;
    // Damped harmonic oscillator starting from rest (initial velocity = 0)
    // decay = 3.0, omega = 5.0
    final double raw = 1.0 - math.exp(-3.0 * t) * (math.cos(5.0 * t) + 0.6 * math.sin(5.0 * t));
    final double endVal = 1.0 - math.exp(-3.0) * (math.cos(5.0) + 0.6 * math.sin(5.0));
    return raw / endVal;
  }
}


/// A custom painter that draws a concentrically peeling colored ring.
/// Starts as a filled circle matching the closed button (with a white border and black drop shadow),
/// and opens outward with a hollow center starting from the inside.
class MorphingRingPainter extends CustomPainter {
  /// Creates a new `MorphingRingPainter`.
  MorphingRingPainter({
    required this.progress,
    required this.color,
    required this.closedRadius,
    required this.targetOuterRadius,
    required this.endBorderWidth,
  });

  /// The animation progress from 0.0 (closed) to 1.0 (open).
  final double progress;

  /// The current selected color of the picker.
  final Color color;

  /// The radius of the picker in the closed state.
  final double closedRadius;

  /// The final outer radius of the ring.
  final double targetOuterRadius;

  /// The final stroke thickness of the ring.
  final double endBorderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Calculate current outer radius (smooth linear interpolation style)
    final double outerRadius = lerpDouble(closedRadius, targetOuterRadius, progress)!;

    // 2. Calculate current inner radius (the hole size).
    // To make it "peel from the inside", the inner radius (the hole) must start at 0
    // and grow slowly at first (ease-in), then expand to its target size.
    final double innerProgress = Curves.easeInCubic.transform(progress.clamp(0.0, 1.0));
    final double targetInnerRadius = targetOuterRadius - endBorderWidth;
    final double innerRadius = lerpDouble(0.0, targetInnerRadius, innerProgress)!;

    // 3. Draw black drop shadow for initial button matching.
    // Fades out completely in the first 50% of the transition.
    if (progress < 0.5) {
      final double blackShadowOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);
      if (blackShadowOpacity > 0.01) {
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.08 * blackShadowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center + const Offset(0, 4), outerRadius, shadowPaint);
      }
    }

    // 4. Draw colored glow that radiates outward and fades.
    final double glowAlpha = lerpDouble(0.45, 0.0, progress.clamp(0.0, 1.0))!;
    if (glowAlpha > 0.01) {
      final double glowRadius = lerpDouble(20.0, 0.0, progress.clamp(0.0, 1.0))!;
      final double glowSpread = lerpDouble(6.0, 0.0, progress.clamp(0.0, 1.0))!;
      if (glowRadius > 0.1) {
        final shadowPaint = Paint()
          ..color = color.withValues(alpha: glowAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, outerRadius + glowSpread, shadowPaint);
      }
    }

    // 5. Draw the colored disc/ring
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (innerRadius <= 0.05) {
      // Solid circle
      canvas.drawCircle(center, outerRadius, paint);
    } else {
      // Hollow ring using Path.combine (difference)
      final outerPath = Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius));
      final innerPath = Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius));
      final ringPath = Path.combine(PathOperation.difference, outerPath, innerPath);
      canvas.drawPath(ringPath, paint);
    }

    // 6. Draw white border (which matches the closed button's white border).
    // Fades out completely in the first 50% of the transition.
    if (progress < 0.5) {
      final double whiteBorderOpacity = (1.0 - progress * 2.0).clamp(0.0, 1.0);
      if (whiteBorderOpacity > 0.01) {
        final whiteBorderPaint = Paint()
          ..color = Colors.white.withValues(alpha: whiteBorderOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..isAntiAlias = true;
        canvas.drawCircle(center, outerRadius - 1.5, whiteBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MorphingRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.closedRadius != closedRadius ||
        oldDelegate.targetOuterRadius != targetOuterRadius ||
        oldDelegate.endBorderWidth != endBorderWidth;
  }
}

