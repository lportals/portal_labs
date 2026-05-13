import 'package:flutter/material.dart';

/// A premium archival item container designed to be used inside 
/// the [ArchiveFolder], but also usable independently.
/// It features a classic frame with a label area, suitable for 
/// documents, stamps, photos, or cards.
class ArchiveItem extends StatelessWidget {
  /// Creates a [ArchiveItem].
  const ArchiveItem({
    super.key,
    required this.child,
    required this.label,
    this.color = Colors.white,
    this.labelStyle,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(8.0),
    this.width = 140.0,
    this.height = 180.0,
  });

  /// The main content of the stamp (e.g., an Image or Icon).
  final Widget child;

  /// The descriptive label shown at the bottom of the stamp.
  final String label;

  /// The background color of the stamp frame.
  final Color color;

  /// The style for the label text.
  final TextStyle? labelStyle;

  /// The border radius of the stamp frame.
  final double borderRadius;

  /// The padding around the [child] content.
  final EdgeInsetsGeometry padding;

  /// The width of the item frame.
  final double width;

  /// The height of the item frame.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: padding,
              child: Center(child: child),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(borderRadius),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: labelStyle ?? const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
