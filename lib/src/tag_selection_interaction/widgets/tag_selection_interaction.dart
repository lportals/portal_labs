import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../common/portal_utils.dart';
import '../models/tag_model.dart';
import '../models/tag_selection_style.dart';
import 'tag_item_widget.dart';

/// A premium, animated tag selection interaction that allows users to pick
/// tags from a pool and see them "fly" into a selected list.
///
/// Features:
/// - Physics-based "Magic Move" animations using custom spring curves.
/// - Adaptive [Wrap] layout that handles multiple lines automatically.
/// - "Apple-inspired" aesthetics with subtle shadows and high-fidelity transitions.
/// - 100% Vanilla Flutter with zero external dependencies.
class TagSelectionInteraction extends StatefulWidget {
  /// The list of all available tags.
  final List<TagModel> allTags;

  /// Initial set of selected tag IDs.
  final Set<String>? initialSelectedIds;

  /// Callback triggered when the selection changes.
  final ValueChanged<Set<String>>? onChanged;

  /// Spacing between tags in the same row.
  final double spacing;

  /// Spacing between rows of tags.
  final double runSpacing;

  /// Padding for the interaction container.
  final EdgeInsets padding;

  /// Title for the selected section.
  final String selectedTitle;

  /// Visual aesthetic configuration.
  final TagSelectionStyle style;

  /// Creates a new [TagSelectionInteraction].
  const TagSelectionInteraction({
    super.key,
    required this.allTags,
    this.initialSelectedIds,
    this.onChanged,
    this.spacing = 8.0,
    this.runSpacing = 10.0,
    this.padding = const EdgeInsets.all(20.0),
    this.selectedTitle = 'TAGS',
    this.style = TagSelectionStyle.light,
  });

  @override
  State<TagSelectionInteraction> createState() =>
      _TagSelectionInteractionState();
}

