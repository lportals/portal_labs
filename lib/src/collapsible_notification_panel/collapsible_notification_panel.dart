import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'models/notification_item.dart';
import 'models/panel_style.dart';
import 'widgets/notification_tile.dart';
import 'widgets/panel_header.dart';


/// A premium notification panel that can be collapsed and expanded with spring physics.
class CollapsibleNotificationPanel extends StatefulWidget {

  /// Creates a [CollapsibleNotificationPanel].
  const CollapsibleNotificationPanel({
    super.key,
    required this.items,
    this.collapsedSubtitle = "What's happening around you",
    this.headerIcon,
    this.initiallyExpanded = false,
    this.style = const CollapsibleNotificationPanelStyle(),
    this.spring = const SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 15,
    ),
    this.onExpansionChanged,
    this.onItemTap,
  });
  /// The list of notifications to display.
  final List<NotificationItem> items;

  /// The subtitle to display when collapsed.
  final String collapsedSubtitle;

  /// Custom icon for the header.
  final IconData? headerIcon;

  /// Whether the panel is initially expanded.
  final bool initiallyExpanded;

  /// Configuration for the visual style.
  final CollapsibleNotificationPanelStyle style;

  /// Physics for the expansion animation.
  final SpringDescription spring;

  /// Callback when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Callback when a notification item is tapped.
  final ValueChanged<NotificationItem>? onItemTap;

  @override
  State<CollapsibleNotificationPanel> createState() => _CollapsibleNotificationPanelState();
}

class _CollapsibleNotificationPanelState extends State<CollapsibleNotificationPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    final SpringSimulation simulation = SpringSimulation(
      widget.spring,
      _controller.value,
      _isExpanded ? 1.0 : 0.0,
      0,
    );

    _controller.animateWith(simulation);
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: BorderRadius.circular(widget.style.borderRadius),
            boxShadow: widget.style.boxShadow ?? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.style.borderRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PanelHeader(
                  notificationCount: widget.items.length,
                  subtitle: widget.collapsedSubtitle,
                  isExpanded: _isExpanded,
                  icon: widget.headerIcon,
                  style: widget.style,
                  expansionAnimation: _controller.view,
                  onToggle: _toggleExpansion,
                ),
                _buildItemsList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _controller.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Divider(
            height: 1, 
            indent: widget.style.tilePadding.left, 
            endIndent: widget.style.tilePadding.right, 
            color: widget.style.dividerColor,
          ),
          const SizedBox(height: 8),
          ...List.generate(widget.items.length, (index) {
            return _buildStaggeredItem(index);
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStaggeredItem(int index) {
    // Each item has a slightly different entrance timing
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate a local animation value for this specific item
        // Stagger logic: delay entrance based on index
        final double staggerDelay = index * 0.1;
        final double itemValue = (_controller.value - staggerDelay).clamp(0.0, 1.0) / (1.0 - staggerDelay);
        
        // Use a curve to make the individual item entrance more punchy
        final double t = Curves.easeOutQuart.transform(itemValue);

        return NotificationTile(
          item: widget.items[index],
          style: widget.style,
          onTap: () => widget.onItemTap?.call(widget.items[index]),
          opacity: t,
          yOffset: (1.0 - t) * 20.0, // Slide up effect
        );
      },
    );
  }
}
