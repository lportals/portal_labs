import 'package:flutter/material.dart';

/// Custom painter to draw the parallel line segments representing stages.
class StepLinesPainter extends CustomPainter {
  /// Creates a [StepLinesPainter] instance.
  const StepLinesPainter({
    required this.stepIndex,
    required this.color,
    required this.isSelected,
  });

  /// The index position of the tick or step on the selector track.
  final int stepIndex;

  /// The active color used to paint the line.
  final Color color;

  /// Whether this tick segment is currently within the active selection range.
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    
    const double lineWidth = 12.0;
    final double startX = (w - lineWidth) / 2;
    final double endX = startX + lineWidth;

    if (stepIndex == 0) {
      // Draw two lines close together, a space, and two lines close together to simulate group standings
      paint.strokeWidth = 2.0;
      canvas.drawLine(Offset(startX, h * 0.15), Offset(endX, h * 0.15), paint);
      canvas.drawLine(Offset(startX, h * 0.35), Offset(endX, h * 0.35), paint);
      
      canvas.drawLine(Offset(startX, h * 0.65), Offset(endX, h * 0.65), paint);
      canvas.drawLine(Offset(startX, h * 0.85), Offset(endX, h * 0.85), paint);
      return;
    }

    if (stepIndex == 5) {
      if (isSelected) {
        // Gold color (premium amber/gold shade)
        final goldColor = const Color(0xFFFFC107);
        final fillPaint = Paint()
          ..color = goldColor
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = goldColor
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // Cup body (filled)
        final cupPath = Path()
          ..moveTo(w / 2 - 4, h / 2 - 4)
          ..lineTo(w / 2 + 4, h / 2 - 4)
          ..lineTo(w / 2 + 2, h / 2 + 1)
          ..quadraticBezierTo(w / 2, h / 2 + 3, w / 2 - 2, h / 2 + 1)
          ..close();
        canvas.drawPath(cupPath, fillPaint);
        canvas.drawPath(cupPath, strokePaint);

        // Stem & base (stroke)
        final basePath = Path()
          ..moveTo(w / 2 - 1, h / 2 + 3)
          ..lineTo(w / 2 - 1, h / 2 + 5)
          ..moveTo(w / 2 + 1, h / 2 + 3)
          ..lineTo(w / 2 + 1, h / 2 + 5)
          ..moveTo(w / 2 - 2.5, h / 2 + 5)
          ..lineTo(w / 2 + 2.5, h / 2 + 5);
        canvas.drawPath(basePath, strokePaint);
      } else {
        // Draw normal outline in inactive color
        final path = Path()
          ..moveTo(w / 2 - 4, h / 2 - 4)
          ..lineTo(w / 2 + 4, h / 2 - 4)
          ..lineTo(w / 2 + 2, h / 2 + 1)
          ..quadraticBezierTo(w / 2, h / 2 + 3, w / 2 - 2, h / 2 + 1)
          ..close()
          ..moveTo(w / 2 - 1, h / 2 + 3)
          ..lineTo(w / 2 - 1, h / 2 + 5)
          ..moveTo(w / 2 + 1, h / 2 + 3)
          ..lineTo(w / 2 + 1, h / 2 + 5)
          ..moveTo(w / 2 - 2.5, h / 2 + 5)
          ..lineTo(w / 2 + 2.5, h / 2 + 5);
        canvas.drawPath(path, paint);
      }
      return;
    }

    // Number of lines: R32=5 (thin), R16=4, QF=2, SF=2
    int numLines = 4;
    double strokeW = 1.5;
    if (stepIndex == 1) {
      numLines = 5;
      strokeW = 0.8;
    } else if (stepIndex == 2) {
      numLines = 4;
      strokeW = 1.0;
    } else if (stepIndex == 3) {
      numLines = 2;
      strokeW = 1.2;
    } else if (stepIndex == 4) {
      numLines = 2;
      strokeW = 1.5;
    }

    paint.strokeWidth = strokeW;

    final double stepY = h / (numLines + 1);
    for (int i = 0; i < numLines; i++) {
      final double y = stepY * (i + 1);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StepLinesPainter oldDelegate) {
    return oldDelegate.color != color || 
           oldDelegate.stepIndex != stepIndex || 
           oldDelegate.isSelected != isSelected;
  }
}
