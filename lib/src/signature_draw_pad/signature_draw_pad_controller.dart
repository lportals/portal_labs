import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data model for a single signature stroke.
class SignatureStroke {
  /// Creates a new [SignatureStroke].
  SignatureStroke({
    required this.points,
    required this.color,
    required this.width,
    this.isEraser = false,
  });

  /// The points that make up the stroke.
  final List<Offset> points;

  /// The color of the stroke.
  final Color color;

  /// The width of the stroke.
  final double width;

  /// Whether this stroke acts as an eraser.
  final bool isEraser;

  /// Creates a copy of this stroke with the given fields replaced.
  SignatureStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
    bool? isEraser,
  }) {
    return SignatureStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      isEraser: isEraser ?? this.isEraser,
    );
  }
}

/// Controller for the [SignatureDrawPad] widget.
class SignatureDrawPadController extends ChangeNotifier {
  /// Creates a new [SignatureDrawPadController].
  SignatureDrawPadController({
    Color initialColor = const Color(0xFF1D1D1F),
    double initialWidth = 3.0,
    this.enableHaptics = true,
  })  : _activeColor = initialColor,
        _strokeWidth = initialWidth;

  final List<SignatureStroke> _strokes = [];
  Color _activeColor;
  final double _strokeWidth;
  bool _isEraserMode = false;

  /// Whether haptic feedback is enabled.
  final bool enableHaptics;

  /// Returns the current list of strokes.
  List<SignatureStroke> get strokes => List.unmodifiable(_strokes);

  /// Returns the current active color.
  Color get activeColor => _activeColor;

  /// Sets the active color, updates existing strokes, and disables eraser mode.
  set activeColor(Color color) {
    if (_activeColor == color) return;
    _activeColor = color;
    _isEraserMode = false;

    // Update existing strokes to the new color (excluding erasers)
    for (int i = 0; i < _strokes.length; i++) {
      if (!_strokes[i].isEraser) {
        _strokes[i] = _strokes[i].copyWith(color: color);
      }
    }

    notifyListeners();
  }

  /// Returns whether eraser mode is active.
  bool get isEraserMode => _isEraserMode;

  /// Toggles eraser mode.
  void toggleEraser() {
    _isEraserMode = !_isEraserMode;
    if (enableHaptics) HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Starts a new stroke at the given [point].
  void startStroke(Offset point) {
    _strokes.add(SignatureStroke(
      points: [point],
      color: _isEraserMode ? Colors.transparent : _activeColor,
      width: _strokeWidth,
      isEraser: _isEraserMode,
    ));
    if (enableHaptics) HapticFeedback.selectionClick();
    notifyListeners();
  }

  /// Adds a [point] to the current stroke.
  void addPoint(Offset point) {
    if (_strokes.isEmpty) return;
    final lastStroke = _strokes.last;
    final updatedPoints = List<Offset>.from(lastStroke.points)..add(point);
    _strokes[_strokes.length - 1] = lastStroke.copyWith(points: updatedPoints);
    notifyListeners();
  }

  /// Removes the last stroke.
  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
      if (enableHaptics) HapticFeedback.mediumImpact();
      notifyListeners();
    }
  }

  /// Clears all strokes.
  void clear() {
    if (_strokes.isNotEmpty) {
      _strokes.clear();
      _isEraserMode = false;
      if (enableHaptics) HapticFeedback.heavyImpact();
      notifyListeners();
    }
  }

  /// Returns whether the pad is empty.
  bool get isEmpty => _strokes.isEmpty;

  /// Returns whether the pad has any strokes.
  bool get isNotEmpty => _strokes.isNotEmpty;

  /// Exports the current signature as a [ui.Image].
  ///
  /// [width] and [height] define the output image size.
  /// [padding] adds a margin around the signature.
  Future<ui.Image?> toImage({
    double width = 1000,
    double height = 500,
    double padding = 20.0,
  }) async {
    if (_strokes.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Calculate the bounding box of all strokes to center the signature
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in _strokes) {
      for (final point in stroke.points) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }
    }

    final signatureWidth = maxX - minX;
    final signatureHeight = maxY - minY;

    // Scale and translate to fit the output dimensions
    final scaleX = (width - padding * 2) / signatureWidth;
    final scaleY = (height - padding * 2) / signatureHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final translateX = (width - signatureWidth * scale) / 2 - minX * scale;
    final translateY = (height - signatureHeight * scale) / 2 - minY * scale;

    canvas.translate(translateX, translateY);
    canvas.scale(scale);

    for (final stroke in _strokes) {
      if (stroke.isEraser) {
        // Eraser in export clears the background (transparency)
        final paint = Paint()
          ..strokeWidth = stroke.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke;

        if (stroke.points.length > 1) {
          canvas.drawPoints(ui.PointMode.polygon, stroke.points, paint);
        }
      } else {
        final paint = Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        if (stroke.points.length > 1) {
          canvas.drawPoints(ui.PointMode.polygon, stroke.points, paint);
        }
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}
