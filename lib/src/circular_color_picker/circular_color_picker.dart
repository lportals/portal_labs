import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/circular_color_picker_style.dart';

/// A premium circular color picker widget.
///
/// Displays a collection of colors arranged in a ring layout. Selecting a color
/// slides it to the center using a spring physics animation, while the previously
/// selected color slides smoothly back to its slot in the ring.
class CircularColorPicker extends StatefulWidget {
  /// Creates a [CircularColorPicker].
  const CircularColorPicker({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onChanged,
    this.style = const CircularColorPickerStyle(),
    this.enabled = true,
  }) : assert(colors.length > 0, 'At least one color must be provided.');

  /// The list of colors to display in the picker.
  final List<Color> colors;

  /// The index of the currently selected color.
  final int selectedIndex;

  /// Callback triggered when a new color is selected.
  final ValueChanged<int> onChanged;

  /// The visual configuration style.
  final CircularColorPickerStyle style;

  /// Whether the picker accepts user interactions.
  final bool enabled;

  @override
  State<CircularColorPicker> createState() => _CircularColorPickerState();
}

class _CircularColorPickerState extends State<CircularColorPicker> {
  late int _previousSelectedIndex;

  @override
  void initState() {
    super.initState();
    _previousSelectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CircularColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousSelectedIndex = oldWidget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Total size required is based on outerRadius and the center circle's size.
    final double totalSize = (widget.style.outerRadius + (widget.style.centerSize / 2)) * 2;

    // Order indices so that static items are built first (bottom),
    // the previous selected item is next, and the currently selected item is last (top).
    final List<int> orderedIndices = List.generate(widget.colors.length, (i) => i);
    orderedIndices.sort((a, b) {
      if (a == widget.selectedIndex) return 1;
      if (b == widget.selectedIndex) return -1;
      if (a == _previousSelectedIndex) return 1;
      if (b == _previousSelectedIndex) return -1;
      return 0;
    });

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        children: orderedIndices.map((index) {
          final double angle = (index * 2 * math.pi / widget.colors.length) - (math.pi / 2);
          final double x = widget.style.outerRadius * math.cos(angle);
          final double y = widget.style.outerRadius * math.sin(angle);
          final bool isSelected = index == widget.selectedIndex;

          return _CircularColorPickerItem(
            key: ValueKey('color_item_$index'),
            color: widget.colors[index],
            circleOffset: Offset(x, y),
            isSelected: isSelected,
            style: widget.style,
            enabled: widget.enabled,
            totalSize: totalSize,
            onTap: () {
              if (!widget.enabled || isSelected) return;
              if (widget.style.enableHaptics) {
                HapticFeedback.lightImpact();
              }
              widget.onChanged(index);
            },
          );
        }).toList(),
      ),
    );
  }
}

/// An individual color item within the [CircularColorPicker].
///
/// Handles its own animation state, transitioning between its position on the
/// circle and the center of the picker based on [isSelected].
class _CircularColorPickerItem extends StatefulWidget {
  const _CircularColorPickerItem({
    super.key,
    required this.color,
    required this.circleOffset,
    required this.isSelected,
    required this.style,
    required this.enabled,
    required this.totalSize,
    required this.onTap,
  });

  final Color color;
  final Offset circleOffset;
  final bool isSelected;
  final CircularColorPickerStyle style;
  final bool enabled;
  final double totalSize;
  final VoidCallback onTap;

  @override
  State<_CircularColorPickerItem> createState() => _CircularColorPickerItemState();
}

class _CircularColorPickerItemState extends State<_CircularColorPickerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
      duration: widget.isSelected
          ? widget.style.toCenterDuration
          : widget.style.toCircleDuration,
    );
  }

  @override
  void didUpdateWidget(covariant _CircularColorPickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.animateTo(
          1.0,
          duration: widget.style.toCenterDuration,
          curve: widget.style.toCenterCurve,
        );
      } else {
        _controller.animateTo(
          0.0,
          duration: widget.style.toCircleDuration,
          curve: widget.style.toCircleCurve,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        // Interpolate position from circleOffset (t = 0) to Offset.zero (t = 1)
        final Offset currentOffset = Offset.lerp(widget.circleOffset, Offset.zero, t)!;

        // Interpolate size from itemSize (t = 0) to centerSize (t = 1)
        final double currentSize = lerpDouble(widget.style.itemSize, widget.style.centerSize, t);

        // Interpolate border width from itemBorderWidth (t = 0) to centerBorderWidth (t = 1)
        final double currentBorderWidth = lerpDouble(
          widget.style.itemBorderWidth,
          widget.style.centerBorderWidth,
          t,
        );

        final double cx = widget.totalSize / 2;
        final double cy = widget.totalSize / 2;

        final double itemLeft = cx + currentOffset.dx - (currentSize / 2);
        final double itemTop = cy + currentOffset.dy - (currentSize / 2);

        return Positioned(
          left: itemLeft,
          top: itemTop,
          width: currentSize,
          height: currentSize,
          child: GestureDetector(
            onTap: widget.enabled ? widget.onTap : null,
            child: MouseRegion(
              cursor: widget.enabled && !widget.isSelected
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.5,
                child: AnimatedContainer(
                  duration: _controller.isAnimating ? Duration.zero : const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.style.useSolidFill ? widget.color : widget.style.fillColor,
                    border: widget.style.useSolidFill
                        ? Border.all(
                            color: widget.color.withValues(alpha: 0.0),
                            width: 0.0,
                          )
                        : Border.all(
                            color: widget.color,
                            width: currentBorderWidth,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Simple linear interpolation helper for doubles to avoid dart:ui dependency issues.
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
