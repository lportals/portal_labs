import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'models/scratch_to_reveal_style.dart';

/// A controller for a [ScratchSurface] or [ScratchToReveal] component.
///
/// It allows programmatic control over the scratching state and 
/// provides access to the current reveal progress.
class ScratchController extends ChangeNotifier {
  double _progress = 0;
  bool _isCompleted = false;

  /// The current reveal progress from 0.0 to 1.0.
  double get progress => _progress;

  /// Whether the reveal has been completed (reached the threshold).
  bool get isCompleted => _isCompleted;

  /// Resets the scratch surface to its initial state.
  void reset() {
    _progress = 0;
    _isCompleted = false;
    notifyListeners();
  }

  /// Forces the surface to be fully revealed.
  void reveal() {
    _progress = 1.0;
    _isCompleted = true;
    notifyListeners();
  }

  /// Internal method to update progress from the surface.
  void updateProgress(double value) {
    if (_progress == value) return;
    _progress = value;
    notifyListeners();
  }

  /// Internal method to mark as completed.
  void complete() {
    if (_isCompleted) return;
    _isCompleted = true;
    notifyListeners();
  }
}

/// A high-fidelity "Scratch to Reveal" card component.
///
/// This is a pre-composed "Premium" component that includes a header,
/// a title, and a [ScratchSurface] wrapped in a styled card.
class ScratchToReveal extends StatefulWidget {
  /// Creates a [ScratchToReveal] card.
  const ScratchToReveal({
    super.key,
    required this.child,
    required this.title,
    this.icon = Icons.apple_rounded,
    this.style = ScratchToRevealStyle.premium,
    this.onCompleted,
    this.label = 'Scratch to reveal',
    this.resetLabel = 'Start again',
    this.controller,
  });

  /// The hidden content to be revealed.
  final Widget child;

  /// The title of the card.
  final String title;

  /// The icon displayed next to the title.
  final IconData icon;

  /// The visual configuration.
  final ScratchToRevealStyle style;

  /// Called when the reveal is completed.
  final VoidCallback? onCompleted;

  /// The text displayed on the surface.
  final String label;

  /// The text for the reset button.
  final String resetLabel;

  /// Optional controller to manage the scratch state.
  final ScratchController? controller;

  @override
  State<ScratchToReveal> createState() => _ScratchToRevealState();
}

class _ScratchToRevealState extends State<ScratchToReveal> {
  late ScratchController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? ScratchController();
    _internalController.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(ScratchToReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _internalController = widget.controller ?? ScratchController();
      _internalController.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    } else {
      _internalController.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.cornerRadius * 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: ScratchSurface(
              controller: _internalController,
              style: widget.style,
              onCompleted: widget.onCompleted,
              label: widget.label,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(widget.icon, size: 24, color: Colors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: widget.style.titleStyle,
          ),
        ),
        if (_internalController.isCompleted)
          GestureDetector(
            onTap: () {
              _internalController.reset();
              HapticFeedback.heavyImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                widget.resetLabel,
                style: widget.style.resetButtonStyle,
              ),
            ),
          )
        else
          const _SmallMenuIcon(),
      ],
    );
  }
}

/// A standalone scratchable surface.
///
/// Can be used independently of the [ScratchToReveal] card structure.
class ScratchSurface extends StatefulWidget {
  /// Creates a [ScratchSurface].
  const ScratchSurface({
    super.key,
    required this.child,
    this.controller,
    this.style = ScratchToRevealStyle.premium,
    this.onCompleted,
    this.label = 'Scratch to reveal',
    this.onProgress,
  });

  /// The hidden content underneath.
  final Widget child;

  /// Optional controller.
  final ScratchController? controller;

  /// Visual style configuration.
  final ScratchToRevealStyle style;

  /// Called when reveal completion threshold is reached.
  final VoidCallback? onCompleted;

  /// Text overlay on the scratch surface.
  final String label;

  /// Called when progress changes.
  final ValueChanged<double>? onProgress;

  @override
  State<ScratchSurface> createState() => _ScratchSurfaceState();
}

