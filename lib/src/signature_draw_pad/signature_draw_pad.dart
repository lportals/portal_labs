import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import 'models/signature_draw_pad_style.dart';
import 'signature_draw_pad_controller.dart';
import 'signature_draw_pad_painter.dart';

/// A premium signature drawing pad with playback animations and high-fidelity interactions.
class SignatureDrawPad extends StatefulWidget {
  /// Creates a new [SignatureDrawPad].
  const SignatureDrawPad({
    super.key,
    this.controller,
    this.style = const SignatureDrawPadStyle(),
    this.onConfirm,
    this.label = 'Draw signature',
    this.paletteColors,
    this.activeColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.viewIcon,
    this.clearIcon,
    this.undoIcon,
    this.eraserIcon,
    this.labelIcon,
    this.dottedBorderColor,
    this.paletteBorderRadius,
    this.confirmButtonText = 'Hold to confirm',
    this.successText = 'Saved!',
    this.confirmButtonColor,
  });

  /// The controller for managing signature state.
  final SignatureDrawPadController? controller;

  /// The visual style configuration.
  final SignatureDrawPadStyle style;

  /// Callback triggered when the signature is confirmed (via hold-to-confirm).
  final VoidCallback? onConfirm;

  /// The label displayed at the top of the pad.
  final String label;

  /// Optional override for the palette colors.
  final List<Color>? paletteColors;

  /// Optional override for the active color.
  final Color? activeColor;

  /// Optional override for the background color.
  final Color? backgroundColor;

  /// Optional override for the border color.
  final Color? borderColor;

  /// Optional override for the border radius.
  final BorderRadius? borderRadius;

  /// Optional override for the border width.
  final double? borderWidth;

  /// Optional override for the view icon.
  final IconData? viewIcon;

  /// Optional override for the clear icon.
  final IconData? clearIcon;

  /// Optional override for the undo icon.
  final IconData? undoIcon;

  /// Optional override for the eraser icon.
  final IconData? eraserIcon;

  /// Optional override for the label icon.
  final IconData? labelIcon;

  /// Optional override for the dotted border color.
  final Color? dottedBorderColor;

  /// Optional override for the palette border radius.
  final double? paletteBorderRadius;

  /// The text displayed on the confirm button.
  final String confirmButtonText;

  /// The text displayed on the confirm button when successful.
  final String successText;

  /// Optional override for the confirm button color.
  final Color? confirmButtonColor;

  @override
  State<SignatureDrawPad> createState() => _SignatureDrawPadState();
}

