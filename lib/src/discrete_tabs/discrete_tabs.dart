import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/discrete_tab.dart';
import 'models/discrete_tabs_style.dart';
import 'shimmer_text.dart';

/// A premium, zero-dependency "Discrete Tabs" navigation widget.
///
/// Features a minimal, expanding interaction where each tab item
/// transitions from a simple icon to a detailed pill with text
/// through a smooth bounce animation.
class DiscreteTabs extends StatefulWidget {
  /// The list of tabs to display.
  final List<DiscreteTab> tabs;

  /// Callback when a tab is selected.
  final ValueChanged<int>? onSelect;

  /// Externally controlled index. If provided, the widget becomes controlled.
  final int? currentIndex;

  /// The initially selected tab index (used when [currentIndex] is null).
  final int initialIndex;

  /// Space between individual tabs.
  final double spacing;

  /// Aesthetic customization including colors, shadows, and borders.
  final DiscreteTabsStyle style;

  const DiscreteTabs({
    super.key,
    required this.tabs,
    this.onSelect,
    this.currentIndex,
    this.initialIndex = 0,
    this.spacing = 10.0,
    this.style = const DiscreteTabsStyle(),
  }) : assert(tabs.length > 0);

  @override
  State<DiscreteTabs> createState() => _DiscreteTabsState();
}

class _DiscreteTabsState extends State<DiscreteTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex ?? widget.initialIndex;
  }

  @override
  void didUpdateWidget(DiscreteTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != null && widget.currentIndex != _selectedIndex) {
      _selectedIndex = widget.currentIndex!;
    }
  }

  void _handleTabSelect(int index) {
    if (_selectedIndex == index) return;

    // Aesthetic haptic feedback
    HapticFeedback.lightImpact();

    if (widget.currentIndex == null) {
      setState(() {
        _selectedIndex = index;
      });
    }

    widget.onSelect?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.tabs.length, (index) {
        final isSelected = _selectedIndex == index;
        final tab = widget.tabs[index];

        return Padding(
          padding: EdgeInsets.only(
            right: index == widget.tabs.length - 1 ? 0 : widget.spacing,
          ),
          child: _DiscreteTabItem(
            tab: tab,
            isSelected: isSelected,
            style: widget.style,
            onTap: () => _handleTabSelect(index),
          ),
        );
      }),
    );
  }
}

class _DiscreteTabItem extends StatelessWidget {
  final DiscreteTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final DiscreteTabsStyle style;

  const _DiscreteTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the size: Circle (isActive=false) vs Pill (isActive=true)
    // We use a flexible width based on the content
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack, // Aesthetic bounce
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (style.activeBackgroundColor ?? style.backgroundColor)
              : style.backgroundColor,
          borderRadius: style.borderRadius,
          border: style.border,
          boxShadow: [
            BoxShadow(
              color: style.shadowColor,
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 24,
              color: isSelected ? tab.activeColor : style.inactiveIconColor,
            ),

            // Text expands with clipping and fade logic
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                alignment: Alignment.centerLeft,
                child: !isSelected
                    ? const SizedBox.shrink()
                    : TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(-10 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ShimmerText(
                            text: tab.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: tab.activeColor,
                            ),
                            baseColor: tab.activeColor,
                            highlightColor:
                                Color.lerp(
                                  tab.activeColor,
                                  Colors.white,
                                  0.8, // Subtle highlight
                                ) ??
                                Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