class _TagSelectionInteractionState extends State<TagSelectionInteraction> {
  late Set<String> _selectedIds;
  final Map<String, Size> _sizeCache = {};

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds ?? {});
  }

  /// Calculates the size of a tag based on its state and the current style.
  Size _measureTag(TagModel tag, bool isSelected, TextScaler textScaler) {
    final style = isSelected ? widget.style.selectedTextStyle : widget.style.unselectedTextStyle;
    final cacheKey = '${tag.id}_${isSelected}_${textScaler.scale(style.fontSize ?? 14)}';
    
    if (_sizeCache.containsKey(cacheKey)) return _sizeCache[cacheKey]!;

    // Measure text with scaling
    final textPainter = TextPainter(
      text: TextSpan(text: tag.label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    
    final textSize = textPainter.size;

    // Horizontal: Left + Right + IconSlot(if selected) + TextWidth + Buffer
    final double horizontalPadding = widget.style.tagPadding.horizontal;
    final width = horizontalPadding + textSize.width + (isSelected ? 20.0 : 0) + 12.0;
    
    // Vertical: We use a fixed height for perfect Wrap alignment
    const height = 40.0;

    final size = Size(width, height);
    _sizeCache[cacheKey] = size;
    return size;
  }

  void _toggleTag(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      widget.onChanged?.call(_selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - widget.padding.horizontal;
        final textScaler = MediaQuery.textScalerOf(context);

        // Separate tags into selected and unselected
        final selectedTags = widget.allTags.where((t) => _selectedIds.contains(t.id)).toList();
        final unselectedTags = widget.allTags.where((t) => !_selectedIds.contains(t.id)).toList();

        // Calculate layout for selected tags
        final selectedSizes = selectedTags.map((t) => _measureTag(t, true, textScaler)).toList();
        final selectedOffsets = _calculateWrapOffsets(selectedSizes, maxWidth);
        final selectedHeight = _calculateTotalHeight(selectedOffsets, selectedSizes, widget.runSpacing);

        // Calculate layout for unselected tags (the pool)
        final unselectedSizes = unselectedTags.map((t) => _measureTag(t, false, textScaler)).toList();
        final unselectedOffsets = _calculateWrapOffsets(unselectedSizes, maxWidth);
        final poolHeight = _calculateTotalHeight(unselectedOffsets, unselectedSizes, widget.runSpacing);

        const sectionGap = 16.0;
        const innerPadding = 12.0;

        const selectedAreaOffsetY = 0.0;
        
        // Calculate the actual height the selected area is occupying
        final actualSelectedHeight = selectedTags.isEmpty 
            ? 0.0 
            : (selectedHeight + innerPadding * 2);

        final poolAreaOffsetY = selectedAreaOffsetY + actualSelectedHeight + (selectedTags.isEmpty ? 0 : sectionGap);

        return Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.selectedTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.4),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: constraints.maxWidth,
                height: poolAreaOffsetY + poolHeight + 20, // Total height
                child: Stack(
                  children: [
                    // --- Selected Area Background ---
                    Positioned(
                      top: selectedAreaOffsetY,
                      left: 0,
                      right: 0,
                      height: actualSelectedHeight,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.fastOutSlowIn,
                        decoration: BoxDecoration(
                          color: widget.style.selectedAreaColor,
                          borderRadius: BorderRadius.circular(
                            widget.style.selectedAreaBorderRadius,
                          ),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    // --- Tags (Flying Layer) ---
                    // We render ALL tags in one stack so they can fly between sections
                    ...widget.allTags.map((tag) {
                      final isSelected = _selectedIds.contains(tag.id);
                      final size = _measureTag(tag, isSelected, textScaler);

                      Offset targetOffset;
                      if (isSelected) {
                        final index = selectedTags.indexOf(tag);
                        targetOffset = selectedOffsets[index].translate(innerPadding, selectedAreaOffsetY + innerPadding);
                      } else {
                        final index = unselectedTags.indexOf(tag);
                        targetOffset = unselectedOffsets[index].translate(0, poolAreaOffsetY);
                      }

                      return AnimatedPositioned(
                        key: ValueKey(tag.id),
                        duration: const Duration(milliseconds: 650),
                        curve: _AppleSpringCurve(
                          damping: widget.style.damping,
                          stiffness: widget.style.stiffness,
                        ),
                        left: targetOffset.dx,
                        top: targetOffset.dy,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 650),
                          curve: _AppleSpringCurve(
                            damping: widget.style.damping,
                            stiffness: widget.style.stiffness,
                          ),
                          scale: isSelected ? 1.0 : 1.0, // We can trigger a pulse here
                          child: TagItemWidget(
                            tag: tag,
                            isSelected: isSelected,
                            style: widget.style,
                            onTap: () => _toggleTag(tag.id),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Offset> _calculateWrapOffsets(List<Size> sizes, double maxWidth) {
    if (sizes.isEmpty) return [];
    List<Offset> offsets = [];
    double currentX = 0;
    double currentY = 0;
    double maxLineHeight = 0;

    for (var size in sizes) {
      if (currentX + size.width > maxWidth && currentX > 0) {
        currentX = 0;
        currentY += maxLineHeight + widget.runSpacing;
        maxLineHeight = 0;
      }
      offsets.add(Offset(currentX, currentY));
      currentX += size.width + widget.spacing;
      maxLineHeight = math.max(maxLineHeight, size.height);
    }
    return offsets;
  }

  double _calculateTotalHeight(List<Offset> offsets, List<Size> sizes, double runSpacing) {
    if (offsets.isEmpty) return 0;
    double maxHeight = 0;
    for (int i = 0; i < offsets.length; i++) {
      maxHeight = math.max(maxHeight, offsets[i].dy + sizes[i].height);
    }
    return maxHeight;
  }
}

/// A custom curve that simulates Apple-style spring physics.
///
/// It uses a damped harmonic oscillator approach to create a snappy,
/// premium interaction feel without external dependencies.
class _AppleSpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const _AppleSpringCurve({
    required this.damping,
    required this.stiffness,
  });

  @override
  double transformInternal(double t) {
    if (t == 0 || t == 1) return t;
    // Standard spring: 1 - e^(-dt) * cos(st)
    return 1 - (math.exp(-damping * t) * math.cos(stiffness * 2 * math.pi * t));
  }
}
