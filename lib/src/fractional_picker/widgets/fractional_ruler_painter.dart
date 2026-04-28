import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-performance [CustomPainter] that draws a horizontal ruler.
///
/// Uses a single [Paint] object throughout and pre-allocates text layout
/// objects to avoid per-frame heap allocations during scrolling.
/// The ruler repaints only when [currentValue] changes by a meaningful amount,
/// ensuring smooth 60/120 fps interaction on all devices.
class FractionalRulerPainter extends CustomPainter {
  /// Creates a [FractionalRulerPainter].
  FractionalRulerPainter({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
    required this.inactiveColor,
    required this.tickColor,
    required this.pixelsPerUnit,
    required this.decimalPlaces,
  });

  /// The current value that is centered on the ruler.
  final double currentValue;

  /// The minimum allowed value.
  final double minValue;

  /// The maximum allowed value.
  final double maxValue;

  /// Color for the active (centered) number.
  final Color activeColor;

  /// Color for the inactive numbers.
  final Color inactiveColor;

  /// Color for the ruler tick marks.
  final Color tickColor;

  /// Number of pixels per 1.0 unit on the ruler.
  final double pixelsPerUnit;

  /// 0 = integers only, 1 = one decimal place.
  final int decimalPlaces;

  // ── Reusable allocations ───────────────────────────────────────────────────
  // These are created once per painter instance instead of on every paint call.
  final Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.5;

  // Cache for TextPainter objects keyed by integer label (e.g. "18").
  // Flutter reuses the same painter instance frames, so this persists.
  final Map<String, TextPainter> _textCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Visible range with 1-unit padding for overdraw margin.
    final double half = centerX / pixelsPerUnit;
    final double startVal = currentValue - half - 1.5;
    final double endVal   = currentValue + half + 1.5;

    final double tickY = size.height - 8;

    // ── 1. Tick marks ─────────────────────────────────────────────────────────
    // Decimal mode uses 0.1 steps (9 intermediate ticks).
    // Integer mode uses 0.2 steps (4 intermediate ticks).
    final int stepScale = decimalPlaces == 0 ? 5 : 10;
    
    final int startStep = (startVal * stepScale).floor();
    final int endStep = (endVal * stepScale).ceil();

    for (int t = startStep; t <= endStep; t++) {
      final double i = t / stepScale.toDouble();
      if (i < minValue - 0.01 || i > maxValue + 0.01) continue;

      final double x = centerX + (i - currentValue) * pixelsPerUnit;

      // Classification
      // In integer mode (step 0.2): t % 5 == 0 is major (integer)
      // In decimal mode (step 0.1): t % 10 == 0 is major (integer)
      final bool isMajor = decimalPlaces == 0 ? (t % 5 == 0) : (t % 10 == 0);
      final bool isHalf  = decimalPlaces == 0 ? false : (t % 5 == 0 && !isMajor);
      final double tickH = isMajor ? 14.0 : (isHalf ? 9.0 : 6.0);

      
      // Fixed uniform color for all ticks, with high contrast
      _paint.color = tickColor.withValues(alpha: 0.7);
      canvas.drawLine(Offset(x, tickY), Offset(x, tickY - tickH), _paint);
    }

    // ── 2. Number labels ──────────────────────────────────────────────────────
    for (int n = startVal.floor(); n <= endVal.ceil(); n++) {
      final double i = n.toDouble();
      if (i < minValue || i > maxValue) continue;

      final double x = centerX + (i - currentValue) * pixelsPerUnit;
      final double dist = (i - currentValue).abs();

      // Sharp falloff for the 'active' state (color)
      // distance of 1.5 units is where it becomes fully inactive
      final double colorT = (1.0 - (dist / 1.5)).clamp(0.0, 1.0);
      
      // All labels are visible (high alpha), but only center is dark
      
      final Color labelColor = Color.lerp(inactiveColor, activeColor, math.pow(colorT, 4).toDouble())!;
      // Constant high alpha so numbers are visible at the edges
      final Color finalColor = labelColor.withValues(alpha: 0.85);

      final String label = decimalPlaces == 0 ? n.toString() : i.toStringAsFixed(1);

      // ── TextPainter cache ───────────────────────────────────────────────────
      // We need a new TextPainter when color changes (each frame during scroll).
      // Key the cache on "label:colorHex" so we reuse identical painters.
      final String cacheKey = '$label:${finalColor.toARGB32()}';
      TextPainter? tp = _textCache[cacheKey];
      if (tp == null) {
        tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: finalColor,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        // Keep cache small: only retain the ~20 most recent painters.
        if (_textCache.length >= 20) {
          _textCache.remove(_textCache.keys.first);
        }
        _textCache[cacheKey] = tp;
      }

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, centerY - tp.height / 2 - 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FractionalRulerPainter old) {
    // Skip repaint if the visual offset has not changed by at least 0.1px.
    // This avoids repaints from floating-point noise during fling deceleration.
    final double pixelDelta = ((currentValue - old.currentValue) * pixelsPerUnit).abs();
    return pixelDelta > 0.1 ||
           old.decimalPlaces != decimalPlaces ||
           old.activeColor   != activeColor   ||
           old.inactiveColor != inactiveColor  ||
           old.tickColor     != tickColor;
  }
}
