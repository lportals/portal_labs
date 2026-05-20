import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'models/physics_collision_card_style.dart';

/// Represents an item configured to float and collide inside the [PhysicsCollisionCard].
class PhysicsCollisionItem {
  /// Creates a [PhysicsCollisionItem] to be simulated in the physics card.
  const PhysicsCollisionItem({
    required this.child,
    required this.radius,
    this.mass,
    this.initialPosition,
    this.initialVelocity = Offset.zero,
    this.decoration,
    this.clipToCircle = true,
  });

  /// The visual widget to display inside the physics body (e.g. an image).
  final Widget child;

  /// The circular collision radius of the item.
  final double radius;

  /// The mass of the item. If null, the mass is automatically calculated
  /// proportional to the circle's area (radius squared).
  final double? mass;

  /// Optional initial position (relative to the top-left of the container).
  /// If null, a random non-overlapping position is calculated.
  final Offset? initialPosition;

  /// The initial velocity of the item in pixels/second. Defaults to [Offset.zero].
  final Offset initialVelocity;

  /// Optional decoration override. If set, this item uses this decoration
  /// instead of the global [PhysicsCollisionCardStyle.itemDecoration].
  /// Useful for transparent items.
  final BoxDecoration? decoration;

  /// Whether to clip the child using a ClipOval.
  /// Defaults to true, which is ideal for photo avatars.
  /// Set to false for transparent PNGs or custom shapes.
  final bool clipToCircle;
}

/// An interactive container widget that simulates realistic rigid-body 2D physics.
///
/// Children are represented as circular bodies that experience gravity,
/// bounce off boundary walls, collide with each other elastically, and
/// can be dragged/thrown using natural gestures.
class PhysicsCollisionCard extends StatefulWidget {
  /// Creates a [PhysicsCollisionCard] simulation container.
  const PhysicsCollisionCard({
    super.key,
    required this.items,
    this.style = const PhysicsCollisionCardStyle(),
    this.width = double.infinity,
    this.height = 300.0,
  });

  /// The list of items to place and simulate within the card.
  final List<PhysicsCollisionItem> items;

  /// The style configuration defining gravity, bounciness, damping, and borders.
  final PhysicsCollisionCardStyle style;

  /// The width of the card. Defaults to [double.infinity].
  final double width;

  /// The height of the card. Defaults to 300.0.
  final double height;

  @override
  State<PhysicsCollisionCard> createState() => _PhysicsCollisionCardState();
}

