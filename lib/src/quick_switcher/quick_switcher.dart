import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/quick_switcher_option.dart';
import 'models/quick_switcher_style.dart';
import '../common/portal_animations.dart';

/// A premium, high-fidelity switch component that toggles between different
/// input modes with a pulse animation and smooth transitions.
class QuickSwitcher extends StatefulWidget {
  /// Creates a [QuickSwitcher].
  const QuickSwitcher({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.onOptionChanged,
    this.onSubmitted,
    this.style = const QuickSwitcherStyle(),
    this.controller,
  }) : assert(options.length > 0);

  /// The list of options to switch between.
  final List<QuickSwitcherOption> options;

  /// The initial index of the selected option.
  final int initialIndex;

  /// Callback when the selected option changes.
  final ValueChanged<int>? onOptionChanged;

  /// Callback when the text input is submitted.
  final ValueChanged<String>? onSubmitted;

  /// The visual style of the switcher.
  final QuickSwitcherStyle style;

  /// The controller for the text input.
  /// If provided, uses this instead of an internal controller.
  final TextEditingController? controller;

  @override
  State<QuickSwitcher> createState() => _QuickSwitcherState();
}

class _QuickSwitcherState extends State<QuickSwitcher>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late final TextEditingController _textController;
  
  late final AnimationController _pulseController;
  late final AnimationController _holdController;
  late final AnimationController _pressController;
  
  late final Animation<double> _buttonScaleAnimation;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<double> _pulseOpacityAnimation;
  late final Animation<double> _holdBreathing;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _textController = widget.controller ?? TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Toggle pop animation
    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.88).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 80,
      ),
    ]).animate(_pulseController);

    // Wave pulse effect
    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Smooth sink that triggers the menu
    _holdBreathing = Tween<double>(begin: 0.0, end: -0.02).animate(
      CurvedAnimation(
        parent: _holdController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Smooth press-down scale
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const PortalSpringCurve(stiffness: 200, damping: 30),
      ),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _successScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.08).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.08, end: 0.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60,
      ),
    ]).animate(_successController);

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleHoldComplete();
      }
    });
  }

  late final AnimationController _successController;
  late final Animation<double> _successScale;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _hideMenu();
    if (widget.controller == null) _textController.dispose();
    _pulseController.dispose();
    _holdController.dispose();
    _pressController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    _updateIndex((_currentIndex + 1) % widget.options.length);
  }

  void _updateIndex(int newIndex) {
    if (newIndex == _currentIndex) return;
    
    setState(() {
      _currentIndex = newIndex;
    });

    _pulseController.forward(from: 0.0);
    HapticFeedback.lightImpact();
    widget.onOptionChanged?.call(_currentIndex);
  }

  void _handleLongPressDown() {
    if (_overlayEntry != null) return;
    _pressController.forward();
    if (widget.style.enableHaptics) HapticFeedback.lightImpact();
  }

  void _handleLongPressStart() {
    if (_overlayEntry != null) return;
    _holdController.forward(from: 0.0);
  }

  void _handleHoldComplete() {
    // Start the rewarding success pop
    _successController.forward(from: 0.0);
    
    // Smoothly return the other states
    _holdController.reverse();
    _pressController.reverse();

    _showMenu();
    if (widget.style.enableHaptics) HapticFeedback.mediumImpact();
  }

  void _handleLongPressEnd() {
    _holdController.reverse();
    _pressController.reverse();
  }

  void _handleLongPressCancel() {
    _holdController.reverse();
    _pressController.reverse();
  }

  void _showMenu() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _QuickSwitcherMenu(
        options: widget.options,
        currentIndex: _currentIndex,
        switcherOffset: offset,
        switcherWidth: size.width,
        style: widget.style,
        onSelect: (index) {
          _updateIndex(index);
          _hideMenu();
        },
        onDismiss: _hideMenu,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final currentOption = widget.options[_currentIndex];

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
      ),
      padding: widget.style.padding,
      child: Row(
        children: [
          // Switch Button with Pulse and Blur Transition
          SizedBox(
            child: GestureDetector(
              onTap: _handleToggle,
              onLongPressDown: (_) => _handleLongPressDown(),
              onLongPressStart: (_) => _handleLongPressStart(),
              onLongPressEnd: (_) => _handleLongPressEnd(),
              onLongPressCancel: () => _handleLongPressCancel(),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // STATIC SHADOW ANCHOR (Independent of scale)
                  Container(
                    width: 52,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.style.borderRadius - 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // Pulse Effect
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScaleAnimation.value,
                        child: Container(
                          width: 60,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.style.pulseColor
                                .withValues(alpha: _pulseOpacityAnimation.value),
                            borderRadius: BorderRadius.circular(widget.style.borderRadius),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Main Pill Button
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _buttonScaleAnimation,
                      _pressScale,
                      _holdBreathing,
                      _successScale,
                    ]),
                    builder: (context, child) {
                      final totalScale = (_buttonScaleAnimation.value * _pressScale.value) 
                          + _holdBreathing.value 
                          + _successScale.value;
                      return Transform.scale(
                        scale: totalScale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.style.switchButtonColor,
                        borderRadius: BorderRadius.circular(widget.style.borderRadius - 4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Icon with Blur Fade
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    final sigma = (1.0 - animation.value) * 1.5;
                                    if (sigma < 0.05) return child!;
                                    return ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                                      child: child,
                                    );
                                  },
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              currentOption.icon,
                              key: ValueKey('icon_$_currentIndex'),
                              color: widget.style.foregroundColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Dual Chevrons
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 7),
                                child: Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: widget.style.foregroundColor.withValues(alpha: 0.3),
                                  size: 22,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -7),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: widget.style.foregroundColor.withValues(alpha: 0.3),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Input field with Animated Hint (Blur Fade)
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) return const SizedBox.shrink();
                      
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final sigma = (1.0 - animation.value) * 1.5;
                                if (sigma < 0.1) return child!;
                                return ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                                  child: child,
                                );
                              },
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          currentOption.placeholder,
                          key: ValueKey('hint_$_currentIndex'),
                          style: TextStyle(
                            color: widget.style.foregroundColor.withValues(alpha: 0.4),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  TextField(
                    controller: _textController,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: widget.style.foregroundColor,
                    style: TextStyle(
                      color: widget.style.foregroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Stronger weight for typed input
                    ),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          SizedBox(
            child: GestureDetector(
              onTap: () => widget.onSubmitted?.call(_textController.text),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // STATIC SHADOW ANCHOR
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.style.switchButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.style.foregroundColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A glassmorphic dropdown menu that appears above the QuickSwitcher.
class _QuickSwitcherMenu extends StatefulWidget {

  const _QuickSwitcherMenu({
    required this.options,
    required this.currentIndex,
    required this.switcherOffset,
    required this.switcherWidth,
    required this.style,
    required this.onSelect,
    required this.onDismiss,
  });
  final List<QuickSwitcherOption> options;
  final int currentIndex;
  final Offset switcherOffset;
  final double switcherWidth;
  final QuickSwitcherStyle style;
  final ValueChanged<int> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_QuickSwitcherMenu> createState() => _QuickSwitcherMenuState();
}

class _QuickSwitcherMenuState extends State<_QuickSwitcherMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Required to stop the yellow underline
      child: Stack(
        children: [
        // Transparent Dismiss Layer
        GestureDetector(
          onTap: _handleDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),

        // Menu Container
        Positioned(
          left: widget.switcherOffset.dx,
          bottom: MediaQuery.of(context).size.height - widget.switcherOffset.dy + 8,
          width: widget.switcherWidth,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(widget.style.borderRadius),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.style.borderRadius),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = index == widget.currentIndex;

                          return GestureDetector(
                            onTap: () => widget.onSelect(index),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                                decoration: BoxDecoration(
                                  border: index != widget.options.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            width: 0.5,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 20,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.black.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.placeholder,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.black.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                  ],
                                ),
                              ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
   );
  }
}
