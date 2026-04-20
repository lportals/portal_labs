import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'models/slot_picker_item.dart';
import 'models/slot_picker_style.dart';

/// A premium, physics-based Slot Picker Interaction widget.
///
/// Designed to simulate the fluid, spring-based interactions found in high-end
/// Apple interfaces. Features expandable items, time slot management,
/// and smooth reactive transitions.
class SlotPickerInteraction extends StatefulWidget {
  /// The list of items to display in the picker.
  final List<SlotPickerItem> items;

  /// Callback when an item's enabled state is toggled.
  final Function(int index, bool isEnabled)? onItemToggle;

  /// Callback when a new slot is added to an item.
  final Function(int index)? onAddSlot;

  /// Callback when a slot is removed from an item.
  final Function(int itemIndex, int slotIndex)? onRemoveSlot;

  /// Callback when a slot's time range is updated.
  final Function(int itemIndex, int slotIndex, SlotRange newRange)? onSlotChanged;

  /// Semantic styling for the picker.
  final SlotPickerStyle style;

  /// Spacing between items.
  final double spacing;

  /// Maximum number of slots allowed per item.
  final int? maxSlots;

  /// Whether to automatically correct invalid time ranges (Start < End).
  final bool enableSmartValidation;

  /// Whether to detect and highlight overlapping slots.
  final bool enableOverlapDetection;

  /// The time interval used for validation corrections and picker snapping.
  final Duration validationInterval;

  const SlotPickerInteraction({
    super.key,
    required this.items,
    this.onItemToggle,
    this.onAddSlot,
    this.onRemoveSlot,
    this.onSlotChanged,
    this.style = const SlotPickerStyle(),
    this.spacing = 8.0,
    this.maxSlots,
    this.enableSmartValidation = true,
    this.enableOverlapDetection = true,
    this.validationInterval = const Duration(hours: 1),
  });

  @override
  State<SlotPickerInteraction> createState() => _SlotPickerInteractionState();
}

class _SlotPickerInteractionState extends State<SlotPickerInteraction> {
  final Set<int> _expandedIndices = {};

  void _handleHeaderTap(int index) {
    final item = widget.items[index];
    final newEnabledState = !item.isEnabled;
    
    // Toggle the switch state
    widget.onItemToggle?.call(index, newEnabledState);
    
    // Auto-add a slot if enabling and currently empty
    if (newEnabledState && item.slots.isEmpty) {
      widget.onAddSlot?.call(index);
    }
    
    setState(() {
      if (newEnabledState) {
        _expandedIndices.add(index);
      } else {
        _expandedIndices.remove(index);
      }
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isExpanded = _expandedIndices.contains(index);

        return Padding(
          key: ValueKey('item_${item.title}_$index'),
          padding: EdgeInsets.only(
            bottom: index == widget.items.length - 1 ? 0 : widget.spacing,
          ),
          child: _SlotPickerItemWidget(
            item: item,
            isExpanded: isExpanded,
            onHeaderTap: () => _handleHeaderTap(index),
            onToggle: (val) {
              if (val != item.isEnabled) {
                 _handleHeaderTap(index);
              }
            },
            onAddSlot: () => widget.onAddSlot?.call(index),
            onRemoveSlot: (slotIndex) {
              final isLastSlot = item.slots.length <= 1;
              widget.onRemoveSlot?.call(index, slotIndex);
              if (isLastSlot && item.isEnabled) {
                // Auto-toggle off since there are no slots left
                _handleHeaderTap(index);
              }
            },
            onSlotChanged: (slotIndex, range) => widget.onSlotChanged?.call(index, slotIndex, range),
            style: widget.style,
            maxSlots: widget.maxSlots,
            enableSmartValidation: widget.enableSmartValidation,
            enableOverlapDetection: widget.enableOverlapDetection,
            validationInterval: widget.validationInterval,
          ),
        );
      }),
    );
  }
}

class _SlotPickerItemWidget extends StatefulWidget {
  final SlotPickerItem item;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddSlot;
  final Function(int) onRemoveSlot;
  final Function(int, SlotRange) onSlotChanged;
  final SlotPickerStyle style;
  final int? maxSlots;
  final bool enableSmartValidation;
  final bool enableOverlapDetection;
  final Duration validationInterval;

