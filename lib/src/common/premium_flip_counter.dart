import 'dart:ui';
import 'package:flutter/material.dart';
import 'portal_utils.dart';

/// A utility widget that simulates a 3D odometer-style mechanical flip animation.
/// 
/// It's specifically designed to handle single-digit transitions for counting
/// or date displays. Each digit animates independently when its value changes,
/// creating a highly premium, tactile feel.
///
/// Features:
/// - **3D Rotation:** Utilizes perspective transformations (`Matrix4`) for a depth effect.
/// - **Configurable Direction:** Supports both upward (increment) and downward (decrement) motions.
/// - **Layout Flexible:** Automatically pads single digits for uniform alignment (e.g., "07").
/// 
/// Example:
/// ```dart
/// PremiumFlipCounter(
///   value: 24,
///   upward: true,
///   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
/// )
/// ```
class PremiumFlipCounter extends StatelessWidget {
  /// The integer value to be displayed.
  /// 
  /// Usually represents a day, count, or price.
  final int value;

  /// Determines the visual "gravity" of the flip.
  /// 
  /// If `true`, the number appears to rotate 'upwards' (like an mechanical counter moving forward).
  /// If `false`, it rotates 'downwards' (backward).
  final bool upward;

  /// The font styling for the digits.
  final TextStyle style;

  /// Optional fixed width for each digit. If null, it will be calculated
  /// automatically based on the [style].
  final double? digitWidth;

  /// Whether to pad single digits with a leading zero (e.g., "07" vs "7").
  final bool padWithZero;

  const PremiumFlipCounter({
    super.key,
    required this.value,
    required this.upward,
    required this.style,
    this.digitWidth,
    this.padWithZero = true,
  });

  @override
  Widget build(BuildContext context) {
    // Measure the widest possible digit (usually '8') to determine column width
    final Size textSize = PortalUtils.measureText('8', style);
    final double width = digitWidth ?? textSize.width;
    final double height = textSize.height;

    // Pad with leading zero for days (e.g., 7 -> "07") for consistent width if requested.
    final String strValue = padWithZero ? PortalUtils.padZero(value) : value.toString();
    final List<String> digits = strValue.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits.asMap().entries.map((entry) {
        final int index = entry.key;
        final String digit = entry.value;
        final int posFromRight = strValue.length - index;

        return ClipRect(
          child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          // Identify if the child is the one coming in or going out
          final isIncoming = child.key == ValueKey('digit_${posFromRight}_$digit');
          
          // ODOMETER LOGIC:
          // If subiendo (upward): Incoming starts at bottom (1.0), Outgoing ends at top (-1.0)
          // If bajando (!upward): Incoming starts at top (-1.0), Outgoing ends at bottom (1.0)
          final slideTween = isIncoming
              ? Tween<Offset>(
                  begin: upward ? const Offset(0.0, 1.2) : const Offset(0.0, -1.2),
                  end: Offset.zero,
                )
              : Tween<Offset>(
                  begin: upward ? const Offset(0.0, -1.2) : const Offset(0.0, 1.2),
                  end: Offset.zero,
                );

          return SlideTransition(
            position: slideTween.animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final double animValue = animation.value;
                  
                  // Cylindrical Rotation Logic
                  final double rotation;
                  if (isIncoming) {
                    // Animation 0 -> 1: Rotation from 1.2 to 0 (or -1.2 to 0)
                    rotation = (upward ? 1.0 - animValue : animValue - 1.0) * 1.2;
                  } else {
                    // Animation 1 -> 0: Rotation from 0 to -1.2 (or 0 to 1.2)
                    rotation = (upward ? animValue - 1.0 : 1.0 - animValue) * 1.2;
                  }

                  return RepaintBoundary(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002) // Perspective
                        ..rotateX(rotation),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
                child: child,
              ),
            ),
          );
        },
            child: SizedBox(
              width: width,
              // Add extra vertical height to allow for 3D perspective rotation
              // without horizontal clipping during the flip
              height: height * 1.2,
              key: ValueKey('digit_${posFromRight}_$digit'),
              child: Center(
                child: Text(
                  digit,
                  style: style,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
