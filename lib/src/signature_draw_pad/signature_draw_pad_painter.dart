import 'package:flutter/material.dart';
import 'signature_draw_pad_controller.dart';

/// Painter for the [SignatureDrawPad] widget.
class SignatureDrawPadPainter extends CustomPainter {
  /// Creates a new [SignatureDrawPadPainter].
  SignatureDrawPadPainter({
    required this.strokes,
    this.opacityValue = 1.0,
    this.playbackValue = 1.0,
    this.shimmerValue = 0.0,
    this.shimmerColor = Colors.white,
  });

  /// The strokes to draw.
  final List<SignatureStroke> strokes;

  /// The opacity of the background signature during playback (0.1 to 1.0).
  final double opacityValue;

  /// The progress of the playback animation (0.0 to 1.0).
  final double playbackValue;

  /// The progress of the shimmer effect (0.0 to 1.0).
  final double shimmerValue;

  /// The color of the shimmer effect.
  final Color shimmerColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    // Use a layer to support BlendMode.clear for erasers
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw the "background" signature (faded if playback is active)
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, stroke.isEraser ? 1.0 : opacityValue);
    }

    // 2. Draw the "playback" signature (animating the trace)
    if (playbackValue < 1.0 || (opacityValue < 1.0 && playbackValue >= 1.0)) {
      _drawPlayback(canvas, size);
    }

    // 3. Draw shimmer effect
    if (shimmerValue > 0.0 && shimmerValue < 1.0) {
      _drawShimmer(canvas, size);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, SignatureStroke stroke, double opacity) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.isEraser
          ? Colors.transparent
          : stroke.color.withValues(alpha: opacity)
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.isEraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = Colors.black; // Color doesn't matter for clear
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawPlayback(Canvas canvas, Size size) {
    double totalLength = 0;
    final List<_StrokeMetadata> metaList = [];

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final path = Path();
      path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }

      final metrics = path.computeMetrics();
      double strokeLength = 0;
      for (final metric in metrics) {
        strokeLength += metric.length;
      }

      totalLength += strokeLength;
      metaList.add(
        _StrokeMetadata(
          path: path,
          color: stroke.color,
          width: stroke.width,
          isEraser: stroke.isEraser,
        ),
      );
    }

    if (totalLength == 0) return;

    final targetLength = totalLength * playbackValue;
    double currentLength = 0;

    for (final meta in metaList) {
      if (currentLength >= targetLength) break;

      final paint = Paint()
        ..color = meta.isEraser ? Colors.black : meta.color
        ..strokeWidth = meta.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (meta.isEraser) {
        paint.blendMode = BlendMode.clear;
      }

      final metrics = meta.path.computeMetrics();
      for (final metric in metrics) {
        final remainingLength = targetLength - currentLength;
        if (remainingLength <= 0) break;

        final segmentLength = remainingLength < metric.length
            ? remainingLength
            : metric.length;
        final extractPath = metric.extractPath(0, segmentLength);
        canvas.drawPath(extractPath, paint);
        currentLength += segmentLength;
      }
    }
  }

  void _drawShimmer(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              shimmerColor.withValues(alpha: 0.0),
              shimmerColor.withValues(alpha: 0.5),
              shimmerColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(
              (shimmerValue * size.width * 2) - size.width,
              0,
              size.width,
              size.height,
            ),
          );

    // Only shimmer over the drawn area
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      shimmerPaint..blendMode = BlendMode.srcATop,
    );
  }

  @override
  bool shouldRepaint(covariant SignatureDrawPadPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.opacityValue != opacityValue ||
        oldDelegate.playbackValue != playbackValue ||
        oldDelegate.shimmerValue != shimmerValue;
  }
}

class _StrokeMetadata {
  _StrokeMetadata({
    required this.path,
    required this.color,
    required this.width,
    required this.isEraser,
  });
  final Path path;
  final Color color;
  final double width;
  final bool isEraser;
}
