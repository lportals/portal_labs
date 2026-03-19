import 'package:flutter/material.dart';
import '../common/portal_utils.dart';
import 'models/journal_item.dart';
import 'models/journal_style.dart';
import '../common/premium_flip_counter.dart';

/// A premium, aesthetic journal navigation component that displays daily entries.
///
/// Features a vertical date slider on the left and a content area on the right.
/// Includes smooth animations, 3D flip counter for the date, and magnetic snapping physics.
///
/// Example usage:
/// ```dart
/// JournalNavigation(
///   items: journalItems,
///   initialDate: DateTime.now(),
///   onDateChanged: (item) => print("Selected: ${item.title}"),
///   style: JournalStyle.portalLabs(),
/// )
/// ```
class JournalNavigation extends StatefulWidget {
  /// The list of items to display.
  final List<JournalItem> items;

  /// The initial date to select. If not found in [items], it defaults to the first item.
  final DateTime? initialDate;

  /// Callback when the selected item changes.
  final ValueChanged<JournalItem>? onDateChanged;

  /// Style configuration for colors, dimensions, and typography.
  final JournalStyle style;

  /// Total height of the component.
  final double height;

  const JournalNavigation({
    super.key,
    required this.items,
    this.initialDate,
    this.onDateChanged,
    this.style = const JournalStyle(),
    this.height = 340.0,
  });

  @override
  State<JournalNavigation> createState() => _JournalNavigationState();
}

class _JournalNavigationState extends State<JournalNavigation> {
  late int _selectedIndex;
  late int _prevIndex;
  late final ScrollController _scrollController;
  
  /// Flag to prevent recursion between human interaction and programmatic scroll.
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getInitialIndex();
    _prevIndex = _selectedIndex;
    _scrollController = ScrollController();
    
    _scrollController.addListener(_onScroll);

    // Initial scroll position to center the current date.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animated: false);
    });
  }

  /// Listen to scroll events to update selected index based on center position.
  void _onScroll() {
    if (_isAutoScrolling) return;

    final double offset = _scrollController.offset;
    // Each date item has a height of 46px.
    final int newIndex = (offset / 46.0).round();

    if (newIndex >= 0 && newIndex < widget.items.length && newIndex != _selectedIndex) {
      if (mounted) {
        setState(() {
          _prevIndex = _selectedIndex;
          _selectedIndex = newIndex;
        });
      }
      widget.onDateChanged?.call(widget.items[newIndex]);
    }
  }

  /// Find index of the [initialDate] in the [items] list.
  int _getInitialIndex() {
    if (widget.initialDate == null) return 0;
    final index = widget.items.indexWhere((item) => 
      item.date.year == widget.initialDate!.year &&
      item.date.month == widget.initialDate!.month &&
      item.date.day == widget.initialDate!.day);
    return index != -1 ? index : 0;
  }

  /// Programmatically scroll to the active index with snapping logic.
  Future<void> _scrollToSelected({bool animated = true}) async {
    if (!_scrollController.hasClients) return;

    final double targetOffset = _selectedIndex * 46.0;
    
    // GUARD: Avoid redundant animations leading to Stack Overflow loops.
    if ((_scrollController.offset - targetOffset).abs() < 0.5) return;

    _isAutoScrolling = true;
    if (animated) {
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
    
    // Short grace period to settle events before re-enabling listener.
    await Future.delayed(const Duration(milliseconds: 50));
    _isAutoScrolling = false;
  }

  /// Explicitly select a date (via tap or arrows).
  void _selectIndex(int index) {
    if (index < 0 || index >= widget.items.length || index == _selectedIndex) return;
    if (mounted) {
      setState(() {
        _prevIndex = _selectedIndex;
        _selectedIndex = index;
      });
    }
    _scrollToSelected();
    widget.onDateChanged?.call(widget.items[index]);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final selectedItem = widget.items[_selectedIndex];
    
    // Manual date formatting using central PortalUtils
    final String monthString = PortalUtils.formatMonthShort(selectedItem.date.month);

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: style.shadows ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: Row(
          children: [
            // Left Date Slider (Vertical Pill scroller)
            _DateSlider(
              style: style,
              items: widget.items,
              selectedIndex: _selectedIndex,
              scrollController: _scrollController,
              onSelect: _selectIndex,
              onScrollEnd: () {
                // Snap effect when user finishes scrolling.
                _scrollToSelected();
              },
            ),

            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Date and Arrows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "$monthString ",
                              style: style.headerMonthStyle,
                            ),
                            PremiumFlipCounter(
                              value: selectedItem.date.day,
                              upward: _selectedIndex > _prevIndex,
                              style: style.headerDayStyle,
                            ),
                          ],
                        ),
                        _NavigationArrows(
                          style: style,
                          onPrevious: _selectedIndex > 0
                              ? () => _selectIndex(_selectedIndex - 1)
                              : null,
                          onNext: _selectedIndex < widget.items.length - 1
                              ? () => _selectIndex(_selectedIndex + 1)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Journal Content with Entry Animation
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_selectedIndex),
                          child: selectedItem.child ?? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedItem.title.isNotEmpty) ...[
                                Text(
                                  selectedItem.title,
                                  style: style.titleStyle,
                                ),
                                const SizedBox(height: 24),
                              ],
                              if (selectedItem.content.isNotEmpty)
                                Text(
                                  selectedItem.content,
                                  style: style.contentStyle,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private helper widget for the vertical date slider.
class _DateSlider extends StatelessWidget {
  final JournalStyle style;
  final List<JournalItem> items;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;
  final VoidCallback onScrollEnd;

  const _DateSlider({
    required this.style,
    required this.items,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSelect,
    required this.onScrollEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.sliderWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: style.sliderColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: Stack(
          children: [
            // The scroller
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  onScrollEnd();
                }
                return false;
              },
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 135), // Centering factor
                itemCount: items.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  // Manual padding to avoid 'intl' dependency
                  final day = items[index].date.day.toString().padLeft(2, '0');

                  return GestureDetector(
                    onTap: () => onSelect(index),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(6),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: style.selectedDayColor,
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF4A4A4A)
                                : const Color(0xFFBCBCBC),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top Mirror Shadow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        style.sliderColor,
                        style.sliderColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Mirror Shadow
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        style.sliderColor,
                        style.sliderColor.withValues(alpha: 0),
                      ],
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

/// Navigation arrows widget with style injection.
class _NavigationArrows extends StatelessWidget {
  final JournalStyle style;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _NavigationArrows({required this.style, this.onPrevious, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ArrowButton(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
          color: style.navArrowColor,
          disabledColor: style.navArrowDisabledColor,
        ),
        const SizedBox(width: 8),
        _ArrowButton(
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
          color: style.navArrowColor,
          disabledColor: style.navArrowDisabledColor,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color disabledColor;

  const _ArrowButton({
    required this.icon,
    this.onPressed,
    required this.color,
    required this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? color : disabledColor,
          ),
        ),
      ),
    );
  }
}
