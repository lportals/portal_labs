import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/archive_folder_style.dart';

/// A premium folder-based component that reveals its contents with a
/// high-fidelity 3D hinge animation, custom geometry, and glassmorphism.
///
/// Items always spread vertically above the folder (in vertical mode) or
/// to the right (in horizontal mode). The front flap always occludes the
/// items, so items never visually "pass through" the folder body. The
/// selected ("Pop-to-Front") item is rendered between the back flap and the
/// front flap — never above the folder.
class ArchiveFolder extends StatefulWidget {
  /// Creates an [ArchiveFolder] with the specified properties.
  const ArchiveFolder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.style = const ArchiveFolderStyle(),
    this.onToggle,
    this.isOpen,
    this.onItemTap,
  });

  /// The title displayed on the front flap.
  final String title;

  /// The subtitle displayed below the title on the front flap.
  final String subtitle;

  /// The list of item widgets (e.g. [ArchiveItem]) to show inside the folder.
  final List<Widget> items;

  /// Visual and interaction style configuration.
  final ArchiveFolderStyle style;

  /// Called when the folder is opened or closed.
  final ValueChanged<bool>? onToggle;

  /// Optional external control of the open/closed state.
  final bool? isOpen;

  /// Called when an item is tapped, with the item index.
  final ValueChanged<int>? onItemTap;

  @override
  State<ArchiveFolder> createState() => _ArchiveFolderState();
}

