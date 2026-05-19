import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import 'models/folder_tabs_style.dart';

/// A premium, zero-dependency "Folder Tabs" component.
///
/// Mimics a physical paper file folder where the active tab rises from the body
/// in a smooth, continuous silhouette using custom geometry (bezier S-curves).
/// Movement transitions are driven by interruptible spring physics.
class FolderTabs extends StatefulWidget {
  /// Creates a [FolderTabs] widget.
  const FolderTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.currentIndex,
    this.initialIndex = 0,
    this.onSelect,
    this.style = const FolderTabsStyle(),
  })  : assert(tabs.length > 0),
        assert(children.length == tabs.length);

  /// The list of text labels for each tab.
  final List<String> tabs;

  /// The corresponding content widgets for each tab.
  final List<Widget> children;

  /// Optional external index control. If provided, the widget is controlled.
  final int? currentIndex;

  /// The initially selected tab index (used when [currentIndex] is null).
  final int initialIndex;

  /// Callback triggered when a tab is selected.
  final ValueChanged<int>? onSelect;

  /// Aesthetic and physics styling configuration.
  final FolderTabsStyle style;

  @override
  State<FolderTabs> createState() => _FolderTabsState();
}

class _FolderTabsState extends State<FolderTabs>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late double _animIndexValue;

  late AnimationController _indexController;
  late double _startIndex;
  late double _targetIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex ?? widget.initialIndex;
    _animIndexValue = _selectedIndex.toDouble();
    _startIndex = _animIndexValue;
    _targetIndex = _animIndexValue;

    _indexController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _indexController.addListener(() {
      setState(() {
        final curve = PortalSpringCurve(
          mass: widget.style.springMass,
          stiffness: widget.style.springStiffness,
          damping: widget.style.springDamping,
        );
        _animIndexValue = lerpDouble(
          _startIndex,
          _targetIndex,
          curve.transform(_indexController.value),
        )!;
      });
    });
  }

  @override
  void didUpdateWidget(FolderTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != null && widget.currentIndex != _selectedIndex) {
      _animateTo(widget.currentIndex!);
    }
  }

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }

  void _animateTo(int target) {
    _selectedIndex = target;
    _startIndex = _animIndexValue;
    _targetIndex = target.toDouble();

    _indexController.forward(from: 0.0);
  }

  void _handleTabSelect(int index) {
    if (_selectedIndex == index) return;

    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    if (widget.currentIndex == null) {
      _animateTo(index);
    }

    widget.onSelect?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double tabWidth = totalWidth / widget.tabs.length;

        return CustomPaint(
          painter: _FolderPainter(
            color: widget.style.folderColor,
            borderRadius: widget.style.borderRadius,
            tabBorderRadius: widget.style.tabBorderRadius,
            tabHeight: widget.style.tabHeight,
            tabCurveWidth: widget.style.tabCurveWidth,
            tabProtrusionWidth: widget.style.tabProtrusionWidth,
            animatedIndex: _animIndexValue,
            tabCount: widget.tabs.length,
            shadows: widget.style.shadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab Bar Row (Height: tabHeight)
              SizedBox(
                height: widget.style.tabHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(widget.tabs.length, (index) {
                    final isSelected = _selectedIndex == index;

                    return Positioned(
                      left: tabWidth * index,
                      width: tabWidth,
                      bottom: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _handleTabSelect(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: isSelected
                                ? widget.style.activeLabelStyle
                                : widget.style.inactiveLabelStyle,
                            child: Text(
                              widget.tabs[index],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Folder Body Container
              Container(
                padding: widget.style.padding,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // Check if this child key matches the currently selected active index
                      final isEntering = (child.key as ValueKey<int>?)?.value == _selectedIndex;

                      // Both entering and exiting widgets slide downwards:
                      // - Entering child starts above (-0.06) and slides down to 0.0
                      // - Exiting child starts at 0.0 and slides down to below (0.06)
                      final offsetAnimation = Tween<Offset>(
                        begin: isEntering ? const Offset(0.0, -0.06) : const Offset(0.0, 0.06),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: widget.children[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter that draws the complete folder silhouette:
/// a continuous path containing the rounded body, transition curves,
/// and the active tab protrusion.
class _FolderPainter extends CustomPainter {
  _FolderPainter({
    required this.color,
    required this.borderRadius,
    required this.tabBorderRadius,
    required this.tabHeight,
    required this.tabCurveWidth,
    required this.tabProtrusionWidth,
    required this.animatedIndex,
    required this.tabCount,
    required this.shadows,
  });

  final Color color;
  final double borderRadius;
  final double tabBorderRadius;
  final double tabHeight;
  final double tabCurveWidth;
  final double tabProtrusionWidth;
  final double animatedIndex;
  final int tabCount;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Local helper to generate the main folder path
    Path getFolderPath(double indexVal) {
      final double tabWidth = size.width / tabCount;
      final double centerX = tabWidth * indexVal + tabWidth / 2;
      final double halfW = tabProtrusionWidth / 2;

      final double leftMorph = (indexVal).clamp(0.0, 1.0);
      final double lastIndex = (tabCount - 1).toDouble();
      final double rightMorph = (lastIndex - indexVal).clamp(0.0, 1.0);

      final double bodyTop = tabHeight;
      final double r = borderRadius;

      final double topLeftY = lerpDouble(0, bodyTop, leftMorph)!;
      final double topLeftRadius = lerpDouble(tabBorderRadius, r, leftMorph)!;

      final double topRightY = lerpDouble(0, bodyTop, rightMorph)!;
      final double topRightRadius = lerpDouble(tabBorderRadius, r, rightMorph)!;

      final double tLeft = centerX - halfW;
      final double tRight = centerX + halfW;

      final path = Path()
        ..moveTo(0, size.height - r)
        ..lineTo(0, topLeftY + topLeftRadius)
        ..arcToPoint(Offset(topLeftRadius, topLeftY), radius: Radius.circular(topLeftRadius));

      if (leftMorph > 0.0) {
        final double activeCurveL = tabCurveWidth * leftMorph;
        final double cStartX = (tLeft - activeCurveL).clamp(topLeftRadius, size.width);
        final double cLeft = tLeft.clamp(topLeftRadius, size.width);
        final double cEndX = (tLeft + activeCurveL).clamp(topLeftRadius, size.width);

        path
          ..lineTo(cStartX, topLeftY)
          ..cubicTo(cLeft, topLeftY, cLeft, 0, cEndX, 0);
      } else {
        path.lineTo(topLeftRadius, 0);
      }

      path.lineTo(tRight - tabCurveWidth * rightMorph, 0);

      if (rightMorph > 0.0) {
        final double activeCurveR = tabCurveWidth * rightMorph;
        final double cStartX = (tRight - activeCurveR).clamp(0, size.width - topRightRadius);
        final double cRight = tRight.clamp(0, size.width - topRightRadius);
        final double cEndX = (tRight + activeCurveR).clamp(0, size.width - topRightRadius);

        path
          ..lineTo(cStartX, 0)
          ..cubicTo(cRight, 0, cRight, topRightY, cEndX, topRightY);
      } else {
        path.lineTo(size.width - topRightRadius, 0);
      }

      path
        ..lineTo(size.width - topRightRadius, topRightY)
        ..arcToPoint(Offset(size.width, topRightY + topRightRadius), radius: Radius.circular(topRightRadius))
        ..lineTo(size.width, size.height - r)
        ..arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r))
        ..lineTo(r, size.height)
        ..arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r))
        ..close();

      return path;
    }

    // 1. Draw inactive background folders first (sitting at exact same height)
    final bgTabColor = Color.alphaBlend(Colors.black.withValues(alpha: 0.12), color);
    
    for (int i = 0; i < tabCount; i++) {
      final double staticIndex = i.toDouble();
      
      // Calculate how close the sliding active index is to this static tab position
      final double distance = (animatedIndex - staticIndex).abs();
      // Smooth visibility factor: 0.0 when active is directly on top, 1.0 when active is 1+ slots away
      final double visibility = distance.clamp(0.0, 1.0);
      
      // Skip drawing if it is fully merged/covered
      if (visibility < 0.01) continue;

      final bgPath = getFolderPath(staticIndex);

      // Smoothly fade out the shadow, outline, and blend the color based on proximity
      final shadowColor = Colors.black.withValues(alpha: 0.08 * visibility);
      final fillTabColor = Color.lerp(color, bgTabColor, visibility)!;
      final outlineColor = Colors.black.withValues(alpha: 0.04 * visibility);

      // Draw soft shadow for the background tab
      canvas.drawPath(
        bgPath,
        Paint()
          ..color = shadowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
          ..style = PaintingStyle.fill,
      );

      // Draw background tab fill (smoothly blends color as active approaches)
      canvas.drawPath(bgPath, Paint()..color = fillTabColor..style = PaintingStyle.fill);

      // Draw subtle background tab outline separator
      canvas.drawPath(
        bgPath,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // 2. Draw the main front folder body (with active moving tab)
    final frontPath = getFolderPath(animatedIndex);

    // Draw main folder shadows
    for (final shadow in shadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius * 0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(frontPath, shadowPaint);
      canvas.restore();
    }

    // Draw main folder fill
    canvas.drawPath(frontPath, Paint()..color = color..style = PaintingStyle.fill);

    // Draw separation rim highlight on active front folder
    canvas.drawPath(
      frontPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Subtle 3D white rim highlight
    canvas.drawPath(
      frontPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _FolderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.tabBorderRadius != tabBorderRadius ||
        oldDelegate.tabHeight != tabHeight ||
        oldDelegate.tabCurveWidth != tabCurveWidth ||
        oldDelegate.tabProtrusionWidth != tabProtrusionWidth ||
        oldDelegate.animatedIndex != animatedIndex ||
        oldDelegate.tabCount != tabCount ||
        oldDelegate.shadows != shadows;
  }
}
