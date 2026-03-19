import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium [CustomPainter] that draws a curved ruler with numbers for scale selection.
/// 
/// This painter handles the visual representation of the arc, the scaling of numbers
/// near the center, and the smooth color interpolation between active and inactive states.
class WeightRulerPainter extends CustomPainter {
  /// The current value being pointed at in the center.
  final double currentValue;

  /// The minimum value allowed on the scale.
  final double minValue;

  /// The maximum value allowed on the scale.
  final double maxValue;

  /// The color of the active (center) number and indicator.
  final Color activeColor;

  /// The color of the inactive numbers away from the center.
  final Color inactiveColor;

  /// The color of the tick marks on the ruler.
  final Color tickColor;

  /// The angular spacing between each integer unit.
  final double anglePerUnit;

  /// The unit to display alongside the number (e.g. 'kg').
  final String unit;

  WeightRulerPainter({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
    required this.inactiveColor,
    required this.tickColor,
    required this.unit,
    this.anglePerUnit = math.pi / 9.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Arc Configuration
    // The center is pushed far down to create a shallow, elegant curve.
    final center = Offset(size.width / 2, size.height * 1.8); 
    final numberRadius = size.height * 1.45;
    final tickRadius = size.height * 1.15;
    
    // Number of neighbors to draw around the center for performance.
    const int visibleNeighbors = 3;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startTick = (currentValue - visibleNeighbors).floorToDouble();
    final endTick = (currentValue + visibleNeighbors).ceilToDouble();

    // 2. Draw Tick Marks
    for (double i = startTick; i <= endTick; i += 0.2) {
      if (i < minValue || i > maxValue) continue;

      final angle = (i - currentValue) * anglePerUnit - (math.pi / 2);
      final distanceFromCenter = (i - currentValue).abs();
      
      // Fade opacity based on distance from the center.
      final opacity = (1.5 - (distanceFromCenter / 1.5)).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      // Robust check for integer ticks (Major ticks)
      final isMajor = (i - i.roundToDouble()).abs() < 0.01;
      paint.color = tickColor.withOpacity(opacity * 0.7);
      paint.strokeWidth = 2.5;
      
      // Responsive tick lengths (9% and 5% of height)
      final tickLength = isMajor ? (size.height * 0.09) : (size.height * 0.05);

      final p1 = Offset(
        center.dx + tickRadius * math.cos(angle),
        center.dy + tickRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (tickRadius - tickLength) * math.cos(angle),
        center.dy + (tickRadius - tickLength) * math.sin(angle),
      );

      canvas.drawLine(p1, p2, paint);
    }

    // 3. Draw Large Numbers
    // Scale font size relative to container height (approx 26% for 2 digits)
    final double baseFontSize = size.height * 0.26;
    final double smallFontSize = size.height * 0.23;

    for (int i = startTick.toInt() - 1; i <= endTick.toInt() + 1; i++) {
      if (i < minValue || i > maxValue) continue;

      final angle = (i - currentValue) * anglePerUnit - (math.pi / 2);
      final distanceFromCenter = (i - currentValue).abs();
      
      // Control opacity for numerical labels
      final opacity = (1.0 - (distanceFromCenter / 2.2)).clamp(0.0, 1.0);
      if (opacity <= 0.1) continue;

      // Smooth color interpolation for a premium "implicit" animation feel.
      final colorT = (1.0 - (distanceFromCenter / 0.7)).clamp(0.0, 1.0);
      final lerpedColor = Color.lerp(inactiveColor, activeColor, colorT);

      // Subtle scaling as numbers approach the center.
      final scaleFactor = 1.0 + (0.08 * colorT); 

      final String label = i.toString();
      final bool isLong = label.length >= 3;

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                color: lerpedColor?.withOpacity(opacity),
                fontSize: isLong ? smallFontSize : baseFontSize, 
                fontWeight: FontWeight.w800,
                letterSpacing: isLong ? -7 : -5,
                height: 1.0,
              ),
            ),
            /* 
            // To re-enable unit display, uncomment the following block:
            if (colorT > 0.5) // Only show unit for the active/center number
              TextSpan(
                text: ' ${unit.toLowerCase()}',
                style: TextStyle(
                  color: lerpedColor?.withOpacity(opacity * (colorT - 0.5) * 2),
                  fontSize: (isLong ? smallFontSize : baseFontSize) * 0.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            */
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pos = Offset(
        center.dx + numberRadius * math.cos(angle),
        center.dy + numberRadius * math.sin(angle),
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(scaleFactor);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant WeightRulerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
           oldDelegate.activeColor != activeColor ||
           oldDelegate.inactiveColor != inactiveColor ||
           oldDelegate.tickColor != tickColor;
  }
}