class _ArchiveFolderState extends State<ArchiveFolder>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Controller for the "Pop-to-Front" spring bounce on item selection.
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  bool _internalIsOpen = false;

  /// The index of the item that was last tapped (shown "pop-to-front").
  int? _frontItemIndex;

  bool get _isOpen => widget.isOpen ?? _internalIsOpen;

  // ---------------------------------------------------------------------------
  // Derived geometry — single source of truth, computed from style.
  // ---------------------------------------------------------------------------

  /// Width of the folder body (front + back flap visible area).
  double get _bodyWidth => widget.style.folderWidth;

  /// Height of the folder body.
  double get _bodyHeight => widget.style.folderHeight;

  /// Width of the side-tab protrusion on the back flap.
  double get _tabProtrusion => widget.style.tabProtrusion;

  /// Full width of the back-flap shape (body + tab).
  double get _flapWidth => _bodyWidth + _tabProtrusion;

  /// Width of each item.
  double get _itemW => widget.style.itemWidth;

  /// Height of each item.
  double get _itemH => widget.style.itemHeight;

  /// Spacing between item centers when fully revealed.
  double get _itemSpacing => widget.style.itemSpacing;

  int get _count => widget.items.length;

  /// Total vertical span of revealed items (distance between outermost item centers).
  double get _totalSpread => (_count - 1) * _itemSpacing;

  // ---------------------------------------------------------------------------
  // Canvas dimensions
  //
  // The Stack canvas must be large enough to show:
  //   - The folder body (bodyWidth × bodyHeight), anchored at top-left.
  //   - All items at their maximum reveal position.
  //
  // Items translate rightward (positive-X) by [itemRevealDistance] + some
  // organic X offset. Items spread vertically (positive and negative Y) by
  // [_totalSpread / 2] around the folder center.
  //
  // We anchor items relative to the Stack's top-left, positioning them so the
  // item center aligns with the folder center at rest (progress == 0) and
  // slides out at reveal (progress == 1).
  // ---------------------------------------------------------------------------

  /// Horizontal canvas width: folder body + max reveal + item width margin.
  double get _canvasWidth =>
      _bodyWidth + widget.style.itemRevealDistance + _itemW;

  /// Vertical canvas height: folder body height PLUS the extra vertical spread
  /// that items need above and below the folder center.
  double get _canvasHeight =>
      math.max(_bodyHeight, _totalSpread + _itemH + 24.0);

  /// The folder body is vertically centred in the canvas.
  double get _folderTopInCanvas => (_canvasHeight - _bodyHeight) / 2;

  /// Folder center Y in canvas coordinates.
  double get _folderCenterY => _folderTopInCanvas + _bodyHeight / 2;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.style.animationCurve,
    );
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _popAnimation = CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    );
    if (_isOpen) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(ArchiveFolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != null && widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen!) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _popController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Interaction handlers
  // ---------------------------------------------------------------------------

  void _handleToggle() {
    if (widget.isOpen != null) {
      widget.onToggle?.call(!widget.isOpen!);
      return;
    }
    setState(() {
      _internalIsOpen = !_internalIsOpen;
      if (_internalIsOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
        // Reset the selected item so it doesn't float above the folder after close.
        _frontItemIndex = null;
      }
    });
    widget.onToggle?.call(_internalIsOpen);
    if (widget.style.enableHaptics) HapticFeedback.lightImpact();
  }

  void _handleItemTap(int index) {
    if (_animation.value < 0.2) {
      _handleToggle();
      return;
    }
    setState(() => _frontItemIndex = index);
    _popController.forward(from: 0.0);
    widget.onItemTap?.call(index);
    if (widget.style.enableHaptics) HapticFeedback.selectionClick();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isHorizontal =
        widget.style.orientation == ArchiveFolderOrientation.horizontal;

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _popController]),
      builder: (context, _) {
        return SizedBox(
          width: isHorizontal ? _canvasHeight : _canvasWidth,
          height: isHorizontal ? _canvasWidth : _canvasHeight,
          child: isHorizontal
              ? _buildHorizontalLayout()
              : _buildVerticalLayout(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Vertical layout  (items spread upward, folder at bottom of spread)
  // ---------------------------------------------------------------------------

  Widget _buildVerticalLayout() {
    // Render order: back-most items first, front-most last (excluding selected).
    final List<int> order = List.generate(_count, (i) => i);
    if (_frontItemIndex != null) {
      order.remove(_frontItemIndex);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Back flap
        Positioned(
          left: 0,
          top: _folderTopInCanvas,
          child: GestureDetector(
            onTap: _handleToggle,
            behavior: HitTestBehavior.opaque,
            child: _buildBackFlap(),
          ),
        ),

        // 2. Items (all except the front item) — below the front flap
        ..._buildItemWidgets(order),

        // 3. Selected item (between back and front flap) — never above flap
        if (_frontItemIndex != null && _animation.value >= 0.1)
          ..._buildItemWidgets([_frontItemIndex!]),

        // 4. Front flap — ALWAYS on top of items
        Positioned(
          left: 0,
          top: _folderTopInCanvas,
          child: GestureDetector(
            onTap: _handleToggle,
            behavior: HitTestBehavior.opaque,
            child: _buildFrontFlap(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Horizontal layout  (items spread to the right, folder rotated 90°)
  // ---------------------------------------------------------------------------
  //
  // Rather than rotating the entire canvas (which inverts coordinate systems
  // and misaligns controls), we build a vertical layout internally and rotate
  // only the folder + items group, keeping the outer SizedBox in screen space.

  Widget _buildHorizontalLayout() {
    final List<int> order = List.generate(_count, (i) => i);
    if (_frontItemIndex != null) {
      order.remove(_frontItemIndex);
    }

    // Inner canvas is swapped: width = _canvasHeight, height = _canvasWidth.
    // We use RotatedBox by -90° (3 quarter turns) so hit-testing and layout perfectly align.
    return RotatedBox(
      quarterTurns: 3,
      child: SizedBox(
        width: _canvasWidth,
        height: _canvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Back flap
              Positioned(
                left: 0,
                top: _folderTopInCanvas,
                child: GestureDetector(
                  onTap: _handleToggle,
                  behavior: HitTestBehavior.opaque,
                  child: _buildBackFlap(),
                ),
              ),

              // Items (non-selected)
              ..._buildItemWidgets(order),

              // Selected item
              if (_frontItemIndex != null && _animation.value >= 0.1)
                ..._buildItemWidgets([_frontItemIndex!]),

              // Front flap — always above items
              Positioned(
                left: 0,
                top: _folderTopInCanvas,
                child: GestureDetector(
                  onTap: _handleToggle,
                  behavior: HitTestBehavior.opaque,
                  child: _buildFrontFlap(),
                ),
              ),
            ],
          ),
        ),
    );
  }

  // ---------------------------------------------------------------------------
  // Item widget builder
  //
  // Each item slides from rest (folderCenter) to a revealed position:
  //   X: bodyWidth + revealDistance  (to the right of the folder)
  //   Y: spread symmetrically around folderCenterY
  // ---------------------------------------------------------------------------

  List<Widget> _buildItemWidgets(List<int> indices) {
    final List<Widget> result = [];

    for (final int i in indices) {
      final double staggeredProgress = CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (i / _count) * 0.35,
          ((i / _count) * 0.35 + 0.65).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ).value;

      // Organic tilt per item.
      final bool organic = widget.style.enableItemRotation;
      final double organicX = organic ? math.sin(i * 1.4) * 14.0 : 0.0;
      final double organicRot = organic ? math.cos(i * 2.8) * 0.07 : 0.0;

      // Arc: slight upward arc during the reveal so items "fly out".
      final double arc = (1.0 - staggeredProgress) * staggeredProgress * 36.0;

      // Resting position: Add spread so they aren't perfectly stacked, and 
      // push them rightward so they slightly protrude from the folder edge.
      final bool isHorizontal = widget.style.orientation == ArchiveFolderOrientation.horizontal;
      // In horizontal mode, we increase the Y spread to fan them out more side-to-side.
      final double restSpreadX = (i - (_count - 1) / 2) * 12.0;
      final double restSpreadY = (i - (_count - 1) / 2) * (isHorizontal ? 20.0 : 8.0);
      
      // We reduce the peek offset in horizontal mode so it doesn't protrude as much.
      final double peekOffset = 50.0;
      final double restX = _bodyWidth / 2 + peekOffset + restSpreadX + (isHorizontal ? -15.0 : 0.0);
      final double restY = _folderCenterY + restSpreadY;

      // Target: right of folder + reveal distance.
      // We keep the inner X target consistent so items exit to the same distance (height in horizontal).
      final double targetX =
          _bodyWidth + widget.style.itemRevealDistance + organicX;
      final double targetY =
          _folderCenterY + (i - (_count - 1) / 2) * _itemSpacing;

      // Blend rest → target with power curve for delayed vertical spread.
      final double vertP = math.pow(staggeredProgress, 1.4).toDouble();
      final double cx = lerpDouble(restX, targetX, staggeredProgress)! + arc;
      final double cy = lerpDouble(restY, targetY, vertP)!;

      // Subtle resting tilt → 0 on reveal.
      final double restRot = (i - (_count - 1) / 2) * 0.012;
      final double rotation = widget.style.itemBaseRotation + lerpDouble(restRot, organicRot, staggeredProgress)!;

      // Bounding box swaps in horizontal mode because of the 90-degree rotation
      final double w = isHorizontal ? _itemH : _itemW;
      final double h = isHorizontal ? _itemW : _itemH;

      // Scale: compressed at rest, full size when revealed.
      double scale = widget.style.itemBaseScale +
          staggeredProgress * (1.0 - widget.style.itemBaseScale);
      if (_frontItemIndex == i) {
        scale *= 1.0 + (_popAnimation.value * 0.07);
      }

      // Item top-left in canvas coordinates.
      final double left = cx - w / 2;
      final double top = cy - h / 2;

      // Visual item layer with integrated GestureDetector.
      result.add(
        Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: Transform(
            transform: Matrix4.identity()
              ..rotateZ(rotation)
              ..scaleByDouble(scale, scale, 1.0, 1.0),
            alignment: Alignment.center,
            child: GestureDetector(
              key: ValueKey('hit_$i'),
              onTap: () => _handleItemTap(i),
              behavior: HitTestBehavior.opaque,
              child: RotatedBox(
                quarterTurns: isHorizontal ? 1 : 0,
                child: KeyedSubtree(
                  key: ValueKey('archive_item_internal_$i'),
                  child: SizedBox(
                    width: _itemW,
                    height: _itemH,
                    child: widget.items[i],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Front flap (glassmorphic, hinge-rotates open)
  // ---------------------------------------------------------------------------

  Widget _buildFrontFlap() {
    final bool isHorizontal = widget.style.orientation == ArchiveFolderOrientation.horizontal;
    final double p = _animation.value;
    final double r = widget.style.borderRadius;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(0.02 + p * 0.85)
        ..scaleByDouble(1.0 + p * 0.015, 1.0 + p * 0.015, 1.0, 1.0),
      alignment: Alignment.centerLeft,
      child: Container(
        width: _bodyWidth,
        height: _bodyHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15 + p * 0.05),
              blurRadius: 20 + p * 20,
              offset: Offset(4 + p * 8, 8 + p * 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Frosted-glass layer.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.style.glassBlur,
                  sigmaY: widget.style.glassBlur,
                ),
                child: Container(
                  color: widget.style.folderColor.withValues(alpha: 0.65),
                ),
              ),
            ),

            // Glass border highlight.
            Positioned.fill(
              child: CustomPaint(
                painter: _GlassBorderPainter(
                  borderRadius: r,
                  borderColor: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),

            // Title / subtitle block
            Positioned(
              bottom: isHorizontal ? null : 28,
              top: isHorizontal ? 20 : null,
              left: 20,
              right: isHorizontal ? null : 16,
              child: RotatedBox(
                quarterTurns: isHorizontal ? 1 : 0,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: widget.style.titleStyle.copyWith(
                      fontSize: 19,
                      letterSpacing: -0.5,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: widget.style.subtitleStyle.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomPaint(
                    size: const Size(120, 8),
                    painter: _FolderFrontDecoratorPainter(),
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Back flap (solid color + side tab geometry)
  // ---------------------------------------------------------------------------

  Widget _buildBackFlap() {
    return CustomPaint(
      size: Size(_flapWidth, _bodyHeight),
      painter: _FolderBackPainter(
        color: widget.style.folderColor,
        borderRadius: widget.style.borderRadius,
        bodyWidth: _bodyWidth,
      ),
    );
  }
}

// =============================================================================
// Painters
// =============================================================================

/// Paints the back flap shape including the side-tab protrusion.
class _FolderBackPainter extends CustomPainter {
  _FolderBackPainter({
    required this.color,
    required this.borderRadius,
    required this.bodyWidth,
  });

  final Color color;
  final double borderRadius;

  /// Width of the folder body area (without the tab).
  final double bodyWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double r = borderRadius;

    // Tab parameters — protrudes on the right side of the back flap.
    const double tabTopY = 0.0;
    const double tabBottomY = 90.0;
    const double tabCurveSpan = 30.0;

    final path = Path()
      // Top-left corner
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      // Top edge to top-right corner of the tab
      ..lineTo(size.width - r, tabTopY)
      ..arcToPoint(Offset(size.width, tabTopY + r), radius: Radius.circular(r))
      // Right edge of the tab, down to the curve-in
      ..lineTo(size.width, tabBottomY - tabCurveSpan)
      // Cubic bezier from tab into the body
      ..cubicTo(
        size.width,
        tabBottomY,
        bodyWidth,
        tabBottomY - tabCurveSpan * 0.3,
        bodyWidth,
        tabBottomY + tabCurveSpan,
      )
      // Left edge of body down to bottom-left
      ..lineTo(bodyWidth, size.height - r)
      ..arcToPoint(Offset(bodyWidth - r, size.height), radius: Radius.circular(r))
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r))
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.14), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FolderBackPainter old) =>
      old.color != color ||
      old.borderRadius != borderRadius ||
      old.bodyWidth != bodyWidth;
}

/// Decorative lines inside the front flap.
class _FolderFrontDecoratorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final p2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, const Offset(60, 0), p1);
    canvas.drawLine(const Offset(0, 6), const Offset(100, 6), p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Inner-stroke glass-border highlight for the front flap.
class _GlassBorderPainter extends CustomPainter {
  _GlassBorderPainter({
    required this.borderRadius,
    required this.borderColor,
  });

  final double borderRadius;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Inner highlight stroke.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Top-left rim light.
    final rimPath = Path()
      ..moveTo(0, borderRadius)
      ..arcToPoint(Offset(borderRadius, 0),
          radius: Radius.circular(borderRadius))
      ..lineTo(size.width * 0.4, 0);

    canvas.drawPath(
      rimPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter old) =>
      old.borderRadius != borderRadius || old.borderColor != borderColor;
}
