import 'package:flutter/material.dart';
import 'models/accordion_item.dart';
import 'models/accordion_style.dart';
import 'widgets/accordion_item_widget.dart';

export 'models/accordion_item.dart';
export 'models/accordion_style.dart';

/// A premium accordion component where collapsed items group into solid blocks
/// and "split" into individual cards when expanded.
///
/// This component provides a high-end interaction paradigm common in modern
/// OS interfaces, ensuring consistent visibility and smooth, organic animations.
class CardSplittingAccordion extends StatefulWidget {
  /// The list of items to display. Can handle any number of sections.
  final List<AccordionItem> items;

  /// Whether only one item can be expanded at a time (Accordion behavior).
  /// Defaults to true.
  final bool exclusive;

  /// The index of the item that should be expanded by default.
  final int? initialExpandedIndex;

  /// Optional custom styling for the accordion.
  final AccordionStyle style;

  /// Creates a new [CardSplittingAccordion].
  const CardSplittingAccordion({
    super.key,
    required this.items,
    this.exclusive = true,
    this.initialExpandedIndex,
    this.style = AccordionStyle.defaultStyle,
  });

  @override
  State<CardSplittingAccordion> createState() => _CardSplittingAccordionState();
}

class _CardSplittingAccordionState extends State<CardSplittingAccordion> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
  }

  void _handleTap(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final bool isExpanded = _expandedIndex == index;

        // Logical blocks: items above or below the split point
        final bool isUpperSection =
            _expandedIndex != null && index < _expandedIndex!;
        final bool isLowerSection =
            _expandedIndex != null && index > _expandedIndex!;

        // Split boundaries: These specific items trigger the physical separation
        final bool isAtEndOfUpperSection =
            _expandedIndex != null && index == _expandedIndex! - 1;
        final bool isAtStartOfLowerSection =
            _expandedIndex != null && index == _expandedIndex! + 1;

        return AccordionItemWidget(
          key: ValueKey('accordion_item_${item.title}_$index'),
          item: item,
          index: index,
          isExpanded: isExpanded,
          style: widget.style,
          isFirst: index == 0,
          isLast: index == widget.items.length - 1,
          isUpperSection: isUpperSection,
          isLowerSection: isLowerSection,
          isAtEndOfUpperSection: isAtEndOfUpperSection,
          isAtStartOfLowerSection: isAtStartOfLowerSection,
          onTap: () => _handleTap(index),
        );
      }).toList(),
    );
  }
}
