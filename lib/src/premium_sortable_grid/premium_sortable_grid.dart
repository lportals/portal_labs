import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'models/premium_sortable_grid_style.dart';

/// A premium, zero-dependency sortable grid widget.
///
/// Features smooth animations, physical spring-like feel, and haptic feedback.
class PremiumSortableGrid<T> extends StatefulWidget {
  /// The list of items to display in the grid.
  final List<T> items;

  /// A function that builds a widget for a given item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// A function that returns a unique ID for a given item.
  final Object Function(T item) idBuilder;

  /// Called when an item is reordered.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// The style configuration for the grid.
  final PremiumSortableGridStyle style;

  /// A builder for the empty state of the grid.
  final WidgetBuilder? emptyBuilder;

  const PremiumSortableGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.idBuilder,
    required this.onReorder,
    this.style = const PremiumSortableGridStyle(),
    this.emptyBuilder,
  });


  @override
  State<PremiumSortableGrid<T>> createState() => _PremiumSortableGridState<T>();
}

class _PremiumSortableGridState<T> extends State<PremiumSortableGrid<T>> {
  Object? _draggingId;
  DateTime _lastReorderTime = DateTime(2000);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.style.animationDuration,
      child: widget.items.isEmpty
          ? SizedBox(
              key: const ValueKey('empty'),
              width: double.infinity,
              child: widget.emptyBuilder?.call(context) ?? const SizedBox.shrink(),
            )
          : LayoutBuilder(
              key: const ValueKey('grid'),
              builder: (context, constraints) {
                final double itemWidth =
                    (constraints.maxWidth - (widget.style.crossAxisCount - 1) * widget.style.spacing) /
                        widget.style.crossAxisCount;
                final double itemHeight = itemWidth / widget.style.itemAspectRatio;

                return SizedBox(
                  height: _calculateTotalHeight(itemHeight) + 40,
                  child: Stack(
                    children: [
                      ...List.generate(widget.items.length, (index) {
                        final item = widget.items[index];
                        final id = widget.idBuilder(item);
                        final isDragging = _draggingId == id;

                        return _SortableGridItem(
                          key: ValueKey(id),
                          index: index,
                          item: item,
                          itemWidth: itemWidth,
                          itemHeight: itemHeight,
                          isDragging: isDragging,
                          style: widget.style,
                          child: widget.itemBuilder(context, item),
                          idBuilder: widget.idBuilder,
                          onDragStarted: () {
                            if (widget.style.enableHaptics) {
                              HapticFeedback.lightImpact();
                            }
                            setState(() {
                              _draggingId = id;
                            });
                          },
                          onDragEnded: () {
                            setState(() {
                              _draggingId = null;
                            });
                          },
                          onDragOver: (dragId) {
                            final now = DateTime.now();
                            if (now.difference(_lastReorderTime).inMilliseconds < 150) return;

                            final oldIndex = widget.items.indexWhere((it) => widget.idBuilder(it) == dragId);
                            if (oldIndex != -1 && oldIndex != index) {
                              _lastReorderTime = now;
                              widget.onReorder(oldIndex, index);
                              if (widget.style.enableHaptics) {
                                HapticFeedback.selectionClick();
                              }
                            }
                          },
                        );
                      }),
                      ..._buildEmptySlotTargets(itemWidth, itemHeight),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _calculateTotalHeight(itemHeight),
                        bottom: 0,
                        child: DragTarget<Object>(
                          onWillAccept: (data) => data != null,
                          onMove: (details) {
                            final now = DateTime.now();
                            if (now.difference(_lastReorderTime).inMilliseconds < 150) return;

                            final oldIndex = widget.items.indexWhere((it) => widget.idBuilder(it) == details.data);
                            final targetIndex = widget.items.length - 1;
                            
                            if (oldIndex != -1 && oldIndex != targetIndex) {
                              _lastReorderTime = now;
                              widget.onReorder(oldIndex, targetIndex);
                              if (widget.style.enableHaptics) {
                                HapticFeedback.selectionClick();
                              }
                            }
                          },
                          builder: (context, _, __) => const SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _buildEmptySlotTargets(double itemWidth, double itemHeight) {
    final int itemsCount = widget.items.length;
    final int crossAxisCount = widget.style.crossAxisCount;
    final int fullRows = itemsCount ~/ crossAxisCount;
    final int itemsInLastRow = itemsCount % crossAxisCount;
    
    if (itemsInLastRow == 0) return [];

    final int emptySlots = crossAxisCount - itemsInLastRow;
    final double top = fullRows * (itemHeight + widget.style.spacing);

    return List.generate(emptySlots, (i) {
      final int col = itemsInLastRow + i;
      final double left = col * (itemWidth + widget.style.spacing);

      return Positioned(
        left: left,
        top: top,
        width: itemWidth,
        height: itemHeight,
        child: DragTarget<Object>(
          onWillAccept: (data) => data != null,
          onMove: (details) {
            final now = DateTime.now();
            if (now.difference(_lastReorderTime).inMilliseconds < 150) return;

            final oldIndex = widget.items.indexWhere((it) => widget.idBuilder(it) == details.data);
            final targetIndex = widget.items.length - 1;
            
            if (oldIndex != -1 && oldIndex != targetIndex) {
              _lastReorderTime = now;
              widget.onReorder(oldIndex, targetIndex);
              if (widget.style.enableHaptics) {
                HapticFeedback.selectionClick();
              }
            }
          },
          builder: (context, _, __) => const SizedBox.expand(),
        ),
      );
    });
  }

  double _calculateTotalHeight(double itemHeight) {
    final int rowCount = (widget.items.length / widget.style.crossAxisCount).ceil();
    if (rowCount == 0) return 0;
    return rowCount * itemHeight + (rowCount - 1) * widget.style.spacing;
  }
}

class _SortableGridItem<T> extends StatefulWidget {
  final int index;
  final T item;
  final double itemWidth;
  final double itemHeight;
  final bool isDragging;
  final PremiumSortableGridStyle style;
  final Widget child;
  final Object Function(T item) idBuilder;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(Object dragId) onDragOver;

  const _SortableGridItem({
    super.key,
    required this.index,
    required this.item,
    required this.itemWidth,
    required this.itemHeight,
    required this.isDragging,
    required this.style,
    required this.child,
    required this.idBuilder,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDragOver,
  });

  @override
  State<_SortableGridItem<T>> createState() => _SortableGridItemState<T>();
}

class _SortableGridItemState<T> extends State<_SortableGridItem<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressing = false;
  Offset? _dropOffset;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.style.pulseDuration,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: widget.style.pulseScale,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed && _isPressing) {
        _pulseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    setState(() {
      _isPressing = true;
    });
    _pulseController.forward();
  }

  void _stopPulse() {
    setState(() {
      _isPressing = false;
    });
    _pulseController.stop();
    _pulseController.reverse();
  }

  void _onDragEnd(DraggableDetails details) {
    final RenderBox? stackBox = context.findAncestorRenderObjectOfType<RenderStack>();
    if (stackBox != null) {
      final localDropOffset = stackBox.globalToLocal(details.offset);
      setState(() {
        _dropOffset = localDropOffset;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _dropOffset = null;
          });
        }
      });
    }
    
    widget.onDragEnded();
  }

  @override
  Widget build(BuildContext context) {
    final int row = widget.index ~/ widget.style.crossAxisCount;
    final int col = widget.index % widget.style.crossAxisCount;

    final double targetLeft = col * (widget.itemWidth + widget.style.spacing);
    final double targetTop = row * (widget.itemHeight + widget.style.spacing);

    final bool isFlying = _dropOffset != null;
    final double left = _dropOffset?.dx ?? targetLeft;
    final double top = _dropOffset?.dy ?? targetTop;

    return AnimatedPositioned(
      duration: isFlying ? widget.style.flybackDuration : widget.style.animationDuration,
      curve: widget.style.animationCurve,
      left: left,
      top: top,
      width: widget.itemWidth,
      height: widget.itemHeight,
      child: DragTarget<Object>(
        onWillAccept: (data) => data != null && data != widget.idBuilder(widget.item),
        onAccept: (data) => widget.onDragOver(data),
        onMove: (details) {
          if (details.data != widget.idBuilder(widget.item)) {
            widget.onDragOver(details.data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onLongPressDown: (_) => _startPulse(),
            onLongPressUp: () => _stopPulse(),
            onLongPressCancel: () => _stopPulse(),
            child: LongPressDraggable<Object>(
              data: widget.idBuilder(widget.item),
              feedback: _buildFeedback(),
              childWhenDragging: Opacity(
                opacity: widget.style.showMagneticGhost ? 0.2 : 0.0,
                child: _buildChild(),
              ),
              onDragStarted: () {
                _stopPulse();
                widget.onDragStarted();
              },
              onDraggableCanceled: (velocity, offset) =>
                  _onDragEnd(DraggableDetails(velocity: velocity, offset: offset)),
              onDragEnd: _onDragEnd,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: RepaintBoundary(child: _buildChild()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.style.borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.child,
    );
  }

  Widget _buildFeedback() {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: widget.style.dragScale,
        child: Opacity(
          opacity: widget.style.dragOpacity,
          child: Container(
            width: widget.itemWidth,
            height: widget.itemHeight,
            decoration: BoxDecoration(
              borderRadius: widget.style.borderRadius,
              boxShadow: widget.style.dragShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
