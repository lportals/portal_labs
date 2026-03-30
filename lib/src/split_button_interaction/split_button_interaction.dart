import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A controller to programmatically expand or collapse the [SplitButtonInteraction].
class SplitButtonController extends ChangeNotifier {
  bool _isExpanded = false;

  /// Whether the menu is currently expanded.
  bool get isExpanded => _isExpanded;

  /// Expands the menu programmatically.
  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  /// Collapses the menu programmatically.
  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  /// Toggles the menu state.
  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}

/// A configuration object for an individual action within the [SplitButtonInteraction].
class SplitAction {
  /// The label displayed when expanded.
  final String label;

  /// The callback when this action is triggered.
  final VoidCallback onTap;

  /// Optional icon.
  final IconData? icon;

  /// Whether the menu should close upon tapping this action. Defaults to true.
  final bool closeOnTap;

  const SplitAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.closeOnTap = true,
  });
}

/// Aesthetic styling for [SplitButtonInteraction].
class SplitButtonStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color activeBackgroundColor;
  final Color activeForegroundColor;
  final BorderRadius borderRadius;
  final Border? border;
  final double height;
  final TextStyle textStyle;

  const SplitButtonStyle({
    this.backgroundColor = const Color(0xFFE5E5EA), // iOS style gray
    this.foregroundColor = const Color(0xFF1C1C1E),
    this.activeBackgroundColor = const Color(0xFFE5E5EA),
    this.activeForegroundColor = const Color(0xFF1C1C1E),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.border,
    this.height = 44.0,
    this.textStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
  });
}

/// A premium, zero-dependency "Split Button Interaction" animation.
///
/// Features a minimal, morphing interaction where a primary button
/// transitions into a row of nested actions with a back button,
/// using smooth bounce expansion, motion blur emergence, and a tactile pop bounce.
class SplitButtonInteraction extends StatefulWidget {
  /// The initial label of the main button.
  final String initialLabel;

  /// The list of actions to display when expanded.
  final List<SplitAction> actions;

  /// Aesthetic customization including colors, shadows, and borders.
  final SplitButtonStyle style;

  /// Optional controller to programmatically expand or collapse the menu.
  final SplitButtonController? controller;

  /// Space between individual action buttons when expanded.
  final double spacing;

  const SplitButtonInteraction({
    super.key,
    required this.initialLabel,
    required this.actions,
    this.controller,
    this.spacing = 8.0,
    this.style = const SplitButtonStyle(),
  }) : assert(actions.length > 0);

  @override
  State<SplitButtonInteraction> createState() => _SplitButtonInteractionState();
}

class _SplitButtonInteractionState extends State<SplitButtonInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Premium bounce for forward (expansion), and elastic bounce for reverse (contraction)
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    // Fade-in/out intervals synchronized with the widths to minimize overlaps
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      reverseCurve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
    );

    _controller.addStatusListener((status) {
      if (mounted) {
        setState(() {
          _isExpanded = status != AnimationStatus.dismissed;
        });
      }
    });

    widget.controller?.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (widget.controller?.isExpanded == true) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(SplitButtonInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.lightImpact();
    if (widget.controller != null) {
      widget.controller!.toggle();
    } else {
      if (_controller.isCompleted) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  void _handleAction(SplitAction action) {
    HapticFeedback.mediumImpact();
    action.onTap();
    if (action.closeOnTap) {
      if (widget.controller != null) {
        widget.controller!.collapse();
      } else {
        _controller.reverse();
      }
    }
  }

  Widget _buildPillDecoration({required Widget child, bool isActive = false}) {
    return Container(
      height: widget.style.height,
      decoration: BoxDecoration(
        color: isActive
            ? widget.style.activeBackgroundColor
            : widget.style.backgroundColor,
        borderRadius: widget.style.borderRadius,
        border: widget.style.border,
      ),
      child: child,
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _toggleExpand,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: 'Collapse menu',
        child: _buildPillDecoration(
          isActive: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_controller.value == 1.0) return child!;
                  
                  final double t = _expandAnimation.value.clamp(0.0, 1.0);
                  final double blur = (1.0 - t) * 4.0;
                  final double opacity = t;

                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blur > 0 ? blur : 0.001,
                      sigmaY: blur > 0 ? blur : 0.001,
                    ),
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: widget.style.activeForegroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _toggleExpand,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: widget.initialLabel,
        child: _buildPillDecoration(
          isActive: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  // Text fade and blur to create a premium "emergence" effect
                  final double t = (1.0 - _fadeAnimation.value).clamp(0.0, 1.0);
                  final double blur = (1.0 - t) * 4.0;
                  
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blur > 0.001 ? blur : 0,
                      sigmaY: blur > 0.001 ? blur : 0,
                    ),
                    child: Opacity(
                      opacity: t,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.initialLabel,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: widget.style.textStyle.copyWith(
                    color: widget.style.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(SplitAction action) {
    return GestureDetector(
      onTap: () => _handleAction(action),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: action.label,
        child: _buildPillDecoration(
          isActive: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Retain native subpixel anti-aliasing when fully expanded
                  if (_controller.value == 1.0) {
                    return child!;
                  }

                  // Calculate smooth entrance using the main expand animation
                  final double t = _expandAnimation.value.clamp(0.0, 1.0);
                  final double blur = (1.0 - t) * 6.0;
                  final double opacity = t;

                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blur > 0 ? blur : 0.001,
                      sigmaY: blur > 0 ? blur : 0.001,
                    ),
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (action.icon != null) ...[
                      Icon(
                        action.icon,
                        size: 18,
                        color: widget.style.foregroundColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      action.label,
                      style: widget.style.textStyle.copyWith(
                        color: widget.style.foregroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The invisible back button used as a spacer to reserve horizontal space.
    final Widget spacer = ExcludeSemantics(
      child: Opacity(
        opacity: 0.0,
        child: IgnorePointer(child: _buildBackButton()),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // A clean parabolic scale pulse applied to the whole UI
          double scale = 1.0;
          final double t = _controller.value;
          if (t < 0.4) {
            final double n = t / 0.4;
            // 6% pop bounce (parabolic pulse)
            scale = 1.0 + (4 * n * (1 - n) * 0.06);
          }
          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    final factor = _expandAnimation.value < 0.0
                        ? 0.0
                        : _expandAnimation.value;
                    return Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: factor,
                      child: child,
                    );
                  },
                  child: spacer,
                ),
                ...widget.actions.map((action) {
                  return AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      final factor = _expandAnimation.value < 0.0
                          ? 0.0
                          : _expandAnimation.value;
                      return Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: factor,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.spacing),
                      child: _buildActionButton(action),
                    ),
                  );
                }),
              ],
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: IgnorePointer(
                ignoring: !_isExpanded,
                child: _buildBackButton(),
              ),
            ),
            FadeTransition(
              opacity: Tween<double>(
                begin: 1.0,
                end: 0.0,
              ).animate(_fadeAnimation),
              child: IgnorePointer(
                ignoring: _isExpanded,
                child: _buildMainButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
