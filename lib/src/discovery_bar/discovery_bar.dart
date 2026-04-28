import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/discovery_bar_models.dart';

/// A premium Discovery Bar widget that uses robust morphing containers to switch 
/// between search and discovery states without layout overflows.
class DiscoveryBar extends StatefulWidget {
  /// Creates a [DiscoveryBar].
  const DiscoveryBar({
    super.key,
    required this.options,
    this.onOptionSelected,
    this.onSearchSubmitted,
    this.searchPlaceholder = 'Search',
    this.style = const DiscoveryBarStyle(),
  });

  /// The list of discovery options to display.
  final List<DiscoveryOption> options;

  /// Callback when a discovery option is selected.
  final ValueChanged<DiscoveryOption>? onOptionSelected;

  /// Callback when the search is submitted.
  final ValueChanged<String>? onSearchSubmitted;

  /// The placeholder text for the search input.
  final String searchPlaceholder;

  /// The style configuration for the discovery bar.
  final DiscoveryBarStyle style;

  @override
  State<DiscoveryBar> createState() => _DiscoveryBarState();
}

class _DiscoveryBarState extends State<DiscoveryBar> {
  bool _isSearching = true;
  int _selectedOptionIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleState() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (!_isSearching) {
      _focusNode.unfocus();
    }
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.style.height;
    final spacing = 8.0;
    final duration = widget.style.duration;
    final curve = widget.style.curve;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final circleSize = height;
        final pillWidth = (totalWidth - circleSize - spacing).clamp(circleSize, totalWidth);

        return SizedBox(
          height: height,
          width: totalWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Morphing Search Unit (Anchored Left)
              AnimatedPositioned(
                duration: duration,
                curve: curve,
                left: 0,
                top: 0,
                bottom: 0,
                width: _isSearching ? pillWidth : circleSize,
                child: _buildMorphingContainer(
                  child: _TapPulseWrapper(
                    active: !_isSearching,
                    onTap: _isSearching ? null : _toggleState,
                    fullArea: true, // Allow tapping anywhere in the circle
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: pillWidth.clamp(circleSize, totalWidth),
                        height: height,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: Colors.black, size: 24),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        final blur = (1.0 - animation.value) * 6.0;
                                        if (blur < 0.1) return child!;
                                        return ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                          child: child,
                                        );
                                      },
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isSearching 
                                    ? _buildSearchInput() 
                                    : const SizedBox.shrink(key: ValueKey('empty')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Morphing Discovery Unit (Anchored Right)
              AnimatedPositioned(
                duration: duration,
                curve: curve,
                right: 0,
                top: 0,
                bottom: 0,
                width: _isSearching ? circleSize : pillWidth,
                child: _buildMorphingContainer(
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == const ValueKey('options_selector_final');
                      
                      return FadeTransition(
                        opacity: isIncoming 
                            ? animation 
                            : CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.3)),
                        child: ScaleTransition(
                          scale: isIncoming 
                              ? Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack))
                              : animation,
                          child: child,
                        ),
                      );
                    },
                    child: _isSearching ? _buildXIconOnly() : _buildOptionsSelector(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMorphingContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      key: const ValueKey('search_input_inner'),
      padding: const EdgeInsets.only(left: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        autofocus: true,
        autocorrect: false,
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.searchPlaceholder,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3), fontSize: 16),
          border: InputBorder.none,
          isDense: true,
        ),
        onSubmitted: widget.onSearchSubmitted,
      ),
    );
  }

  Widget _buildXIconOnly() {
    return _TapPulseWrapper(
      key: const ValueKey('x_icon_pulse_container'),
      onTap: _toggleState,
      fullArea: true,
      child: const Center(
        child: Icon(Icons.close, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildOptionsSelector() {
    return LayoutBuilder(
      key: const ValueKey('options_selector_final'),
      builder: (context, constraints) {
        final optionWidth = constraints.maxWidth / widget.options.length;
        if (constraints.maxWidth < 60) return const SizedBox.shrink();

        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: const Cubic(0.175, 0.885, 0.450, 1.1),
              left: _selectedOptionIndex * optionWidth + 4,
              top: 4, bottom: 4, width: (optionWidth - 8).clamp(0.0, double.infinity),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.options[_selectedOptionIndex].activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(widget.style.height / 2),
                ),
              ),
            ),
            Row(
              children: List.generate(widget.options.length, (index) {
                final option = widget.options[index];
                final isSelected = _selectedOptionIndex == index;
                return Expanded(
                  child: Center(
                    child: _TapPulseWrapper(
                      fullArea: true,
                      onTap: () {
                        setState(() => _selectedOptionIndex = index);
                        widget.onOptionSelected?.call(option);
                        HapticFeedback.lightImpact();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(option.icon, color: isSelected ? option.activeColor : const Color(0xFF1C1C1E), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              option.label, 
                              style: TextStyle(
                                color: isSelected ? Colors.black : const Color(0xFF1C1C1E), 
                                fontSize: 16, 
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// A micro-interaction wrapper that pulses (scales up then down) when tapped.
class _TapPulseWrapper extends StatefulWidget {

  const _TapPulseWrapper({
    super.key, 
    required this.child, 
    this.onTap, 
    this.active = true,
    this.fullArea = false,
  });
  final Widget child;
  final VoidCallback? onTap;
  final bool active;
  final bool fullArea;

  @override
  State<_TapPulseWrapper> createState() => _TapPulseWrapperState();
}

class _TapPulseWrapperState extends State<_TapPulseWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.active) {
      _controller.forward(from: 0.0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active && widget.onTap == null) {
      return widget.child;
    }
    
    Widget pulseChild = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.fullArea 
          ? Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: pulseChild,
            )
          : pulseChild,
    );
  }
}
