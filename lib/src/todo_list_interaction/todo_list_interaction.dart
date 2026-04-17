import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'models/todo_item.dart';
import 'models/todo_category.dart';
import 'models/todo_list_style.dart';
import '../theme/portal_theme.dart';

/// A premium, interactive To-do list with a concentric "Island" design system.
/// 
/// All visual properties and physics parameters are fully customizable via [TodoListStyle].
class TodoListInteraction extends StatefulWidget {
  final List<TodoItem> items;
  final List<TodoCategory> categories;
  final String dateString;
  final TodoListStyle style;
  final void Function(List<TodoItem> items)? onChanged;

  const TodoListInteraction({
    super.key,
    required this.items,
    required this.categories,
    required this.dateString,
    this.style = const TodoListStyle(),
    this.onChanged,
  });

  @override
  State<TodoListInteraction> createState() => _TodoListInteractionState();
}

class _TodoListInteractionState extends State<TodoListInteraction> {
  late List<TodoItem> _items;
  late String _activeFilter;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _activeFilter = widget.style.filters.first;
  }

  void _handleToggle(String id) {
    setState(() {
      final index = _items.indexWhere((it) => it.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isCompleted: !_items[index].isCompleted);
        widget.onChanged?.call(_items);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: widget.style.outerBackgroundColor,
        borderRadius: BorderRadius.circular(widget.style.outerBorderRadius),
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Text(
              widget.dateString,
              style: widget.style.dateStyle ?? theme.typography.bodyMedium.copyWith(
                color: theme.colors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                fontFamily: 'Courier',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: widget.style.cardBackgroundColor,
              borderRadius: BorderRadius.circular(widget.style.cardBorderRadius),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TodoTabs(
                  activeFilter: _activeFilter,
                  onChanged: (val) => setState(() => _activeFilter = val),
                  style: widget.style,
                ),
                const SizedBox(height: 12),
                ...widget.categories.map((category) {
                  final categoryItems = _items.where((it) => it.categoryId == category.id).toList();
                  return _TodoCategoryGroup(
                    key: ValueKey('group_${category.id}'),
                    category: category,
                    items: categoryItems,
                    activeFilter: _activeFilter,
                    style: widget.style,
                    onToggle: _handleToggle,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoCategoryGroup extends StatefulWidget {
  final TodoCategory category;
  final List<TodoItem> items;
  final String activeFilter;
  final TodoListStyle style;
  final ValueChanged<String> onToggle;

  const _TodoCategoryGroup({
    super.key,
    required this.category,
    required this.items,
    required this.activeFilter,
    required this.style,
    required this.onToggle,
  });

  @override
  State<_TodoCategoryGroup> createState() => _TodoCategoryGroupState();
}

class _TodoCategoryGroupState extends State<_TodoCategoryGroup> {
  final Map<String, double> _heights = {};
  double _headerHeight = 40.0;
  
  /// Track which IDs are currently in their completion animation cycle
  final Set<String> _flyingIds = {};
  
  /// Track which IDs are horizontally displaced to the right
  final Set<String> _displacedIds = {};
  
  bool _isExpanded = true;

  Future<void> _internalToggle(String id) async {
    final itemIndex = widget.items.indexWhere((it) => it.id == id);
    if (itemIndex == -1) return;
    final item = widget.items[itemIndex];
    final sortedBefore = List<TodoItem>.from(widget.items)..sort((a,b)=>a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));
    final sortedAfter = List<TodoItem>.from(widget.items);
    final idx = sortedAfter.indexWhere((it) => it.id == id);
    sortedAfter[idx] = item.copyWith(isCompleted: !item.isCompleted);
    sortedAfter.sort((a,b)=>a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));

    final bool willMoveUp = item.isCompleted && !sortedAfter.firstWhere((it) => it.id == id).isCompleted;
    final bool willStayAtSamePosition = sortedBefore.indexOf(item) == sortedAfter.indexWhere((it) => it.id == id);

    if (willMoveUp || willStayAtSamePosition) {
      widget.onToggle(id);
      return;
    }

    setState(() { 
      _flyingIds.add(id); 
      _displacedIds.add(id); 
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) { 
      setState(() { 
        widget.onToggle(id); 
        _displacedIds.remove(id); 
      }); 
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _flyingIds.remove(id));
  }

  void _updateHeight(String key, double height) {
    if (_heights[key] != height) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _heights[key] = height); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    List<TodoItem> visibleItems = widget.items;
    
    if (widget.activeFilter == 'Completed') {
      visibleItems = widget.items.where((it) => it.isCompleted).toList();
    } else if (widget.activeFilter == 'Pending') {
      visibleItems = widget.items.where((it) => !it.isCompleted).toList();
    }

    if (visibleItems.isEmpty) return const SizedBox.shrink();
    final sortedItems = List<TodoItem>.from(visibleItems)..sort((a, b) => a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));

    double currentTop = 0;
    final double headerTop = currentTop;
    currentTop += _headerHeight;

    final Map<String, double> itemPositions = {};
    if (_isExpanded) {
      for (var item in sortedItems) {
        itemPositions[item.id] = currentTop;
        currentTop += (_heights[item.id] ?? widget.style.itemHeight);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: _TodoSpringCurve(stiffness: widget.style.springStiffness, damping: widget.style.springDamping),
      height: currentTop + 4.0,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...[
            // Non-animating items lower in stack
            ...sortedItems.where((it) => !_flyingIds.contains(it.id)),
            // Animating items higher in stack to stay on top while flying
            ...sortedItems.where((it) => _flyingIds.contains(it.id)),
          ].map((item) {
            final targetTop = itemPositions[item.id] ?? headerTop;
            final isFlying = _flyingIds.contains(item.id);
            final isDisplaced = _displacedIds.contains(item.id);
            final isItemVisible = _isExpanded && sortedItems.contains(item);
            
            return AnimatedPositioned(
              key: ValueKey('item_${item.id}'),
              duration: Duration(milliseconds: isFlying ? 900 : 800),
              curve: _TodoSpringCurve(
                stiffness: isFlying ? widget.style.springStiffness * 0.8 : widget.style.springStiffness, 
                damping: widget.style.springDamping
              ),
              top: targetTop,
              left: isDisplaced ? 20.0 : 0.0,
              right: isDisplaced ? -20.0 : 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isItemVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !isItemVisible,
                  child: _MeasureSize(
                    onSizeChange: (size) => _updateHeight(item.id, size.height),
                    child: _TodoItemTile(item: item, onToggle: () => _internalToggle(item.id), style: widget.style),
                  ),
                ),
              ),
            );
          }),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: _TodoSpringCurve(stiffness: widget.style.springStiffness, damping: widget.style.springDamping),
            top: headerTop,
            left: 0,
            right: 0,
            child: _MeasureSize(
              onSizeChange: (size) => setState(() => _headerHeight = size.height),
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      _AnimatedSpringRotation(
                        isExpanded: _isExpanded, 
                        style: widget.style,
                        child: const Icon(Icons.arrow_right_rounded, size: 28),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.category.title, 
                        style: widget.style.categoryHeaderStyle ?? theme.typography.h3.copyWith(
                          fontWeight: FontWeight.w800, 
                          fontFamily: 'Courier', 
                          fontSize: 17
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSpringRotation extends StatefulWidget {
  final bool isExpanded;
  final Widget child;
  final TodoListStyle style;
  const _AnimatedSpringRotation({required this.isExpanded, required this.child, required this.style});
  @override
  State<_AnimatedSpringRotation> createState() => _AnimatedSpringRotationState();
}

class _AnimatedSpringRotationState extends State<_AnimatedSpringRotation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0, end: 0.25).animate(CurvedAnimation(
      parent: _controller, 
      curve: _TodoSpringCurve(stiffness: widget.style.springStiffness, damping: widget.style.springDamping * 0.75)
    ));
    if (widget.isExpanded) _controller.value = 1.0;
  }
  @override
  void didUpdateWidget(covariant _AnimatedSpringRotation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) widget.isExpanded ? _controller.forward() : _controller.reverse();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return RotationTransition(turns: _animation, child: widget.child); }
}

class _TodoTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onChanged;
  final TodoListStyle style;

  const _TodoTabs({required this.activeFilter, required this.onChanged, required this.style});

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    final filters = style.filters;
    final activeIndex = filters.indexOf(activeFilter);

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: style.tabTrackColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / (filters.isEmpty ? 1 : filters.length);
          
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: _TodoSpringCurve(stiffness: style.springStiffness, damping: style.springDamping),
                left: 4 + (activeIndex * tabWidth),
                top: 4,
                bottom: 4,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: style.tabIndicatorColor,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: List.generate(filters.length, (index) {
                  final filter = filters[index];
                  final isActive = activeFilter == filter;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isActive) {
                          HapticFeedback.lightImpact();
                          onChanged(filter);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: style.tabTextStyle ?? theme.typography.bodyMedium.copyWith(
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive ? Colors.black : theme.colors.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Courier',
                            letterSpacing: -0.3,
                          ),
                          child: Text(filter, maxLines: 1),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final TodoListStyle style;
  const _TodoItemTile({required this.item, required this.onToggle, required this.style});
  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: style.itemHeight,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: item.isCompleted ? (style.checkboxActiveColor ?? theme.colors.primary) : Colors.transparent,
                  border: Border.all(color: item.isCompleted ? (style.checkboxActiveColor ?? theme.colors.primary) : (style.checkboxBorderColor ?? theme.colors.border), width: 1.0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: item.isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: style.itemTextStyle ?? theme.typography.bodyMedium.copyWith(
                    color: item.isCompleted ? theme.colors.textSecondary.withOpacity(0.6) : theme.colors.textPrimary,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: theme.colors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Courier',
                  ),
                  child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends StatefulWidget {
  final Widget child;
  final _OnSizeChange onSizeChange;
  const _MeasureSize({required this.onSizeChange, required this.child});
  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}
typedef _OnSizeChange = void Function(Size size);
class _MeasureSizeState extends State<_MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) { final RenderBox? renderBox = context.findRenderObject() as RenderBox?; if (renderBox != null && renderBox.hasSize) widget.onSizeChange(renderBox.size); } });
    return widget.child;
  }
}
class _TodoSpringCurve extends Curve {
  final SpringSimulation simulation;
  _TodoSpringCurve({double mass = 1.0, required double stiffness, required double damping}) : simulation = SpringSimulation(SpringDescription(mass: mass, stiffness: stiffness, damping: damping), 0.0, 1.0, 0.0);
  @override
  double transformInternal(double t) => simulation.x(t).clamp(-0.2, 1.2);
}