class _SignatureDrawPadState extends State<SignatureDrawPad>
    with TickerProviderStateMixin {
  late final SignatureDrawPadController _controller;

  // Animation controllers for playback sequence
  late final AnimationController _opacityController;
  late final AnimationController _playbackController;
  late final AnimationController _shimmerController;

  // Animation for clear/restart transition
  late final AnimationController _clearController;
  bool _isLocked = false;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    final initialPalette = widget.paletteColors ?? widget.style.paletteColors;
    final initialColor =
        widget.activeColor ??
        (initialPalette.isNotEmpty
            ? initialPalette.first
            : widget.style.activeColor);

    _controller =
        widget.controller ??
        SignatureDrawPadController(
          initialColor: initialColor,
          initialWidth: widget.style.strokeWidth,
          enableHaptics: widget.style.enableHaptics,
        );
    _controller.addListener(_onControllerChanged);

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _playbackController = AnimationController(
      vsync: this,
      duration: widget.style.playbackDuration,
      value: 1.0,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 0.0,
    );

    _clearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerChanged);
    }
    _opacityController.dispose();
    _playbackController.dispose();
    _shimmerController.dispose();
    _clearController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Future<void> _playSignature() async {
    if (_controller.isEmpty) return;

    if (widget.style.enableHaptics) HapticFeedback.mediumImpact();

    // 1. Fade out background
    _opacityController.animateTo(0.1, curve: Curves.easeOut);

    // 2. Animate playback
    await _playbackController.forward(from: 0.0);

    // 3. Shimmer
    await _shimmerController.forward(from: 0.0);

    // 4. Fade background back in
    _opacityController.animateTo(1.0, curve: Curves.easeIn);
    _playbackController.value = 1.0;
    _shimmerController.value = 0.0;
  }

  void _onConfirm() {
    if (widget.style.enableHaptics) HapticFeedback.mediumImpact();
    setState(() => _isConfirming = true);
  }

  void _onComplete() {
    setState(() {
      _isLocked = true;
      _isConfirming = false;
    });
    widget.onConfirm?.call();
  }

  void _unlock() {
    if (widget.style.enableHaptics) HapticFeedback.selectionClick();
    setState(() => _isLocked = false);
  }

  void _restart() {
    if (_controller.isEmpty) return;
    _clearController.reverse().then((_) {
      _controller.clear();
      _clearController.forward();
      setState(() => _isLocked = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.paletteColors ?? widget.style.paletteColors;
    final bgColor = widget.backgroundColor ?? widget.style.backgroundColor;
    final borderColor = widget.borderColor ?? widget.style.borderColor;
    final borderRadius = widget.borderRadius ?? widget.style.borderRadius;
    final borderWidth = widget.borderWidth ?? widget.style.borderWidth;

    final viewIcon = widget.viewIcon ?? widget.style.viewIcon;
    final clearIcon = widget.clearIcon ?? widget.style.clearIcon;
    final undoIcon = widget.undoIcon ?? widget.style.undoIcon;
    final eraserIcon = widget.eraserIcon ?? widget.style.eraserIcon;
    final labelIcon = widget.labelIcon ?? widget.style.labelIcon;
    final dottedColor =
        widget.dottedBorderColor ?? widget.style.dottedBorderColor;
    final paletteRadius =
        widget.paletteBorderRadius ?? widget.style.paletteBorderRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Pad Container
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      labelIcon,
                      size: 20,
                      color: widget.style.labelStyle.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.label, style: widget.style.labelStyle),
                    const Spacer(),
                    _AnimatedVisibility(
                      isVisible:
                          _controller.isNotEmpty &&
                          !_isLocked &&
                          !_isConfirming,
                      child: _HeaderAction(
                        icon: viewIcon,
                        onTap: _playSignature,
                        style: widget.style,
                      ),
                    ),
                    _AnimatedVisibility(
                      isVisible:
                          _controller.isNotEmpty &&
                          !_isLocked &&
                          !_isConfirming,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _HeaderAction(
                          icon: clearIcon,
                          onTap: _restart,
                          style: widget.style,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Drawing Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Dotted Border Frame
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DottedFramePainter(
                            color: dottedColor.withValues(
                              alpha: 0.4,
                            ), // Subtle but visible
                            borderRadius: 12,
                          ),
                        ),
                      ),
                      // Gesture Detector & Canvas
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: _isLocked,
                          child: GestureDetector(
                            onPanStart: (details) {
                              _controller.startStroke(details.localPosition);
                            },
                            onPanUpdate: (details) {
                              _controller.addPoint(details.localPosition);
                            },
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _opacityController,
                                _playbackController,
                                _shimmerController,
                                _clearController,
                              ]),
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: SignatureDrawPadPainter(
                                    strokes: _controller.strokes,
                                    opacityValue:
                                        _opacityController.value *
                                        _clearController.value,
                                    playbackValue: _playbackController.value,
                                    shimmerValue: _shimmerController.value,
                                    shimmerColor: widget.style.shimmerColor,
                                  ),
                                  size: Size.infinite,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _AnimatedVisibility(
                      isVisible:
                          _controller.isNotEmpty &&
                          !_isLocked &&
                          !_isConfirming,
                      child: _FooterAction(
                        icon: undoIcon,
                        onTap: _controller.undo,
                        style: widget.style,
                      ),
                    ),
                    _AnimatedVisibility(
                      isVisible:
                          _controller.isNotEmpty &&
                          !_isLocked &&
                          !_isConfirming,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _FooterAction(
                          icon: eraserIcon,
                          onTap: _controller.toggleEraser,
                          isActive: _controller.isEraserMode,
                          style: widget.style,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_isLocked)
                      _HeaderAction(
                        icon: Icons.edit_outlined,
                        onTap: _unlock,
                        style: widget.style,
                      )
                    else
                      _HoldToConfirmButton(
                        style: widget.style,
                        onConfirm: _onConfirm,
                        onComplete: _onComplete,
                        isEnabled: _controller.isNotEmpty,
                        text: widget.confirmButtonText,
                        successText: widget.successText,
                        color: widget.confirmButtonColor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Color Palette
        _AnimatedVisibility(
          isVisible: !_isLocked && !_isConfirming,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors.map((color) {
                final isSelected =
                    _controller.activeColor == color &&
                    !_controller.isEraserMode;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _ColorButton(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => _controller.activeColor = color,
                    style: widget.style,
                    borderRadius: paletteRadius,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    required this.style,
  });

  final IconData icon;
  final VoidCallback onTap;
  final SignatureDrawPadStyle style;

  @override
  Widget build(BuildContext context) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: style.labelStyle.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.onTap,
    required this.style,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final SignatureDrawPadStyle style;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? style.activeColor.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? style.activeColor
              : style.labelStyle.color?.withValues(
                  alpha: onTap == null ? 0.2 : 0.7,
                ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.style,
    required this.borderRadius,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final SignatureDrawPadStyle style;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _AnimatedScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            // Base physical shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            // Sophisticated elevation shadow when selected
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Selection Ring (Inner border)
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius - 4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            // Selection Check (Optional, very subtle)
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HoldToConfirmButton extends StatefulWidget {
  const _HoldToConfirmButton({
    required this.style,
    this.onConfirm,
    this.onComplete,
    this.isEnabled = true,
    required this.text,
    required this.successText,
    this.color,
  });

  final SignatureDrawPadStyle style;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final bool isEnabled;
  final String text;
  final String successText;
  final Color? color;

  @override
  State<_HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<_HoldToConfirmButton>
    with TickerProviderStateMixin {
  late final AnimationController _holdController;
  late final AnimationController _pressController;
  late final AnimationController _pulseController;
  late final AnimationController _successController;

  late final Animation<double> _pressScale;
  late final Animation<double> _pulseScale;
  late final Animation<double> _successScale;

  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const PortalSpringCurve(stiffness: 300, damping: 25),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseScale = Tween<double>(begin: 0.0, end: 0.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _successScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.1,
          end: 0.05,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60,
      ),
    ]).animate(_successController);

    _pulseController.addListener(() {
      if (_pulseController.value > 0.48 &&
          _pulseController.value < 0.52 &&
          widget.style.enableHaptics &&
          _holdController.isAnimating) {
        HapticFeedback.selectionClick();
      }
    });

    _holdController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
        if (widget.style.enableHaptics) HapticFeedback.heavyImpact();

        setState(() => _isSuccess = true);
        _successController.forward(from: 0.0);

        // Notify parent immediately so other UI elements can respond (e.g. hide buttons)
        widget.onConfirm?.call();

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          // Final completion after showing the success state
          widget.onComplete?.call();
          _holdController.reset();
          _pressController.reverse();
          _successController.reverse();
          setState(() => _isSuccess = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    _pressController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    if (!widget.isEnabled || _isSuccess) return;
    _pressController.forward();
    if (widget.style.enableHaptics) HapticFeedback.lightImpact();
  }

  void _handleRelease() {
    if (_holdController.value < 1.0) {
      _pressController.reverse();
      _holdController.reverse();
      _pulseController.stop();
      _pulseController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = widget.color ?? widget.style.confirmButtonColor;
    final activeColor = widget.style.activeColor;

    return GestureDetector(
      onLongPressDown: (_) => _handleTapDown(),
      onLongPressStart: (_) {
        if (!widget.isEnabled || _isSuccess) return;
        _holdController.forward();
        _pulseController.repeat(reverse: true);
      },
      onLongPressEnd: (_) {
        _handleRelease();
      },
      onLongPressCancel: () => _handleRelease(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressScale, _pulseScale, _successScale]),
        builder: (context, child) {
          final totalScale =
              _pressScale.value + _pulseScale.value + _successScale.value;
          return Transform.scale(scale: totalScale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isSuccess
                ? activeColor
                : (widget.isEnabled
                      ? defaultBgColor
                      : defaultBgColor.withValues(alpha: 0.5)),
            borderRadius: widget.style.confirmButtonBorderRadius,
            border: Border.all(
              color: _isSuccess
                  ? activeColor
                  : Colors.white.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: _isSuccess
                    ? activeColor.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isSuccess ? 20 : 10,
                offset: Offset(0, _isSuccess ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.style.confirmButtonBorderRadius,
            child: SizedBox(
              width: 160, // Fixed width for smoother transition
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Integrated Background Fill
                  if (!_isSuccess)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _holdController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _holdController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    activeColor.withValues(alpha: 0.15),
                                    activeColor.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Blur Crossfade Transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          // The "Emil Blur Trick": blur increases as opacity decreases
                          final blurValue = (1.0 - animation.value) * 6.0;
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: blurValue,
                              sigmaY: blurValue,
                              tileMode: TileMode.decal,
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.9, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                    ),
                                child: child,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: _isSuccess
                        ? Row(
                            key: const ValueKey('success'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.successText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            key: const ValueKey('label'),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.text,
                              style: widget.style.confirmButtonStyle.copyWith(
                                color: widget.isEnabled
                                    ? widget.style.confirmButtonStyle.color
                                    : widget.style.confirmButtonStyle.color
                                          ?.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  const _AnimatedScaleButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class _DottedFramePainter extends CustomPainter {
  const _DottedFramePainter({required this.color, required this.borderRadius});

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Draw dashed path
    const dashWidth = 5.0;
    const dashSpace = 5.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedVisibility extends StatelessWidget {
  const _AnimatedVisibility({required this.isVisible, required this.child});

  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isVisible ? 1.0 : 0.8,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        curve: Curves.easeOut,
        child: IgnorePointer(ignoring: !isVisible, child: child),
      ),
    );
  }
}