class _ScratchSurfaceState extends State<ScratchSurface> 
    with TickerProviderStateMixin {
  
  late ScratchController _controller;
  final List<List<Offset>> _paths = [];
  final List<_JaggedShard> _jaggedShards = [];
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Particle Physics System
  late Ticker _ticker;
  final List<_ScratchParticle> _particles = [];
  Duration _lastElapsed = Duration.zero;
  final math.Random _random = math.Random();

  final Set<int> _scratchedCells = {};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScratchController();
    _controller.addListener(_onInternalControllerChanged);

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _ticker = createTicker(_onTick);
    _ticker.start();

    if (_controller.isCompleted) {
      _fadeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScratchSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onInternalControllerChanged);
      _controller = widget.controller ?? ScratchController();
      _controller.addListener(_onInternalControllerChanged);
    }
  }

  void _onInternalControllerChanged() {
    if (_controller.isCompleted && !_fadeController.isAnimating && _fadeController.value == 0) {
      _fadeController.forward();
      widget.onCompleted?.call();
    } else if (!_controller.isCompleted && _fadeController.value > 0) {
      _resetState();
    }
    if (mounted) setState(() {});
  }

  void _resetState() {
    _paths.clear();
    _jaggedShards.clear();
    _scratchedCells.clear();
    _particles.clear();
    _fadeController.reset();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onInternalControllerChanged);
    }
    _fadeController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    if (_particles.isEmpty) return;

    bool needsPaint = false;
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt * 2.5;
      if (p.life <= 0) {
        _particles.removeAt(i);
      } else {
        p.velocity += const Offset(0, 1200) * dt; 
        p.position += p.velocity * dt;
        p.angle += p.angularVelocity * dt;
        needsPaint = true;
      }
    }

    if (needsPaint && mounted) {
      setState(() {});
    }
  }

  void _spawnParticles(Offset position) {
    int count = _random.nextInt(4) + 2; 
    for (int i = 0; i < count; i++) {
        final double dx = (_random.nextDouble() - 0.5) * 300;
        final double dy = (_random.nextDouble() - 0.5) * 300 - 150; 
        final double size = _random.nextDouble() * 5 + 2; 
        
        _particles.add(_ScratchParticle(
            position: position + Offset((_random.nextDouble() - 0.5) * widget.style.brushSize, (_random.nextDouble() - 0.5) * widget.style.brushSize),
            velocity: Offset(dx, dy),
            angle: _random.nextDouble() * math.pi * 2,
            angularVelocity: (_random.nextDouble() - 0.5) * 15,
            size: size,
        ));
    }
  }

  void _addJaggedEdges(Offset position) {
    int count = _random.nextInt(3) + 2; 
    for (int i = 0; i < count; i++) {
      final double offsetRadius = widget.style.brushSize * 0.5;
      final double dx = (_random.nextDouble() - 0.5) * offsetRadius * 2;
      final double dy = (_random.nextDouble() - 0.5) * offsetRadius * 2;
      final double size = _random.nextDouble() * (widget.style.brushSize * 0.4) + (widget.style.brushSize * 0.1);
      final double angle = _random.nextDouble() * math.pi * 2;
      
      _jaggedShards.add(_JaggedShard(
        position: position + Offset(dx, dy), 
        size: size,
        angle: angle,
      ));
    }
  }

  bool _trackGridCoverage(Offset point, Size size) {
    final double cellWidth = size.width / widget.style.gridColumns;
    final double cellHeight = size.height / widget.style.gridRows;
    
    final int centerX = (point.dx / cellWidth).floor();
    final int centerY = (point.dy / cellHeight).floor();

    bool addedNew = false;
    for (int x = centerX - 1; x <= centerX + 1; x++) {
      for (int y = centerY - 1; y <= centerY + 1; y++) {
        if (x >= 0 && x < widget.style.gridColumns && y >= 0 && y < widget.style.gridRows) {
          if (_scratchedCells.add(y * widget.style.gridColumns + x)) {
            addedNew = true;
          }
        }
      }
    }
    return addedNew;
  }

  double _calculateCoverage() {
    int targetTotal = 0;
    int targetScratched = 0;
    
    const int marginX = 2;
    const int marginY = 2;
    
    for (int x = marginX; x < widget.style.gridColumns - marginX; x++) {
      for (int y = marginY; y < widget.style.gridRows - marginY; y++) {
        targetTotal++;
        if (_scratchedCells.contains(y * widget.style.gridColumns + x)) {
          targetScratched++;
        }
      }
    }
    
    final coverage = targetTotal == 0 ? 0.0 : targetScratched / targetTotal;
    _controller.updateProgress(coverage);
    widget.onProgress?.call(coverage);
    return coverage;
  }

  void _handleCompletion() {
    _controller.complete();
    _fadeController.forward();
    HapticFeedback.mediumImpact();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(widget.style.cornerRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Revealed Content with Entry Animation
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    final double scale = 0.95 + (_fadeAnimation.value * 0.05);
                    return Transform.scale(
                      scale: _controller.isCompleted ? scale : 1.0,
                      child: Opacity(
                        opacity: _controller.isCompleted ? _fadeAnimation.value : 0.8,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: (1.0 - _fadeAnimation.value) * 0.2),
                            BlendMode.srcATop,
                          ),
                          child: widget.child,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Scratch Layer
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (d) {
                    if (_controller.isCompleted) return;
                    setState(() {
                      _paths.add([d.localPosition]);
                      if (_trackGridCoverage(d.localPosition, size)) {
                        _spawnParticles(d.localPosition);
                        _addJaggedEdges(d.localPosition);
                        HapticFeedback.lightImpact();
                      }
                    });
                  },
                  onPanUpdate: (d) {
                    if (_controller.isCompleted) return;
                    setState(() {
                      if (_paths.isNotEmpty) {
                        _paths.last.add(d.localPosition);
                      }
                      if (_trackGridCoverage(d.localPosition, size)) {
                        _spawnParticles(d.localPosition);
                        _addJaggedEdges(d.localPosition);
                      }
                    });

                    if (!_controller.isCompleted && _calculateCoverage() > widget.style.successThreshold) {
                      _handleCompletion();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: (1.0 - _fadeAnimation.value).clamp(0.0, 1.0),
                        child: CustomPaint(
                          painter: _ScratchPainter(
                            paths: _paths,
                            jaggedShards: _jaggedShards,
                            particles: _particles,
                            style: widget.style,
                            label: widget.label,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScratchParticle {
  _ScratchParticle({
    required this.position,
    required this.velocity,
    required this.angle,
    required this.angularVelocity,
    required this.size,
  }) : life = 1.0;

  Offset position;
  Offset velocity;
  double angle;
  double angularVelocity;
  double size;
  double life;
}

class _JaggedShard {
  _JaggedShard({
    required this.position,
    required this.size,
    required this.angle,
  });

  final Offset position;
  final double size;
  final double angle;
}

class _ScratchPainter extends CustomPainter {
  _ScratchPainter({
    required this.paths,
    required this.jaggedShards,
    required this.particles,
    required this.style,
    required this.label,
  });

  final List<List<Offset>> paths;
  final List<_JaggedShard> jaggedShards;
  final List<_ScratchParticle> particles;
  final ScratchToRevealStyle style;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(style.cornerRadius)),
      Paint()..color = style.surfaceColor,
    );

    _drawGrid(canvas, size);
    _drawLabel(canvas, size);

    final Paint scratchPaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = style.brushSize
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.bevel
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      if (path.length > 1) {
        final Path scratchPath = Path();
        scratchPath.moveTo(path[0].dx, path[0].dy);
        for (int i = 1; i < path.length; i++) {
          scratchPath.lineTo(path[i].dx, path[i].dy);
        }
        canvas.drawPath(scratchPath, scratchPaint);
      } else if (path.isNotEmpty) {
        canvas.drawRect(
          Rect.fromCenter(center: path[0], width: style.brushSize, height: style.brushSize), 
          scratchPaint..style = PaintingStyle.fill,
        );
        scratchPaint.style = PaintingStyle.stroke;
      }
    }

    final Paint shardPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    
    for (final shard in jaggedShards) {
      canvas.save();
      canvas.translate(shard.position.dx, shard.position.dy);
      canvas.rotate(shard.angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: shard.size, height: shard.size), 
        shardPaint,
      );
      canvas.restore();
    }

    canvas.restore();

    final Paint particlePaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.angle);
      particlePaint.color = style.particleColor.withValues(alpha: p.life.clamp(0.0, 1.0));
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size), 
        particlePaint,
      );
      canvas.restore();
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = style.gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    const double spacing = 14.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), gridPaint);
    }
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i - size.height, size.height), gridPaint);
    }
  }

  void _drawLabel(Canvas canvas, Size size) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: label, style: style.labelTextStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 60);

    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) => true;
}

class _SmallMenuIcon extends StatelessWidget {
  const _SmallMenuIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black),
    );
  }
}
