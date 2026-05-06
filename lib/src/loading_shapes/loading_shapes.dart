import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'models/loading_shapes_style.dart';

/// A premium loading widget that morphs between different organic and geometric shapes.
///
/// This widget provides a "Pro Max" experience with smooth path interpolation,
/// subtle rotation, and physics-based motion.
class LoadingShapes extends StatefulWidget {
  /// Creates a new [LoadingShapes] instance.
  const LoadingShapes({
    super.key,
    this.style = const LoadingShapesStyle(),
    this.isLoading = true,
  });

  /// The style configuration for the loading shapes.
  final LoadingShapesStyle style;

  /// Whether the animation is currently active.
  final bool isLoading;

  @override
  State<LoadingShapes> createState() => _LoadingShapesState();
}

class _LoadingShapesState extends State<LoadingShapes>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;
  late Animation<double> _scaleAnimation;
  
  double _totalRotation = 0.0;
  late Ticker _rotationTicker;

  int _currentShapeIndex = 0;
  int _nextShapeIndex = 1;

  @override
  void initState() {
    super.initState();

    _morphController = AnimationController(
      vsync: this,
      duration: widget.style.transitionDuration,
    );

    // Main morphing animation
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: widget.style.transitionCurve,
    );

    // Scale animation: Subtle "breathing" during transition
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_morphController);

    // Continuous rotation ticker for perfectly fluid momentum
    _rotationTicker = createTicker((elapsed) {
      if (!mounted || !widget.isLoading) return;
      
      setState(() {
        // Base rotation speed from style
        double speed = widget.style.baseRotationSpeed; 
        
        // Add momentum boost during morphing using a bell curve (sin)
        if (_morphController.isAnimating) {
          final boostFactor = math.sin(_morphAnimation.value * math.pi);
          speed += boostFactor * widget.style.boostRotationSpeed;
        }
        
        _totalRotation += speed;
      });
    });

    _rotationTicker.start();

    _morphController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTransitionComplete();
      }
    });

    if (widget.isLoading) {
      _morphController.forward();
    }
  }

  void _onTransitionComplete() {
    if (!mounted) return;

    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    final shapes = widget.style.shapes;
    if (shapes.isEmpty) return;

    setState(() {
      _currentShapeIndex = _nextShapeIndex;
      _nextShapeIndex = (_nextShapeIndex + 1) % shapes.length;
    });

    _morphController.reset();

    if (widget.isLoading) {
      // Configurable delay before next transition for a custom "thinking" feel
      Future.delayed(widget.style.pauseDuration, () {
        if (mounted && widget.isLoading) {
          _morphController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(LoadingShapes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _morphController.forward();
      if (!_rotationTicker.isActive) _rotationTicker.start();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _rotationTicker.stop();
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _rotationTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shapes = widget.style.shapes;
    if (shapes.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _morphController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _totalRotation,
              child: CustomPaint(
                size: Size(widget.style.size, widget.style.size),
                painter: _ShapeMorphPainter(
                  currentShape: shapes[_currentShapeIndex],
                  nextShape: shapes[_nextShapeIndex],
                  progress: _morphAnimation.value,
                  style: widget.style,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShapeMorphPainter extends CustomPainter {
  /// Creates a new [_ShapeMorphPainter].
  const _ShapeMorphPainter({
    required this.currentShape,
    required this.nextShape,
    required this.progress,
    required this.style,
  });

  /// The current shape definition.
  final PortalShapeDefinition currentShape;

  /// The next shape definition.
  final PortalShapeDefinition nextShape;

  /// The transition progress between [currentShape] and [nextShape].
  final double progress;

  /// The style configuration.
  final LoadingShapesStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill;

    if (style.shadows != null) {
      for (final shadow in style.shadows!) {
        final shadowPaint = shadow.toPaint();
        canvas.drawPath(_getPath(size, progress), shadowPaint);
      }
    }

    canvas.drawPath(_getPath(size, progress), paint);

    if (style.borderWidth > 0) {
      final borderPaint = Paint()
        ..color = style.borderColor ?? style.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.borderWidth;
      canvas.drawPath(_getPath(size, progress), borderPaint);
    }
  }

  Path _getPath(Size size, double t) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Use a high number of points for smooth morphing
    const int totalPoints = 120;
    final points = <Offset>[];

    for (int i = 0; i <= totalPoints; i++) {
      final angle = (i / totalPoints) * 2 * math.pi;

      // Calculate radius for current shape at this angle
      final r1 = _getRadiusAtAngle(angle, currentShape, maxRadius);
      // Calculate radius for next shape at this angle
      final r2 = _getRadiusAtAngle(angle, nextShape, maxRadius);

      // Interpolate radius
      final r = lerpDouble(r1, r2, t)!;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    // Use Catmull-Rom or Cubic Bezier for smoothness
    // Here we use a simpler approach: smooth the interpolation by averaging radii or using a more organic formula
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
    }
    path.close();

    return path;
  }

  double _getRadiusAtAngle(double angle, PortalShapeDefinition def, double maxRadius) {
    final n = def.sides;
    
    // Polygon formula breaks for n < 3 (triangles are the minimum polygon)
    // For n < 3, we use a pure organic blob formula
    if (n < 3) {
      return maxRadius * (def.innerRadiusRatio + (1 - def.innerRadiusRatio) * (math.cos(angle * n) + 1) / 2);
    }

    final sectionAngle = (2 * math.pi) / n;
    final normalizedAngle = (angle % sectionAngle) - (sectionAngle / 2);

    // Polygon radius component
    final polyR = maxRadius * math.cos(math.pi / n) / math.cos(normalizedAngle);

    // Star/Blob component using sine wave
    final starR = maxRadius * (def.innerRadiusRatio + (1 - def.innerRadiusRatio) * (math.cos(angle * n) + 1) / 2);

    // Smoothness determines how much we lean towards the star/blob vs sharp polygon
    return lerpDouble(polyR, starR, def.smoothness)!;
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null || b == null) return null;
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(_ShapeMorphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentShape != currentShape ||
        oldDelegate.nextShape != nextShape;
  }
}
