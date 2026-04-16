import 'package:flutter/material.dart';
import '../models/pinnable_item.dart';
import '../models/pinnable_list_style.dart';
import '../../theme/portal_theme.dart';

/// A premium card component for [PinnableItem]s.
class PinnableItemCard extends StatelessWidget {
  /// The item to display.
  final PinnableItem item;

  /// Callback triggered when the pin button is pressed.
  final VoidCallback onPinToggle;

  /// The visual style of the card.
  final PinnableListStyle? style;

  const PinnableItemCard({
    super.key,
    required this.item,
    required this.onPinToggle,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 74),
        decoration: BoxDecoration(
          color: style?.cardBackgroundColor ?? theme.colors.surface,
          borderRadius: style?.cardBorderRadius ?? BorderRadius.circular(20),
          border: style?.cardBorder ?? Border.all(
            color: theme.colors.border.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: style?.cardShadows ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Section
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: item.icon ?? Icon(
                  Icons.category_rounded,
                  color: theme.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Text Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: theme.typography.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.typography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Pin Button
            _PinButton(
              isPinned: item.isPinned,
              onPressed: onPinToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _PinButton extends StatefulWidget {
  final bool isPinned;
  final VoidCallback onPressed;

  const _PinButton({
    required this.isPinned,
    required this.onPressed,
  });

  @override
  State<_PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<_PinButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    final activeColor = theme.colors.primary;

    final List<BoxShadow> activeShadows = [
      BoxShadow(
        color: activeColor.withOpacity(widget.isPinned ? 0.3 : 0.0),
        blurRadius: widget.isPinned ? 8 : 0,
        offset: Offset(0, widget.isPinned ? 4 : 0),
      ),
    ];

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.isPinned ? activeColor : theme.colors.background,
            shape: BoxShape.circle,
            border: widget.isPinned 
                ? null 
                : Border.all(color: theme.colors.border, width: 1.5),
            boxShadow: activeShadows,
          ),
          child: Center(
            child: Icon(
              widget.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: 18,
              color: widget.isPinned ? Colors.white : theme.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
