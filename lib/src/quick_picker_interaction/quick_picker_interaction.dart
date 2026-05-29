import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/quick_picker_option.dart';
import 'models/quick_picker_style.dart';
import '../cinematic_text_transition/cinematic_text_transition.dart';
import '../cinematic_text_transition/models/cinematic_text_transition_style.dart';

/// A premium, high-fidelity option picker widget that expands into a segmented
/// capsule option list, utilizing cinematic text transitions, icon blur transitions,
/// and smooth rotations.
class QuickPickerInteraction extends StatefulWidget {
  /// Creates a [QuickPickerInteraction].
  const QuickPickerInteraction({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.onChanged,
    this.style = const QuickPickerStyle(),
    this.enabled = true,
  }) : assert(options.length >= 2, 'At least 2 options must be provided.');

  /// The list of options available in the picker.
  final List<QuickPickerOption> options;

  /// The initial index of the selected option.
  final int initialIndex;

  /// Callback triggered when the selected option changes.
  final ValueChanged<int>? onChanged;

  /// The visual style of the picker.
  final QuickPickerStyle style;

  /// Whether the picker is enabled for user interaction.
  final bool enabled;

  @override
  State<QuickPickerInteraction> createState() => _QuickPickerInteractionState();
}

class _QuickPickerInteractionState extends State<QuickPickerInteraction> {
  late int _selectedIndex;
  bool _isPressed = false;
  bool _isMenuOpen = false;
  double? _lastWidth;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // ── TextPainter width cache ──────────────────────────────────────────────
  // Avoids allocating a new [TextPainter] on every rebuild. The cache is
  // invalidated whenever the label or text style changes.
  String? _cachedLabel;
  TextStyle? _cachedStyle;
  double? _cachedWidth;

