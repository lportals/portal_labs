import 'package:flutter/material.dart';
import 'models/scrollable_subgroups_style.dart';
import 'models/scrollable_subgroups_data.dart';

/// A scrollable list widget that groups items under sticky section headers.
///
/// Each group is rendered using [SliverMainAxisGroup] with a
/// [SliverPersistentHeader] that pins to the top of the viewport as you
/// scroll through the group's items.
///
/// The widget is fully generic over [T]. The caller controls the header UI
/// via [headerBuilder], an optional prefix row via [prefixItemBuilder],
/// and each item's UI via [itemBuilder].
class ScrollableSubgroups<T> extends StatefulWidget {
  /// Creates a [ScrollableSubgroups] widget.
  const ScrollableSubgroups({
    super.key,
    required this.data,
    required this.style,
    required this.onChanged,
    required this.itemBuilder,
    this.headerBuilder,
    this.prefixItemBuilder,
    this.controller,
    this.physics,
    this.primary,
    this.shrinkWrap = false,
  });

  /// The grouped data to display.
  final List<ScrollableSubgroupsData<T>> data;

  /// Visual configuration for the sticky headers and group spacing.
  final ScrollableSubgroupsStyle style;

  /// Called with the tapped item whenever a row is selected.
  final void Function(T) onChanged;

  /// Builds the widget shown inside each row, receiving the item.
  ///
  /// The returned widget is wrapped in a [GestureDetector] internally, so
  /// there is no need to handle taps inside [itemBuilder].
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Optional builder for the sticky header of each group.
  ///
  /// Receives the [BuildContext] and the [ScrollableSubgroupsData] for that
  /// group. When omitted, the default header renders [ScrollableSubgroupsData.title]
  /// using [ScrollableSubgroupsStyle.headerTextStyle].
  final Widget Function(BuildContext context, ScrollableSubgroupsData<T> group)?
      headerBuilder;

  /// Optional builder for a non-sticky prefix row rendered once at the top of
  /// each group's item list (e.g. a column-header row).
  ///
  /// Unlike [headerBuilder], this row scrolls with the group content and is
  /// NOT pinned to the top of the viewport.
  final Widget Function(BuildContext context, ScrollableSubgroupsData<T> group)?
      prefixItemBuilder;

  /// Optional scroll controller to track or programmatically adjust scrolling.
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// Whether this is the primary scroll view associated with the parent
  /// PrimaryScrollController.
  final bool? primary;

  /// Whether the extent of the scroll view should be determined by the contents
  /// being viewed.
  final bool shrinkWrap;

  @override
  State<ScrollableSubgroups<T>> createState() => _ScrollableSubgroupsState<T>();
}

class _ScrollableSubgroupsState<T> extends State<ScrollableSubgroups<T>> {
  /// Stable keys assigned to each group's header to measure their positions.
  late List<GlobalKey> _groupKeys;

  /// Stable keys assigned to each group's last content row to track scroll clearance.
  late List<GlobalKey> _groupBottomKeys;

  /// ValueNotifiers to drive opacity updates for each group.
  late List<ValueNotifier<double>> _opacities;

  /// ValueNotifiers to drive bottom border radius animation for each header.
  late List<ValueNotifier<BorderRadius>> _headerBorderRadii;

