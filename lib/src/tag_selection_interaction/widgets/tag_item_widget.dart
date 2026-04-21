import 'package:flutter/material.dart';

import '../models/tag_model.dart';
import '../models/tag_selection_style.dart';

/// A premium, animated tag item used within the [TagSelectionInteraction].
///
/// This widget handles its own visual state transitions (selected vs unselected)
/// with smooth animations and high-fidelity styling.
class TagItemWidget extends StatelessWidget {
  /// The tag data model.
  final TagModel tag;

  /// Whether the tag is currently selected.
  final bool isSelected;

  /// Callback when the tag is pressed.
  final VoidCallback onTap;

  /// The styling configuration for the tag.
  final TagSelectionStyle style;

  /// Creates a new [TagItemWidget].
  const TagItemWidget({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 650),
        curve: Curves.fastOutSlowIn,
        padding: style.tagPadding,
        decoration: BoxDecoration(
          color: isSelected ? style.selectedTagColor : style.unselectedTagColor,
          borderRadius: BorderRadius.circular(style.borderRadius),
          boxShadow: isSelected ? style.selectedTagShadows : null,
        ),
        constraints: const BoxConstraints(
          minHeight: 40.0,
          maxHeight: 40.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tag.label,
              style: isSelected ? style.selectedTextStyle : style.unselectedTextStyle,
            ),
            // Smoothly animate the 'X' icon instead of popping it
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut, // Changed to prevent negative width on back-bounce
              width: isSelected ? 20.0 : 0.0,
              clipBehavior: Clip.none,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Transform.scale(
                    scale: isSelected ? 1.0 : 0.5,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: style.closeIconColor,
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
