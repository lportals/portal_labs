import 'package:flutter/material.dart';

/// Paints the slider track with a background, active gradient, and internal indicator dots.
class SliderTrackPainter extends CustomPainter {
  /// Proportional progress of the slider (0.0 to 1.0).
  final double progress;

  /// Colors for the active portion of the track.
  final List<Color> colors;

  /// Background color for the inactive portion of the track.
  final Color inactiveColor;

  /// Border radius of the track.
  final double borderRadius;

  /// Number of segments or "dots" shown in the track.
  final int dotCount;

  /// Size of the thumb to account for its radius in track drawing.
  final double thumbSize;

  final double trackHeight;

  /// Custom colors for the decorative dots.
  final Color activeDotColor;
  final Color inactiveDotColor;

  SliderTrackPainter({
    required this.progress,
    required this.colors,
    required this.inactiveColor,
    required this.borderRadius,
    required this.dotCount,
    required this.thumbSize,
    required this.trackHeight,
    required this.activeDotColor,
    required this.inactiveDotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawInactiveTrack(canvas, size, Paint()..color = inactiveColor);
    _drawActiveTrack(canvas, size, Paint()..style = PaintingStyle.fill);
    _drawDots(canvas, size, Paint());
  }

  void _drawInactiveTrack(Canvas canvas, Size size, Paint paint) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _drawActiveTrack(Canvas canvas, Size size, Paint paint) {
    if (progress < 0) return;

    // To be perfectly concentric, the filling is a stadium from 0 to [activeWidth].
    // activeWidth ranges from [trackHeight] to [size.width].
    final double activeWidth = trackHeight + (progress * (size.width - trackHeight));
    
    paint.shader = LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, activeWidth, size.height));

    final RRect activeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, activeWidth, size.height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(activeRRect, paint);
    
    paint.shader = null;
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    if (dotCount <= 1) return;

    // To be consistent with the stadium geometry, dots should be positioned 
    // where the thumb center can actually go.
    // Thumb center ranges from [trackHeight/2] to [size.width - trackHeight/2].
    final double startX = trackHeight / 2;
    final double endX = size.width - trackHeight / 2;
    final double thumbCenterX = startX + (progress * (endX - startX));

    for (int i = 0; i < dotCount; i++) {
      final double dotProgress = i / (dotCount - 1);
      final double x = startX + (dotProgress * (endX - startX));
      
      // A dot is active if it's behind or at the thumb's current center
      final bool isActive = x <= thumbCenterX + 0.1; // Small epsilon for precision
      
      paint.color = isActive ? activeDotColor.withValues(alpha: 0.5) : inactiveDotColor;
      canvas.drawCircle(Offset(x, size.height / 2), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SliderTrackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.colors != colors ||
           oldDelegate.inactiveColor != inactiveColor ||
           oldDelegate.borderRadius != borderRadius ||
           oldDelegate.thumbSize != thumbSize;
  }
}
