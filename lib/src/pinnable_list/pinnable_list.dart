import 'package:flutter/material.dart';
import 'models/pinnable_item.dart';
import 'models/pinnable_list_style.dart';
import 'widgets/pinnable_item_card.dart';
import '../theme/portal_theme.dart';
import '../common/portal_animations.dart';

/// Function signature for building a custom card in the [PinnableList].
typedef PinnableItemBuilder = Widget Function(
  BuildContext context,
  PinnableItem item,
  VoidCallback onToggle,
);

/// The ultimate premium pinnable list.
/// 
/// Features:
/// - **Dynamic Measurements**: No hardcoded heights. Items can have any size.
/// - **Spring "Flight" Physics**: Customizable spring motion for item displacement.
/// - **Smart Sorting**: Optional comparator to maintain order within sections.
/// - **Custom Card Builder**: Optional builder to fully customize how each item looks.
class PinnableList extends StatefulWidget {
  /// Creates a [PinnableList].
  const PinnableList({
    super.key,
    required this.items,
    this.style = const PinnableListStyle(),
    this.itemComparator,
    this.itemBuilder,
    this.onChanged,
  });

  /// The set of items to manage.
  final List<PinnableItem> items;

  /// Optional visual style.
  final PinnableListStyle style;

  /// Optional comparator to define the order of items within each section.
  final int Function(PinnableItem a, PinnableItem b)? itemComparator;

  /// Optional builder to fully customize the appearance of each card.
  /// Standard [PinnableItemCard] is used if null.
  final PinnableItemBuilder? itemBuilder;

  /// Triggered when an item's pinned state is toggled.
  final void Function(List<PinnableItem> allItems)? onChanged;

  @override
  State<PinnableList> createState() => _PinnableListState();
}

class _PinnableListState extends State<PinnableList> {
  late List<PinnableItem> _items;
  final Map<String, double> _heights = {};
  double _headerHeight = 48.0;
  String? _lastToggledId;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _togglePin(String id) {
    setState(() {
      _lastToggledId = id;
      final index = _items.indexWhere((it) => it.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isPinned: !_items[index].isPinned);
        widget.onChanged?.call(_items);
      }
    });
  }

  void _updateHeight(String id, double height) {
    if (_heights[id] != height) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _heights[id] = height);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _items.where((it) => it.isPinned).toList();
    final unpinned = _items.where((it) => !it.isPinned).toList();

    if (widget.itemComparator != null) {
      pinned.sort(widget.itemComparator);
      unpinned.sort(widget.itemComparator);
    }

    double currentTop = 0;
    
    final double pinnedHeaderTop = currentTop;
    final Map<String, double> pinnedPositions = {};
    if (pinned.isNotEmpty) {
      currentTop += _headerHeight + widget.style.headerToItemsSpacing;
      for (var item in pinned) {
        pinnedPositions[item.id] = currentTop;
        currentTop += (_heights[item.id] ?? 86.0);
      }
      currentTop += widget.style.sectionSpacing;
    }

    final double unpinnedHeaderTop = currentTop;
    final Map<String, double> unpinnedPositions = {};
    currentTop += _headerHeight + widget.style.headerToItemsSpacing;
    for (var item in unpinned) {
      unpinnedPositions[item.id] = currentTop;
      currentTop += (_heights[item.id] ?? 86.0);
    }

    final double totalHeight = currentTop + 20;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutQuart,
          height: totalHeight,
          width: constraints.maxWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _AdaptiveHeader(
                title: 'Pinned Items',
                count: pinned.length,
                style: widget.style,
                top: pinnedHeaderTop,
                visible: pinned.isNotEmpty,
                onMeasured: (h) => setState(() => _headerHeight = h),
              ),

              _AdaptiveHeader(
                title: 'All Items',
                count: unpinned.length,
                style: widget.style,
                top: unpinnedHeaderTop,
                visible: unpinned.isNotEmpty,
                onMeasured: (h) => setState(() => _headerHeight = h),
              ),

              ...[
                ..._items.where((it) => it.id != _lastToggledId),
                if (_lastToggledId != null) 
                  ..._items.where((it) => it.id == _lastToggledId),
              ].map((item) {
                final targetTop = item.isPinned 
                    ? pinnedPositions[item.id] ?? 0 
                    : unpinnedPositions[item.id] ?? 0;

                return AnimatedPositioned(
                  key: ValueKey('pos_${item.id}'),
                  duration: const Duration(milliseconds: 1100),
                  curve: PortalSpringCurve(stiffness: 140, damping: 20),
                  top: targetTop,
                  left: 0,
                  right: 0,
                  child: AnimatedScale(
                    scale: _lastToggledId == item.id ? 1.02 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    child: _MeasureSize(
                      onSizeChange: (size) => _updateHeight(item.id, size.height),
                      child: widget.itemBuilder != null
                          ? widget.itemBuilder!(context, item, () => _togglePin(item.id))
                          : PinnableItemCard(
                              item: item,
                              onPinToggle: () => _togglePin(item.id),
                              style: widget.style,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _AdaptiveHeader extends StatelessWidget {

  const _AdaptiveHeader({
    required this.title,
    required this.count,
    required this.style,
    required this.top,
    required this.visible,
    required this.onMeasured,
  });
  final String title;
  final int count;
  final PinnableListStyle style;
  final double top;
  final bool visible;
  final Function(double) onMeasured;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutQuart,
      top: top,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: visible ? 1.0 : 0.0,
        child: _MeasureSize(
          onSizeChange: (size) => onMeasured(size.height),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: style.sectionHeaderStyle ?? PortalTheme.of(context).typography.h4,
                ),
                const SizedBox(width: 8),
                if (count > 0 && style.showHeaderBadge)
                   _Badge(count: count, style: style),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {

  const _Badge({required this.count, required this.style});
  final int count;
  final PinnableListStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.badgeBackgroundColor ?? theme.colors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: style.badgeTextStyle ?? theme.typography.caption.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MeasureSize extends StatefulWidget {

  const _MeasureSize({
    required this.onSizeChange,
    required this.child,
  });
  final Widget child;
  final OnSizeChange onSizeChange;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

/// Callback triggered when a widget's size is measured.
typedef OnSizeChange = void Function(Size size);

class _MeasureSizeState extends State<_MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          widget.onSizeChange(renderBox.size);
        }
      }
    });
    return widget.child;
  }
}