class _PhysicsCollisionCardState extends State<PhysicsCollisionCard>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_PhysicsBody> _bodies = [];
  Size _containerSize = Size.zero;

  double _lastElapsedSeconds = 0.0;
  bool _isSleeping = false;
  int _restFrames = 0;
  DateTime? _lastHapticTime;

  @override
  void initState() {
    super.initState();
    // Initialize ticker for high-performance updates
    _ticker = createTicker(_updatePhysics);
  }

  @override
  void didUpdateWidget(covariant PhysicsCollisionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the item configuration has changed, rebuild bodies and wake up simulation
    if (oldWidget.items != widget.items) {
      _initializePositions();
      _wakeUp();
    } else if (oldWidget.style.gravity != widget.style.gravity ||
        oldWidget.style.restitution != widget.style.restitution ||
        oldWidget.style.damping != widget.style.damping) {
      _wakeUp();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Initial spawn logic for items. Positions them safely inside boundaries.
  void _initializePositions() {
    if (_containerSize == Size.zero) return;
    _bodies.clear();

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final radius = item.radius;
      final mass = item.mass ?? (radius * radius);

      Offset spawnPos;
      if (item.initialPosition != null) {
        // Clamp spawn position inside container borders
        spawnPos = Offset(
          item.initialPosition!.dx.clamp(radius, _containerSize.width - radius),
          item.initialPosition!.dy.clamp(
            radius,
            _containerSize.height - radius,
          ),
        );
      } else {
        spawnPos = _findRandomNonOverlappingPosition(radius);
      }

      _bodies.add(
        _PhysicsBody(
          id: i,
          position: spawnPos,
          velocity: item.initialVelocity,
          radius: radius,
          mass: mass,
          child: item.child,
          lastDragPosition: spawnPos,
          decoration: item.decoration,
          clipToCircle: item.clipToCircle,
        ),
      );
    }
  }

  /// Finds a random coordinates offset inside the card container that does
  /// not overlap with previously placed bodies. Falls back to random overlap.
  Offset _findRandomNonOverlappingPosition(double radius) {
    final rand = math.Random();
    const int maxAttempts = 20;

    final double minX = radius;
    final double maxX = math.max(minX, _containerSize.width - radius);
    final double minY = radius;
    final double maxY = math.max(minY, _containerSize.height - radius);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final rx = minX + rand.nextDouble() * (maxX - minX);
      final ry = minY + rand.nextDouble() * (maxY - minY);
      final testPos = Offset(rx, ry);

      bool hasOverlap = false;
      for (final body in _bodies) {
        final dist = (body.position - testPos).distance;
        if (dist < (body.radius + radius)) {
          hasOverlap = true;
          break;
        }
      }

      if (!hasOverlap) {
        return testPos;
      }
    }

    // Default fallback position
    final rx = minX + rand.nextDouble() * (maxX - minX);
    final ry = minY + rand.nextDouble() * (maxY - minY);
    return Offset(rx, ry);
  }

  /// Wakes the physics engine ticker from sleep state.
  void _wakeUp() {
    if (_isSleeping || !_ticker.isActive) {
      _isSleeping = false;
      _restFrames = 0;
      _lastElapsedSeconds = 0.0;
      if (!_ticker.isActive) {
        _ticker.start();
      }
    }
  }

  /// Standard physics updates triggered every frame by the ticker callback.
  void _updatePhysics(Duration elapsed) {
    if (_containerSize == Size.zero) return;

    final double elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (_lastElapsedSeconds == 0.0) {
      _lastElapsedSeconds = elapsedSeconds;
      return;
    }

    double dt = elapsedSeconds - _lastElapsedSeconds;
    _lastElapsedSeconds = elapsedSeconds;

    // Clamp dt to prevent physical simulation exploding on massive frame lag
    if (dt > 0.03) dt = 0.03;
    if (dt <= 0.0) return;

    // Sub-stepping for collision accuracy (run physics engine multiple ticks per frame)
    const int subSteps = 4;
    final double subDt = dt / subSteps;

    final gravity = widget.style.gravity;
    final damping = widget.style.damping;
    final restitution = widget.style.restitution;

    for (int step = 0; step < subSteps; step++) {
      // 1. Position and rotation integration
      for (final body in _bodies) {
        if (body.isDragged) continue;

        body.velocity += gravity * subDt;
        // Velocity air resistance damping
        body.velocity *= (1.0 - damping * subDt);
        body.position += body.velocity * subDt;

        // Rotation integration and friction damping
        body.angle += body.angularVelocity * subDt;
        body.angularVelocity *= (1.0 - damping * subDt);
      }

      // 2. Wall collision resolutions
      for (final body in _bodies) {
        _resolveWallCollision(
          body,
          _containerSize.width,
          _containerSize.height,
          restitution,
        );
      }

      // 3. Circle-to-Circle elastic body collisions
      for (int i = 0; i < _bodies.length; i++) {
        for (int j = i + 1; j < _bodies.length; j++) {
          _resolveBodyCollision(_bodies[i], _bodies[j], restitution);
        }
      }
    }

    // 4. Auto-sleep manager checks if all objects are resting
    bool allResting = true;
    for (final body in _bodies) {
      if (body.isDragged) {
        allResting = false;
        break;
      }
      if (body.velocity.distanceSquared > 0.1 ||
          body.angularVelocity.abs() > 0.05) {
        allResting = false;
        break;
      }
    }

    if (allResting) {
      _restFrames++;
      if (_restFrames > 30) {
        _ticker.stop();
        _isSleeping = true;
        _restFrames = 0;
      }
    } else {
      _restFrames = 0;
    }

    setState(() {});
  }

  /// Resolves bounds collision with wall boundaries.
  void _resolveWallCollision(
    _PhysicsBody body,
    double width,
    double height,
    double restitution,
  ) {
    bool collided = false;
    double bounceSpeed = 0.0;
    final r = body.radius;

    // Horizontal boundaries (left / right walls)
    if (body.position.dx - r < 0) {
      body.position = Offset(r, body.position.dy);
      if (body.velocity.dx < 0) {
        final double normalSpeed = body.velocity.dx.abs();
        final double oldVx = body.velocity.dx;
        body.velocity = Offset(-oldVx * restitution, body.velocity.dy);

        // Apply wall friction: tangent component is velocity.dy
        final double surfaceVelocity =
            body.velocity.dy - body.angularVelocity * r;
        double deltaVt = -surfaceVelocity / 3.0;
        double maxFriction = 0.3 * normalSpeed * (1.0 + restitution);
        final double limit = maxFriction.isNaN || maxFriction.isInfinite
            ? 0.0
            : maxFriction.abs();
        deltaVt = deltaVt.clamp(-limit, limit);

        body.velocity = Offset(body.velocity.dx, body.velocity.dy + deltaVt);
        body.angularVelocity -= deltaVt * 2.0 / r;

        bounceSpeed = normalSpeed;
        collided = true;
      }
    } else if (body.position.dx + r > width) {
      body.position = Offset(width - r, body.position.dy);
      if (body.velocity.dx > 0) {
        final double normalSpeed = body.velocity.dx.abs();
        final double oldVx = body.velocity.dx;
        body.velocity = Offset(-oldVx * restitution, body.velocity.dy);

        // Apply wall friction: tangent component is -velocity.dy
        final double surfaceVelocity =
            -body.velocity.dy - body.angularVelocity * r;
        double deltaVt = -surfaceVelocity / 3.0;
        double maxFriction = 0.3 * normalSpeed * (1.0 + restitution);
        final double limit = maxFriction.isNaN || maxFriction.isInfinite
            ? 0.0
            : maxFriction.abs();
        deltaVt = deltaVt.clamp(-limit, limit);

        body.velocity = Offset(body.velocity.dx, body.velocity.dy - deltaVt);
        body.angularVelocity -= deltaVt * 2.0 / r;

        bounceSpeed = normalSpeed;
        collided = true;
      }
    }

    // Vertical boundaries (top / bottom walls)
    if (body.position.dy - r < 0) {
      body.position = Offset(body.position.dx, r);
      if (body.velocity.dy < 0) {
        final double normalSpeed = body.velocity.dy.abs();
        final double oldVy = body.velocity.dy;
        body.velocity = Offset(body.velocity.dx, -oldVy * restitution);

        // Apply wall friction: tangent component is -velocity.dx
        final double surfaceVelocity =
            -body.velocity.dx - body.angularVelocity * r;
        double deltaVt = -surfaceVelocity / 3.0;
        double maxFriction = 0.3 * normalSpeed * (1.0 + restitution);
        final double limit = maxFriction.isNaN || maxFriction.isInfinite
            ? 0.0
            : maxFriction.abs();
        deltaVt = deltaVt.clamp(-limit, limit);

        body.velocity = Offset(body.velocity.dx - deltaVt, body.velocity.dy);
        body.angularVelocity -= deltaVt * 2.0 / r;

        bounceSpeed = normalSpeed;
        collided = true;
      }
    } else if (body.position.dy + r > height) {
      body.position = Offset(body.position.dx, height - r);
      if (body.velocity.dy > 0) {
        final double normalSpeed = body.velocity.dy.abs();
        final double oldVy = body.velocity.dy;
        body.velocity = Offset(body.velocity.dx, -oldVy * restitution);

        // Apply wall friction: tangent component is velocity.dx
        final double surfaceVelocity =
            body.velocity.dx - body.angularVelocity * r;
        double deltaVt = -surfaceVelocity / 3.0;
        double maxFriction = 0.3 * normalSpeed * (1.0 + restitution);
        final double limit = maxFriction.isNaN || maxFriction.isInfinite
            ? 0.0
            : maxFriction.abs();
        deltaVt = deltaVt.clamp(-limit, limit);

        body.velocity = Offset(body.velocity.dx + deltaVt, body.velocity.dy);
        body.angularVelocity -= deltaVt * 2.0 / r;

        bounceSpeed = normalSpeed;
        collided = true;
      }
    }

    if (collided) {
      _triggerHaptics(bounceSpeed);
    }
  }

  /// Resolves collision between two circles.
  void _resolveBodyCollision(
    _PhysicsBody b1,
    _PhysicsBody b2,
    double restitution,
  ) {
    final Offset normal = b2.position - b1.position;
    final double dist = normal.distance;
    final double minDist = b1.radius + b2.radius;

    if (dist >= minDist || dist == 0) return;

    // 1. Separation / penetration depth correction
    final double overlap = minDist - dist;
    final Offset normalUnit = normal / dist;

    if (b1.isDragged && b2.isDragged) {
      return;
    } else if (b1.isDragged) {
      b2.position += normalUnit * overlap;
    } else if (b2.isDragged) {
      b1.position -= normalUnit * overlap;
    } else {
      // Split separation force based on inverse masses
      final double totalMass = b1.mass + b2.mass;
      b1.position -= normalUnit * overlap * (b2.mass / totalMass);
      b2.position += normalUnit * overlap * (b1.mass / totalMass);
    }

    // 2. Resolve elastic velocities along collision normal
    final Offset relVelocity = b2.velocity - b1.velocity;
    final double velAlongNormal =
        relVelocity.dx * normalUnit.dx + relVelocity.dy * normalUnit.dy;

    // Do not resolve if velocities are already separating
    if (velAlongNormal > 0) return;

    final double m1Inv = b1.isDragged ? 0.0 : (1.0 / b1.mass);
    final double m2Inv = b2.isDragged ? 0.0 : (1.0 / b2.mass);
    if (m1Inv + m2Inv == 0.0) return;

    final double impulseScalar =
        -(1.0 + restitution) * velAlongNormal / (m1Inv + m2Inv);
    final Offset impulse = normalUnit * impulseScalar;

    if (!b1.isDragged) {
      b1.velocity -= impulse * m1Inv;
    }
    if (!b2.isDragged) {
      b2.velocity += impulse * m2Inv;
    }

    // 3. Resolve friction and rotational angular momentum (tangent friction)
    final Offset tangentUnit = Offset(-normalUnit.dy, normalUnit.dx);
    final double relVelTangent =
        (b2.velocity.dx - b1.velocity.dx) * tangentUnit.dx +
        (b2.velocity.dy - b1.velocity.dy) * tangentUnit.dy;

    // Relative velocity at the contact point including angular velocities
    final double rotVel1 = b1.angularVelocity * b1.radius;
    final double rotVel2 = b2.angularVelocity * b2.radius;
    final double relTangentSpeed = relVelTangent - (rotVel1 + rotVel2);

    final double totalInvMass = m1Inv + m2Inv;
    if (totalInvMass > 0.0) {
      // Moment of inertia for disk: I = 0.5 * m * r^2  =>  r^2 / I = 2 / m
      final double inertia1 = b1.isDragged ? 0.0 : (2.0 * m1Inv);
      final double inertia2 = b2.isDragged ? 0.0 : (2.0 * m2Inv);

      double tangentImpulse =
          -relTangentSpeed / (totalInvMass + inertia1 + inertia2);

      // Coulomb's law friction cap: |tangentImpulse| <= mu * normalImpulse
      const double mu = 0.35; // coefficient of friction
      double maxFriction = mu * impulseScalar;
      final double limit = maxFriction.isNaN || maxFriction.isInfinite
          ? 0.0
          : maxFriction.abs();
      tangentImpulse = tangentImpulse.clamp(-limit, limit);

      final Offset tangentImpulseVec = tangentUnit * tangentImpulse;
      if (!b1.isDragged) {
        b1.velocity -= tangentImpulseVec * m1Inv;
        b1.angularVelocity -= tangentImpulse * (m1Inv * 2.0 / b1.radius);
      }
      if (!b2.isDragged) {
        b2.velocity += tangentImpulseVec * m2Inv;
        b2.angularVelocity -= tangentImpulse * (m2Inv * 2.0 / b2.radius);
      }
    }

    _triggerHaptics(impulseScalar);
  }

  /// Triggers collision vibration haptics with rate-throttling to keep the feel premium.
  void _triggerHaptics(double force) {
    if (!widget.style.enableHaptics) return;
    if (force > widget.style.hapticThreshold) {
      final now = DateTime.now();
      if (_lastHapticTime == null ||
          now.difference(_lastHapticTime!).inMilliseconds > 80) {
        HapticFeedback.lightImpact();
        _lastHapticTime = now;
      }
    }
  }

  /// Gesture callbacks for handling manual grabbing and throwing physics.
  void _onDragStart(
    _PhysicsBody body,
    DragStartDetails details,
    Offset localOffset,
  ) {
    _wakeUp();
    body.isDragged = true;
    body.velocity = Offset.zero;
    body.lastDragTime = DateTime.now();
    body.lastDragPosition = body.position;
    setState(() {});
  }

  void _onDragUpdate(_PhysicsBody body, DragUpdateDetails details) {
    if (_containerSize == Size.zero) return;

    // Use gesture delta directly to transition position smoothly
    final Offset newPos = body.position + details.delta;
    final double r = body.radius;

    final double oldX = body.position.dx;
    body.position = Offset(
      newPos.dx.clamp(r, _containerSize.width - r),
      newPos.dy.clamp(r, _containerSize.height - r),
    );

    // Roll rotation matching the drag distance delta
    final double deltaX = body.position.dx - oldX;
    body.angle += deltaX / r;

    // Track instant velocity and spin calculation for throwing mechanics
    final DateTime now = DateTime.now();
    final double dt =
        now.difference(body.lastDragTime).inMicroseconds /
        Duration.microsecondsPerSecond;

    if (dt > 0.001) {
      final Offset instantVelocity =
          (body.position - body.lastDragPosition) / dt;
      // Exponential moving average filter for velocity smoothing
      body.velocity =
          Offset.lerp(body.velocity, instantVelocity, 0.4) ?? instantVelocity;

      // Track rotational spin induced by horizontal dragging motion
      final double instantAngularVelocity =
          (body.position.dx - body.lastDragPosition.dx) / r / dt;
      body.angularVelocity =
          (body.angularVelocity * 0.6) + (instantAngularVelocity * 0.4);
    }

    body.lastDragTime = now;
    body.lastDragPosition = body.position;
    setState(() {});
  }

  void _onDragEnd(_PhysicsBody body, DragEndDetails details) {
    body.isDragged = false;
    final Offset gestureVelocity = details.velocity.pixelsPerSecond;

    // Use native platform gesture speed tracker if significant, else fallback to manual calculations
    if (gestureVelocity.distanceSquared > 100.0) {
      body.velocity = _clampSpeed(gestureVelocity, 2200.0);
    } else {
      body.velocity = _clampSpeed(body.velocity, 2200.0);
    }

    // Clamp spin to prevent extreme rotation speeds upon throw release
    body.angularVelocity = body.angularVelocity.clamp(-40.0, 40.0);
    setState(() {});
  }

  Offset _clampSpeed(Offset velocity, double maxSpeed) {
    final double speed = velocity.distance;
    if (speed > maxSpeed) {
      return (velocity / speed) * maxSpeed;
    }
    return velocity;
  }

  void _handleResize(Size newSize) {
    if (_containerSize == newSize) return;

    final bool isFirstLayout = _containerSize == Size.zero;
    _containerSize = newSize;

    if (isFirstLayout) {
      _initializePositions();
      _wakeUp();
    } else {
      // Re-clamp all body locations to fit inside modified dimensions
      for (final body in _bodies) {
        final r = body.radius;
        body.position = Offset(
          body.position.dx.clamp(r, newSize.width - r),
          body.position.dy.clamp(r, newSize.height - r),
        );
      }
      _wakeUp();
    }
    setState(() {});
  }

  Widget _buildBodyWidget(_PhysicsBody body) {
    final double size = body.radius * 2;
    final double scale = body.isDragged ? 1.08 : 1.0;

    return Positioned(
      left: body.position.dx - body.radius,
      top: body.position.dy - body.radius,
      width: size,
      height: size,
      child: GestureDetector(
        onPanStart: (details) =>
            _onDragStart(body, details, details.localPosition),
        onPanUpdate: (details) => _onDragUpdate(body, details),
        onPanEnd: (details) => _onDragEnd(body, details),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            width: size,
            height: size,
            decoration: body.decoration ?? widget.style.itemDecoration,
            clipBehavior: body.clipToCircle ? Clip.antiAlias : Clip.none,
            child: Transform.rotate(
              angle: body.angle,
              child: body.clipToCircle
                  ? ClipOval(child: body.child)
                  : body.child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isInfinite
            ? widget.width.isInfinite
                  ? 350.0
                  : widget.width
            : constraints.maxWidth;
        final double height = constraints.maxHeight.isInfinite
            ? widget.height.isInfinite
                  ? 300.0
                  : widget.height
            : constraints.maxHeight;

        final double padHorizontal =
            widget.style.gridPadding.left + widget.style.gridPadding.right;
        final double padVertical =
            widget.style.gridPadding.top + widget.style.gridPadding.bottom;

        final double innerWidth = (width - padHorizontal).clamp(
          0.0,
          double.infinity,
        );
        final double innerHeight = (height - padVertical).clamp(
          0.0,
          double.infinity,
        );

        // Schedule bounds sync check
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleResize(Size(innerWidth, innerHeight));
          }
        });

        return Container(
          width: width,
          height: height,
          decoration: widget.style.cardDecoration,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: widget.style.gridPadding,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration:
                  widget.style.gridDecoration ??
                  BoxDecoration(
                    color: widget.style.gridBackgroundColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: widget.style.gridColor.withAlpha(
                        (255 * 0.4).round(),
                      ),
                    ),
                  ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (widget.style.showGrid)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(
                          gridColor: widget.style.gridColor,
                        ),
                      ),
                    ),
                  if (widget.style.showStars)
                    const Positioned.fill(
                      child: CustomPaint(painter: _StarPainter()),
                    ),
                  for (final body in _bodies) _buildBodyWidget(body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Internal helper model holding tracking variables for simulated physical bodies.
class _PhysicsBody {
  _PhysicsBody({
    required this.id,
    required this.position,
    required this.velocity,
    required this.radius,
    required this.mass,
    required this.child,
    required this.lastDragPosition,
    this.decoration,
    this.clipToCircle = true,
  });

  final int id;
  Offset position;
  Offset velocity;
  double angle = 0.0;
  double angularVelocity = 0.0;
  final double radius;
  final double mass;
  final Widget child;
  final BoxDecoration? decoration;
  final bool clipToCircle;

  // Gesture tracking variables
  bool isDragged = false;
  Offset dragOffset = Offset.zero;
  DateTime lastDragTime = DateTime.now();
  Offset lastDragPosition;
}

/// Custom painter that renders a clean, subtle line grid pattern in the background.
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const double spacing = 28.0;

    // Draw vertical lines
    for (double x = 0.0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0.0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}

/// A custom painter that draws a deterministic background starfield.
///
/// Uses a fixed seed random number generator to ensure that stars remain
/// at the same coordinates across rebuilds and repaints.
class _StarPainter extends CustomPainter {
  /// Creates a const [_StarPainter].
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(1337);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw around 22 subtle background stars
    for (int i = 0; i < 22; i++) {
      final double x = rand.nextDouble() * size.width;
      final double y = rand.nextDouble() * size.height;
      // Soft stars with random radius between 0.6 and 1.6
      final double radius = 0.6 + rand.nextDouble() * 1.0;
      // Random opacity between 0.15 and 0.65
      final double opacity = 0.15 + rand.nextDouble() * 0.50;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add a tiny subtle glow to every 4th star to make it look premium
      if (i % 4 == 0) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), radius * 3.0, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => false;
}