  const _SlotPickerItemWidget({
    required this.item,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.onToggle,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onSlotChanged,
    required this.style,
    this.maxSlots,
    required this.enableSmartValidation,
    required this.enableOverlapDetection,
    required this.validationInterval,
  });

  @override
  State<_SlotPickerItemWidget> createState() => _SlotPickerItemWidgetState();
}

class _SlotPickerItemWidgetState extends State<_SlotPickerItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _clampedAnimation;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<SlotRange> _currentSlots;

  @override
  void initState() {
    super.initState();
    _currentSlots = List.from(widget.item.slots);
    _controller = AnimationController(
      vsync: this,
      lowerBound: -0.5,
      upperBound: 1.5,
      duration: const Duration(milliseconds: 500),
    );

    _expandAnimation = _controller;
    _clampedAnimation = _expandAnimation.drive(_ClampedTween(begin: 0.0, end: 1.0));

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _runSpringAnimation(bool expand, {double velocity = 0}) {
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 180,
      damping: 15,
    );

    final simulation = SpringSimulation(
      spring,
      _controller.value,
      expand ? 1.0 : 0.0,
      velocity,
    );

    _controller.animateWith(simulation);
  }

  @override
  void didUpdateWidget(_SlotPickerItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _runSpringAnimation(widget.isExpanded);
    }

    // Sync slots with AnimatedList
    final newSlots = widget.item.slots;
    if (_currentSlots.length < newSlots.length) {
      final startIndex = _currentSlots.length;
      final count = newSlots.length - _currentSlots.length;
      
      setState(() {
        _currentSlots = List.from(newSlots);
        if (widget.isExpanded) {
          _runSpringAnimation(true, velocity: 3.5);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (int i = 0; i < count; i++) {
          _listKey.currentState?.insertItem(
            startIndex + i, 
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    } else if (_currentSlots.length > newSlots.length) {
      final oldSlots = List.from(_currentSlots);
      final count = _currentSlots.length - newSlots.length;
      
      final updatedSlots = List<SlotRange>.from(newSlots);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (int i = 0; i < count; i++) {
          final index = oldSlots.length - 1 - i;
          final removedItem = oldSlots[index];
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => _buildRemovedItem(removedItem, animation),
            duration: const Duration(milliseconds: 200),
          );
        }
        
        if (mounted) {
          setState(() {
            _currentSlots = updatedSlots;
          });
        }
      });
    } else {
        // Just update the instances if count is same
        _currentSlots = List.from(newSlots);
    }
  }

  Widget _buildRemovedItem(SlotRange slot, Animation<double> animation) {
    final bounceAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    
    return FadeTransition(
      opacity: _ClampedTween(begin: 0.0, end: 1.0).animate(animation),
      child: SizeTransition(
        sizeFactor: bounceAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _SlotRow(
            slot: slot,
            onRemove: () {},
            onChanged: (range) {},
            style: widget.style,
            validationInterval: widget.validationInterval,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _doSlotsOverlap(SlotRange a, SlotRange b) {
    int startA = a.startTime.hour * 60 + a.startTime.minute;
    int endA = a.endTime.hour * 60 + a.endTime.minute;
    int startB = b.startTime.hour * 60 + b.startTime.minute;
    int endB = b.endTime.hour * 60 + b.endTime.minute;
    
    // Handle 12:00 AM as end of day for validation
    if (endA == 0) endA = 1440;
    if (endB == 0) endB = 1440;

    return startA < endB && startB < endA;
  }

  Set<int> _getOverlappingIndices() {
    if (!widget.enableOverlapDetection) return <int>{};
    
    final overlaps = <int>{};
    for (int i = 0; i < _currentSlots.length; i++) {
      for (int j = i + 1; j < _currentSlots.length; j++) {
        if (_doSlotsOverlap(_currentSlots[i], _currentSlots[j])) {
          overlaps.add(i);
          overlaps.add(j);
        }
      }
    }
    return overlaps;
  }

  @override
  Widget build(BuildContext context) {
    final overlappingIndices = _getOverlappingIndices();
    final effectiveSwitchColor = widget.style.activeSwitchColor;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final isActuallyEnabled = widget.item.isEnabled;
        
        final Color backgroundColor = isActuallyEnabled 
            ? Colors.white 
            : widget.style.collapsedBackgroundColor;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: widget.style.borderRadius,
            boxShadow: (isActuallyEnabled && widget.isExpanded) ? widget.style.shadows : null,
            border: Border.all(
              color: Color.lerp(
                Colors.grey.withOpacity(0.05),
                Colors.grey.withOpacity(0.15),
                _clampedAnimation.value,
              )!,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ItemHeader(
                title: widget.item.title,
                isEnabled: widget.item.isEnabled,
                onTap: widget.onHeaderTap,
                onToggle: widget.onToggle,
                style: widget.style,
                activeSwitchColor: effectiveSwitchColor,
              ),
              if (_clampedAnimation.value > 0)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Padding(
                    padding: widget.style.contentPadding,
                    child: FadeTransition(
                      opacity: _clampedAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _currentSlots.length,
                            itemBuilder: (context, index, animation) {
                              if (index >= _currentSlots.length) return const SizedBox.shrink();
                              
                              final bounceAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );
   
                              return FadeTransition(
                                opacity: _ClampedTween(begin: 0.0, end: 1.0).animate(animation),
                                 child: SizeTransition(
                                  sizeFactor: bounceAnimation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(bounceAnimation),
                                    child: SlideTransition(
                                      position: _clampedAnimation.drive(
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.05),
                                          end: Offset.zero,
                                        ).chain(CurveTween(
                                          curve: Interval(
                                            (index * 0.03).clamp(0.0, 0.3),
                                            (index * 0.03 + 0.6).clamp(0.0, 1.0),
                                            curve: Curves.easeOutCubic,
                                          ),
                                        )),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                          child: _SlotRow(
                                            slot: _currentSlots[index],
                                            onRemove: () => widget.onRemoveSlot(index),
                                            onChanged: (range) => widget.onSlotChanged(index, range),
                                            style: widget.style,
                                            hasError: overlappingIndices.contains(index),
                                            enableSmartValidation: widget.enableSmartValidation,
                                            validationInterval: widget.validationInterval,
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (widget.maxSlots == null || _currentSlots.length < widget.maxSlots!) ...[
                            const SizedBox(height: 4),
                            SlideTransition(
                              position: _clampedAnimation.drive(
                                Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).chain(CurveTween(
                                  curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
                                )),
                              ),
                              child: _AddMoreButton(
                                onTap: widget.onAddSlot,
                                style: widget.style,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedSlotEntry extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedSlotEntry({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.3 + (index * 0.1);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 0.9),
        (start + 0.3).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ItemHeader extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final SlotPickerStyle style;
  final Color activeSwitchColor;

  const _ItemHeader({
    required this.title,
    required this.isEnabled,
    required this.onTap,
    required this.onToggle,
    required this.style,
    required this.activeSwitchColor,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Padding(
        padding: style.headerPadding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: style.titleStyle ??
                    TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? style.labelColor : style.secondaryLabelColor,
                      letterSpacing: -0.4,
                    ),
              ),
            ),
            AbsorbPointer(
              child: Transform.translate(
                offset: const Offset(8, 0), // Compensating for switch's internal margin
                child: Transform.scale(
                  scale: 0.82,
                  child: Switch.adaptive(
                    value: isEnabled,
                    onChanged: (val) {},
                    activeColor: Colors.white,
                    activeTrackColor: activeSwitchColor,
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

class _SlotRow extends StatelessWidget {
  final SlotRange slot;
  final VoidCallback onRemove;
  final ValueChanged<SlotRange> onChanged;
  final SlotPickerStyle style;
  final bool hasError;
  final bool enableSmartValidation;
  final Duration validationInterval;

  const _SlotRow({
    required this.slot,
    required this.onRemove,
    required this.onChanged,
    required this.style,
    this.hasError = false,
    this.enableSmartValidation = true,
    required this.validationInterval,
  });

  String _formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  TimeOfDay _fromMinutes(int minutes) {
    final clamped = minutes.clamp(0, 1439);
    return TimeOfDay(hour: clamped ~/ 60, minute: clamped % 60);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? slot.startTime : slot.endTime;
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      TimeOfDay selectedTime = initialTime;
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        isStart ? 'Start Time' : 'End Time',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label.resolveFrom(context).withOpacity(0.6),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Done', 
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          color: CupertinoColors.activeBlue,
                          decoration: TextDecoration.none,
                        )
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  minuteInterval: (validationInterval.inMinutes % 60 == 0) ? 1 : 
                                 (validationInterval.inMinutes < 60 ? validationInterval.inMinutes : 1),
                  initialDateTime: DateTime(2024, 1, 1, initialTime.hour, initialTime.minute),
                  onDateTimeChanged: (dt) {
                    selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
                    
                    if (!enableSmartValidation) {
                       onChanged(isStart 
                          ? slot.copyWith(startTime: selectedTime) 
                          : slot.copyWith(endTime: selectedTime));
                       return;
                    }

                    if (isStart) {
                      final startMins = _toMinutes(selectedTime);
                      final endMins = _toMinutes(slot.endTime);
                      
                      if (startMins >= endMins) {
                        final newEnd = _fromMinutes(startMins + validationInterval.inMinutes);
                        onChanged(slot.copyWith(startTime: selectedTime, endTime: newEnd));
                      } else {
                        onChanged(slot.copyWith(startTime: selectedTime));
                      }
                    } else {
                      final startMins = _toMinutes(slot.startTime);
                      final endMins = _toMinutes(selectedTime);
                      
                      if (endMins <= startMins) {
                        final newStart = _fromMinutes(endMins - validationInterval.inMinutes);
                        onChanged(slot.copyWith(startTime: newStart, endTime: selectedTime));
                      } else {
                        onChanged(slot.copyWith(endTime: selectedTime));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: style.activeSwitchColor,
                onPrimary: Colors.white,
                onSurface: style.labelColor,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        if (!enableSmartValidation) {
           onChanged(isStart 
              ? slot.copyWith(startTime: picked) 
              : slot.copyWith(endTime: picked));
           return;
        }

        if (isStart) {
          final startMins = _toMinutes(picked);
          final endMins = _toMinutes(slot.endTime);
          
          if (startMins >= endMins) {
            final newEnd = _fromMinutes(startMins + validationInterval.inMinutes);
            onChanged(slot.copyWith(startTime: picked, endTime: newEnd));
          } else {
            onChanged(slot.copyWith(startTime: picked));
          }
        } else {
          final startMins = _toMinutes(slot.startTime);
          final endMins = _toMinutes(picked);
          
          if (endMins <= startMins) {
            final newStart = _fromMinutes(endMins - validationInterval.inMinutes);
            onChanged(slot.copyWith(startTime: newStart, endTime: picked));
          } else {
            onChanged(slot.copyWith(endTime: picked));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeInput(
            timeString: _formatTime(context, slot.startTime),
            onTap: () => _selectTime(context, true),
            style: style,
            hasError: hasError,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "To",
          style: TextStyle(
            fontSize: 14,
            color: style.secondaryLabelColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TimeInput(
            timeString: _formatTime(context, slot.endTime),
            onTap: () => _selectTime(context, false),
            style: style,
            hasError: hasError,
          ),
        ),
        const SizedBox(width: 12),
        _PressScale(
          onTap: onRemove,
          child: _IconButton(
            icon: Icons.close,
            backgroundColor: style.removeButtonBackgroundColor,
            iconColor: style.removeIconColor,
          ),
        ),
      ],
    );
  }
}

class _TimeInput extends StatelessWidget {
  final String timeString;
  final VoidCallback onTap;
  final SlotPickerStyle style;
  final bool hasError;

  const _TimeInput({
    required this.timeString,
    required this.onTap,
    required this.style,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hasError ? style.errorColor.withOpacity(0.05) : style.inputFillColor,
          borderRadius: BorderRadius.circular(10),
          border: hasError 
              ? Border.all(color: style.errorColor, width: 1.0)
              : (style.inputBorder ?? Border.all(color: Colors.grey.withOpacity(0.15))),
        ),
        child: Text(
          timeString,
          style: style.slotTextStyle ??
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: style.slotTextColor,
              ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _IconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 16,
        color: iconColor,
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  final SlotPickerStyle style;

  const _AddMoreButton({
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: style.addButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: const Color(0xFF636366),
            ),
            const SizedBox(width: 4),
            Text(
              "Add More",
              style: style.addButtonTextStyle ?? TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: style.secondaryLabelColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A premium press-scale interaction wrapper.
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

class _ClampedTween extends Tween<double> {
  _ClampedTween({super.begin, super.end});

  @override
  double lerp(double t) => super.lerp(t).clamp(0.0, 1.0);
}