  /// Returns the natural rendered width of [label] for [style], caching the
  /// result so repeated calls within the same label/style pair are free.
  double _getTextWidth(String label, TextStyle style) {
    if (label == _cachedLabel && style == _cachedStyle && _cachedWidth != null) {
      return _cachedWidth!;
    }
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _cachedLabel = label;
    _cachedStyle = style;
    _cachedWidth = painter.width;
    return painter.width;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(QuickPickerInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _lastWidth = _getTextWidth(
          widget.options[_selectedIndex].label,
          widget.style.textStyle,
        );
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _handleHaptic() {
    if (widget.style.enableHaptics && widget.enabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _toggleMenu() {
    if (!widget.enabled) return;
    _handleHaptic();

    if (_isMenuOpen) {
      _hideMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    if (_overlayEntry != null) return;

    setState(() {
      _isMenuOpen = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => _QuickPickerMenu(
        options: widget.options,
        selectedIndex: _selectedIndex,
        style: widget.style,
        layerLink: _layerLink,
        // Called immediately on tap — used only for haptics so the user gets
        // instant tactile feedback without waiting for the popup to close.
        onSelect: (index) {
          if (index != _selectedIndex) _handleHaptic();
        },
        // Called AFTER the popup exit animation completes. This is the moment
        // the trigger button should begin its text / icon transition.
        onDismiss: (int? selectedIndex) {
          if (selectedIndex != null && selectedIndex != _selectedIndex) {
            setState(() {
              _lastWidth = _getTextWidth(
                widget.options[_selectedIndex].label,
                widget.style.textStyle,
              );
              _selectedIndex = selectedIndex;
            });
            widget.onChanged?.call(selectedIndex);
          }
          _removeOverlay();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  void _hideMenu() {
    if (!_isMenuOpen) return;
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.options[_selectedIndex];
    // A small +4 px buffer accounts for sub-pixel rendering variance across devices.
    final double targetWidth = _getTextWidth(selectedOption.label, widget.style.textStyle) + 4.0;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: 'Selector, currently set to ${selectedOption.label}',
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTapDown: widget.enabled
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: widget.enabled
                ? (_) => setState(() => _isPressed = false)
                : null,
            onTapCancel: widget.enabled
                ? () => setState(() => _isPressed = false)
                : null,
            onTap: widget.enabled ? _toggleMenu : null,
            child: AnimatedScale(
              scale: _isPressed ? widget.style.pressScale : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.6,
                child: AnimatedContainer(
                  duration: widget.style.animationDuration,
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: _isMenuOpen
                        ? widget.style.openBackgroundColor
                        : widget.style.backgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.style.borderRadius),
                    border: widget.style.triggerBorderColor == Colors.transparent
                        ? null
                        : Border.all(
                            color: widget.style.triggerBorderColor,
                          ),
                    boxShadow: widget.style.triggerShadowColor == Colors.transparent
                        ? null
                        : [
                            BoxShadow(
                              color: widget.style.triggerShadowColor,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: AnimatedSize(
                    duration: widget.style.animationDuration,
                    curve: Curves.easeOutCubic,
                    clipBehavior: Clip.none,
                    child: Padding(
                      padding: widget.style.padding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Blur-fade Icon Transition
                          SizedBox(
                            width: widget.style.iconSize,
                            height: widget.style.iconSize,
                            child: AnimatedSwitcher(
                              duration: widget.style.animationDuration,
                              transitionBuilder: (child, animation) {
                                final scaleAnimation = Tween<double>(
                                  begin: 0.7,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutBack,
                                  ),
                                );

                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: scaleAnimation,
                                    child: AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        final double blur =
                                            (1.0 - animation.value) *
                                            widget.style.maxIconBlur;
                                        if (blur < 0.05) return child!;
                                        return ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                            sigmaX: blur,
                                            sigmaY: blur,
                                          ),
                                          child: child,
                                        );
                                      },
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Icon(
                                selectedOption.icon,
                                key: ValueKey(selectedOption.value),
                                color: widget.style.selectedIconColor,
                                size: widget.style.iconSize,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Cinematic Text Transition (no bounce/elasticity) with smooth parallel left-aligned width morphing
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: _lastWidth ?? targetWidth,
                              end: targetWidth,
                            ),
                            duration: widget.style.animationDuration,
                            curve: Curves.easeOutCubic,
                            // Reset _lastWidth once the animation settles, so that subsequent
                            // setState calls (e.g. popup close) don't replay the width animation.
                            onEnd: () {
                              if (mounted && _lastWidth != null) {
                                setState(() => _lastWidth = null);
                              }
                            },
                            builder: (context, width, child) {
                              return SizedBox(
                                width: width,
                                height: widget.style.textStyle.fontSize != null
                                    ? widget.style.textStyle.fontSize! * 1.5
                                    : 24.0,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: 0.0,
                                    maxWidth: double.infinity,
                                    minHeight: 0.0,
                                    maxHeight: widget.style.textStyle.fontSize != null
                                        ? widget.style.textStyle.fontSize! * 1.5
                                        : 24.0,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: CinematicTextTransition(
                              key: const ValueKey('picker_cinematic_text'),
                              text: selectedOption.label,
                              style: CinematicTextTransitionStyle(
                                textStyle: widget.style.textStyle.copyWith(
                                  color: widget.style.selectedColor,
                                ),
                                enableElasticity: false,
                                duration: widget.style.animationDuration,
                                enableHaptics: false,
                                // Anchor both layers to the left edge so the entering
                                // text does not jump when the exiting layer fades out.
                                stackAlignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Rotating Chevron Arrow
                          AnimatedRotation(
                            turns: _isMenuOpen ? 0.5 : 0.0,
                            duration: widget.style.animationDuration,
                            curve: Curves.easeInOutCubic,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: widget.style.chevronColor,
                              size: widget.style.chevronSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The animated overlay menu popup displaying horizontal segmented options.
class _QuickPickerMenu extends StatefulWidget {
  const _QuickPickerMenu({
    required this.options,
    required this.selectedIndex,
    required this.style,
    required this.layerLink,
    required this.onSelect,
    required this.onDismiss,
  });

  final List<QuickPickerOption> options;
  final int selectedIndex;
  final QuickPickerStyle style;
  final LayerLink layerLink;
  /// Called immediately when the user taps an option (e.g. for haptic feedback).
  final ValueChanged<int>? onSelect;
  /// Called with the selected index after the popup exit animation completes,
  /// or `null` if the popup was dismissed without a selection change.
  final void Function(int? selectedIndex) onDismiss;

  @override
  State<_QuickPickerMenu> createState() => _QuickPickerMenuState();
}

class _QuickPickerMenuState extends State<_QuickPickerMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  late int _localSelectedIndex;
  // Cancelable timer for the popup exit delay. Stored so it can be cancelled
  // in [dispose] if the widget is removed before the timer fires.
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _localSelectedIndex = widget.selectedIndex;

    _controller = AnimationController(
      vsync: this,
      duration: widget.style.popupAnimationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(
      begin: -8.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Reverses the enter animation and then reports the [selectedIndex] (or
  /// `null` for an unselected dismiss) back to the parent via [onDismiss].
  Future<void> _handleDismiss([int? selectedIndex]) async {
    await _controller.reverse();
    widget.onDismiss(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // Determine overall popup width from style.
    // Formula: each segment + popup padding on both sides + 1 px per divider.
    final int dividerCount = widget.options.length - 1;
    final double containerWidth =
        (widget.style.popupSegmentWidth * widget.options.length) +
        widget.style.popupPadding.horizontal +
        dividerCount.toDouble();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dismiss tap target blocking interaction outside the dropdown.
          GestureDetector(
            onTap: () => _handleDismiss(), // no selection change
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),

          // Segmented Capsule Options Popover
          CompositedTransformFollower(
            link: widget.layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: widget.style.popupOffset,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: containerWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: widget.style.popupPadding,
                      decoration: BoxDecoration(
                        color: widget.style.popupBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          widget.style.borderRadius,
                        ),
                        border: Border.all(
                          color: widget.style.popupBorderColor,
                        ),
                        boxShadow: widget.style.popupShadowColor == Colors.transparent
                            ? null
                            : [
                                BoxShadow(
                                  color: widget.style.popupShadowColor,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Stack(
                        children: [
                          // Option Items Row
                          Row(
                            children: List.generate(
                              widget.options.length * 2 - 1,
                              (i) {
                                if (i.isOdd) {
                                  // Middle vertical divider line in intersection
                                  return Container(
                                    width: 1.0,
                                    height: 24,
                                    color: widget.style.popupBorderColor
                                        .withValues(alpha: 0.8),
                                  );
                                }

                                final int idx = i ~/ 2;
                                final option = widget.options[idx];
                                final isSelected = idx == _localSelectedIndex;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isSelected) return;

                                      // 1. Highlight the selected pill immediately
                                      //    so the user sees the feedback before the popup exits.
                                      setState(() {
                                        _localSelectedIndex = idx;
                                      });

                                      // 2. Fire haptics immediately via onSelect.
                                      widget.onSelect?.call(idx);

                                      // 3. Schedule popup exit. When the exit animation
                                      //    completes, _handleDismiss forwards the selected
                                      //    idx to the parent — THAT is when the trigger
                                      //    button starts its text / icon transition.
                                      _dismissTimer?.cancel();
                                      _dismissTimer = Timer(
                                        widget.style.selectionDismissDelay,
                                        () {
                                          if (mounted) _handleDismiss(idx);
                                        },
                                      );
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Option In-Place Active Segment Background (Scale & Blur-Fade)
                                        Positioned.fill(
                                          child: AnimatedSwitcher(
                                            duration:
                                                widget.style.popupAnimationDuration,
                                            transitionBuilder: (
                                              child,
                                              animation,
                                            ) {
                                              final scaleAnimation =
                                                  Tween<double>(
                                                    begin: 0.95,
                                                    end: 1.0,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  );
                                              return FadeTransition(
                                                opacity: animation,
                                                child: ScaleTransition(
                                                  scale: scaleAnimation,
                                                  child: AnimatedBuilder(
                                                    animation: animation,
                                                    builder: (context, child) {
                                                      final double blur =
                                                          (1.0 -
                                                              animation.value) *
                                                          widget
                                                              .style
                                                              .maxIconBlur;
                                                      if (blur < 0.05) {
                                                        return child!;
                                                      }
                                                      return ImageFiltered(
                                                        imageFilter:
                                                            ImageFilter.blur(
                                                              sigmaX: blur,
                                                              sigmaY: blur,
                                                            ),
                                                        child: child,
                                                      );
                                                    },
                                                    child: child,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: isSelected
                                                ? Container(
                                                    key: ValueKey(
                                                      'active_pill_$idx',
                                                    ),
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: widget
                                                          .style
                                                          .activeSegmentColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            topLeft: idx == 0
                                                                ? Radius.circular(
                                                                  widget
                                                                          .style
                                                                          .borderRadius -
                                                                      4,
                                                                )
                                                                : const Radius.circular(4.0),
                                                            bottomLeft: idx == 0
                                                                ? Radius.circular(
                                                                  widget
                                                                          .style
                                                                          .borderRadius -
                                                                      4,
                                                                )
                                                                : const Radius.circular(4.0),
                                                            topRight: idx ==
                                                                    widget
                                                                            .options
                                                                            .length -
                                                                        1
                                                                ? Radius.circular(
                                                                  widget
                                                                          .style
                                                                          .borderRadius -
                                                                      4,
                                                                )
                                                                : const Radius.circular(4.0),
                                                            bottomRight: idx ==
                                                                    widget
                                                                            .options
                                                                            .length -
                                                                        1
                                                                ? Radius.circular(
                                                                  widget
                                                                          .style
                                                                          .borderRadius -
                                                                      4,
                                                                )
                                                                : const Radius.circular(4.0),
                                                          ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ),

                                        // Option Label content Row
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                option.icon,
                                                size: widget.style.iconSize,
                                                color: isSelected
                                                    ? widget.style.selectedIconColor
                                                    : widget
                                                        .style.unselectedColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  option.label,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: widget.style.textStyle
                                                      .copyWith(
                                                        color: isSelected
                                                            ? widget
                                                                .style
                                                                .selectedColor
                                                            : widget
                                                                .style
                                                                .unselectedColor,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Beautiful Pointer triangle matching the popover capsule border and shadow
                    CustomPaint(
                      size: const Size(16, 8),
                      painter: _TrianglePointerPainter(
                        fillColor: widget.style.popupBackgroundColor,
                        borderColor: widget.style.popupBorderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw a pixel-perfect popup anchor arrow.
class _TrianglePointerPainter extends CustomPainter {
  const _TrianglePointerPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, fillPaint);

    // Draw only the sides of the triangle (not the base at the top)
    canvas.drawLine(Offset.zero, Offset(size.width / 2, size.height), borderPaint);
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width, 0), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor;
  }
}
