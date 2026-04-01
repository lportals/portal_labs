import 'package:flutter/material.dart';
import 'models/card_stack_item.dart';
import 'models/card_stack_style.dart';

/// A premium, interactive card stack that expands and collapses with a smooth transition.
///
/// This widget displays a chronological list of cards. In its collapsed state,
/// it shows the most recent card with a stacked visual hint of the items underneath.
/// Upon interaction, it expands to reveal the full list of up to three items.
class CardStackInteraction extends StatefulWidget {

  /// Creates a [CardStackInteraction] with the given [items] and optional [style].
  const CardStackInteraction({
    super.key,
    required this.items,
    this.style = const CardStackStyle(),
    this.onExpansionChanged,
  });
  /// The list of items to display in the stack.
  /// Max 3 items are shown according to design constraints.
  final List<CardStackItem> items;

  /// Optional style configuration for the interaction.
  final CardStackStyle style;

  /// Callback triggered when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<CardStackInteraction> createState() => _CardStackInteractionState();
}

class _CardStackInteractionState extends State<CardStackInteraction>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Layout properties are now derived from widget.style

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    // Current design is optimized for a maximum of 3 items in the stack.
    final displayItems = widget.items.take(3).toList();
    final middleIndex = (displayItems.length - 1) / 2.0;

    // Calculate heights for the layout
    final expandedHeight =
        (displayItems.length * widget.style.cardHeight) +
        ((displayItems.length - 1) * widget.style.cardSpacing);
    final collapsedHeight =
        widget.style.cardHeight +
        (displayItems.length > 1
            ? (displayItems.length - 1) * widget.style.collapsedOffset * 2
            : 0);

    final currentHeight = _isExpanded ? expandedHeight : collapsedHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          height: currentHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: List.generate(displayItems.length, (index) {
              return _buildAnimatedCard(
                item: displayItems[index],
                index: index,
                middleIndex: middleIndex,
                totalItems: displayItems.length,
                containerHeight: currentHeight,
              );
            }).reversed.toList(),
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildAnimatedCard({
    required CardStackItem item,
    required int index,
    required double middleIndex,
    required int totalItems,
    required double containerHeight,
  }) {
    // Calculate position relative to the middle
    double top = 0;
    double scale = 1.0;
    double opacity = 1.0;

    final centerY = containerHeight / 2 - widget.style.cardHeight / 2;
    const int visibleLimit = 3;

    if (_isExpanded) {
      // All items expanded symmetrically
      top =
          centerY +
          (index - middleIndex) *
              (widget.style.cardHeight + widget.style.cardSpacing);
      scale = 1.0;
    } else {
      if (index < visibleLimit) {
        // First 3 items stacked symmetrically
        top = centerY + (index - middleIndex) * widget.style.collapsedOffset;
        scale = 0.95 - (index * widget.style.collapsedScaleDelta);
      } else {
        // Items beyond 3 hide behind the last visible card (index 2)
        final lastVisibleIndex = visibleLimit - 1;
        top =
            centerY +
            (lastVisibleIndex - middleIndex) * widget.style.collapsedOffset;
        scale = 0.95 - (lastVisibleIndex * widget.style.collapsedScaleDelta);
      }
    }

    // Always opaque to avoid "fade" look; they hide behind each other by position/order
    opacity = 1.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      top: top,
      left: 0,
      right: 0,
      height: widget.style.cardHeight,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        scale: scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
          opacity: opacity,
          child: _CardItem(item: item, style: widget.style),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.style.buttonBackgroundColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                'Show All',
                style: TextStyle(
                  color: widget.style.buttonTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              secondChild: Text(
                'Hide',
                style: TextStyle(
                  color: widget.style.buttonTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: widget.style.buttonTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardItem extends StatelessWidget {

  const _CardItem({required this.item, required this.style});
  final CardStackItem item;
  final CardStackStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: style.cardBackgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: [
          BoxShadow(
            color: style.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.iconBackgroundColor ?? style.iconContainerColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: style.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: style.titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: style.subtitleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.date,
            style: TextStyle(
              color: style.dateColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