  /// Key applied to the viewport container to calculate relative offsets.
  final GlobalKey _viewportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initKeysAndOpacities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollStates();
    });
  }

  /// Initializes keys and value notifiers for each group.
  void _initKeysAndOpacities() {
    _groupKeys = List.generate(widget.data.length, (_) => GlobalKey());
    _groupBottomKeys = List.generate(widget.data.length, (_) => GlobalKey());
    _opacities = List.generate(
      widget.data.length,
      (_) => ValueNotifier<double>(1.0),
    );
    _headerBorderRadii = List.generate(
      widget.data.length,
      (_) => ValueNotifier<BorderRadius>(
        widget.style.headerTopBorderRadius ?? BorderRadius.zero,
      ),
    );
  }

  @override
  void didUpdateWidget(ScrollableSubgroups<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.length != oldWidget.data.length) {
      for (final opacity in _opacities) {
        opacity.dispose();
      }
      for (final radius in _headerBorderRadii) {
        radius.dispose();
      }
      _initKeysAndOpacities();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollStates();
      });
    }
  }

  @override
  void dispose() {
    for (final opacity in _opacities) {
      opacity.dispose();
    }
    for (final radius in _headerBorderRadii) {
      radius.dispose();
    }
    super.dispose();
  }

  /// Calculates positions of headers and bottoms relative to the viewport,
  /// updating opacity and bottom border radius values dynamically.
  void _updateScrollStates() {
    if (!mounted) return;
    final RenderBox? viewportBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final collisionPoint = widget.style.headerHeight;
    final fadeDistance = widget.style.fadeDistance;
    final topRadius = widget.style.headerTopBorderRadius ?? BorderRadius.zero;

    for (int i = 0; i < widget.data.length; i++) {
      // 1. Calculate bottom border radius for header i
      final bottomBox =
          _groupBottomKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (bottomBox != null && bottomBox.hasSize) {
        final bottomY =
            bottomBox.localToGlobal(Offset.zero).dy + bottomBox.size.height;
        final relativeBottom =
            bottomY - (viewportTop + widget.style.headerHeight);
        final maxRadius = topRadius.topLeft.x > 0 ? topRadius.topLeft.x : 16.0;

        if (relativeBottom <= 0) {
          // All content has scrolled past the header, round bottom corners fully.
          _headerBorderRadii[i].value = topRadius.copyWith(
            bottomLeft: Radius.circular(maxRadius),
            bottomRight: Radius.circular(maxRadius),
          );
        } else if (relativeBottom < maxRadius) {
          // Smoothly transition bottom corners to rounded.
          final progress = 1.0 - (relativeBottom / maxRadius);
          final r = maxRadius * progress;
          _headerBorderRadii[i].value = topRadius.copyWith(
            bottomLeft: Radius.circular(r),
            bottomRight: Radius.circular(r),
          );
        } else {
          // Content is still fully visible below the header.
          _headerBorderRadii[i].value = topRadius;
        }
      } else {
        _headerBorderRadii[i].value = topRadius;
      }

      // 2. Calculate opacity for group i (based on next group i + 1)
      if (i < widget.data.length - 1) {
        final nextBox =
            _groupKeys[i + 1].currentContext?.findRenderObject() as RenderBox?;
        if (nextBox != null && nextBox.hasSize) {
          final nextTop = nextBox.localToGlobal(Offset.zero).dy;
          final relativeTop = nextTop - viewportTop;

          final double opacity;
          if (relativeTop >= collisionPoint) {
            opacity = 1.0;
          } else if (relativeTop <= collisionPoint - fadeDistance) {
            opacity = 0.0;
          } else {
            opacity =
                (relativeTop - (collisionPoint - fadeDistance)) / fadeDistance;
          }
          _opacities[i].value = opacity;
        } else {
          _opacities[i].value = 1.0;
        }
      }
    }

    if (_opacities.isNotEmpty) {
      _opacities.last.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateScrollStates();
        return false;
      },
      child: CustomScrollView(
        key: _viewportKey,
        controller: widget.controller,
        physics: widget.physics,
        primary: widget.primary,
        shrinkWrap: widget.shrinkWrap,
        slivers: [
          for (int i = 0; i < widget.data.length; i++)
            ValueListenableBuilder<double>(
              valueListenable: _opacities[i],
              builder: (context, opacity, child) {
                return SliverOpacity(
                  opacity: opacity,
                  sliver: child!,
                );
              },
              child: SliverMainAxisGroup(
                slivers: [
                  // Sticky group title header.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate<T>(
                      key: _groupKeys[i],
                      group: widget.data[i],
                      style: widget.style,
                      headerBuilder: widget.headerBuilder,
                      borderRadiusNotifier: _headerBorderRadii[i],
                    ),
                  ),
                  // Optional non-sticky prefix row (e.g. column headers).
                  if (widget.prefixItemBuilder != null)
                    SliverToBoxAdapter(
                      child: widget.prefixItemBuilder!(context, widget.data[i]),
                    ),
                  // Item rows.
                  SliverList.builder(
                    itemCount: widget.data[i].subGroups.length,
                    itemBuilder: (context, index) {
                      final subGroup = widget.data[i].subGroups[index];
                      Widget row = widget.itemBuilder(context, subGroup);

                      // Wrap the last item in KeyedSubtree to measure clearance.
                      if (index == widget.data[i].subGroups.length - 1) {
                        row = KeyedSubtree(
                          key: _groupBottomKeys[i],
                          child: row,
                        );
                      }

                      return GestureDetector(
                        onTap: () => widget.onChanged(subGroup),
                        behavior: HitTestBehavior.opaque,
                        child: row,
                      );
                    },
                  ),
                  // Bottom gap between groups for visual card separation.
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: widget.style.groupSpacing),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky header delegate
// ---------------------------------------------------------------------------

class _StickyHeaderDelegate<T> extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({
    this.key,
    required this.group,
    required this.style,
    this.headerBuilder,
    required this.borderRadiusNotifier,
  });

  final Key? key;
  final ScrollableSubgroupsData<T> group;
  final ScrollableSubgroupsStyle style;
  final Widget Function(BuildContext, ScrollableSubgroupsData<T>)? headerBuilder;
  final ValueNotifier<BorderRadius> borderRadiusNotifier;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final resolvedScaffoldColor = style.scaffoldBackgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;

    Widget header = Container(
      key: key,
      // We keep the container decoration completely flat/square (no borderRadius)
      // so it blocks scrolling list rows completely.
      decoration: BoxDecoration(
        color: style.headerBackgroundColor ?? Colors.white,
      ),
      alignment: Alignment.center,
      padding: style.headerPadding ??
          const EdgeInsets.symmetric(horizontal: 16),
      child: headerBuilder != null
          ? headerBuilder!(context, group)
          : Text(
              group.title,
              textAlign: TextAlign.center,
              style: style.headerTextStyle ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );

    // Dynamically apply border radius based on scroll position/clearance.
    return ValueListenableBuilder<BorderRadius>(
      valueListenable: borderRadiusNotifier,
      builder: (context, borderRadius, child) {
        if (borderRadius == BorderRadius.zero) return child!;
        return Container(
          color: resolvedScaffoldColor,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: child!,
          ),
        );
      },
      child: header,
    );
  }

  @override
  double get maxExtent => style.headerHeight;

  @override
  double get minExtent => style.headerHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate<T> oldDelegate) {
    return group.title != oldDelegate.group.title ||
        style != oldDelegate.style ||
        key != oldDelegate.key ||
        borderRadiusNotifier != oldDelegate.borderRadiusNotifier;
  }
}
