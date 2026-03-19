import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/weight_ruler_painter.dart';

/// A premium, minimalist weight picker component.
/// 
/// Replicates a high-fidelity analog scale with haptic feedback,
/// curved ruler interaction, and organic transitions.
class ModernWeightPicker extends StatefulWidget {
  /// The minimum scrollable value.
  final double minValue;

  /// The maximum scrollable value.
  final double maxValue;

  /// The initially selected value.
  final double initialValue;

  /// The title displayed at the top.
  final String title;

  /// The callback when the value changes.
  final ValueChanged<double> onValueChanged;

  /// The unit to display alongside the weight (e.g., 'kg', 'lb').
  /// NOTE: The visual display of the unit is currently disabled in the 
  /// painter but can be re-enabled in [WeightRulerPainter].
  final String unit;

  /// Whether to enable haptic feedback during scrolling.
  final bool enableHaptics;

  /// Primary color for the active value and indicator.
  final Color activeColor;

  /// Secondary color for inactive values.
  final Color inactiveColor;

  /// Color for the ruler tick marks.
  final Color tickColor;

  /// Background color of the picker container.
  final Color backgroundColor;

  /// Border radius of the picker container.
  final double borderRadius;

  /// Total height of the picker component.
  final double height;

  const ModernWeightPicker({
    super.key,
    this.minValue = 10.0,
    this.maxValue = 300.0,
    this.initialValue = 25.0,
    this.title = 'Weight',
    this.unit = 'kg',
    this.enableHaptics = true,
    required this.onValueChanged,
    this.activeColor = const Color(0xFF1D1D1F),
    this.inactiveColor = const Color(0xFFC7C7CC),
    this.tickColor = const Color(0xFFD1D1D6),
    this.backgroundColor = Colors.white,
    this.borderRadius = 44,
    this.height = 320,
  });

  @override
  State<ModernWeightPicker> createState() => _ModernWeightPickerState();
}

class _ModernWeightPickerState extends State<ModernWeightPicker> {
  late double _currentValue;
  final ScrollController _scrollController = ScrollController();
  
  /// Controls the precision and feel of the scroll.
  static const double _pixelsPerUnit = 105.0; 

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    
    final initialOffset = (_currentValue - widget.minValue) * _pixelsPerUnit;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(initialOffset);
      }
    });

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final newValue = (offset / _pixelsPerUnit) + widget.minValue;
    final clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
    
    if ((clampedValue - _currentValue).abs() > 0.001) {
      if (widget.enableHaptics) {
        final int oldStep = (_currentValue * 10).round();
        final int newStep = (clampedValue * 10).round();
        
        if (oldStep != newStep) {
          // Intelligent Haptics:
          if (newStep % 10 == 0) {
            // Integer value: Stronger feedback
            HapticFeedback.mediumImpact();
          } else if (newStep % 5 == 0) {
            // Half value (0.5): Light feedback
            HapticFeedback.selectionClick();
          }
          // Other 0.1 increments are silent to avoid "noise"
        }
      }

      setState(() {
        _currentValue = clampedValue;
      });
      
      widget.onValueChanged(_currentValue);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Static Title Label
          Positioned(
            top: widget.height * 0.11, // Relative to height
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: widget.height * 0.065, // Relative font size
                fontWeight: FontWeight.w700,
                color: widget.inactiveColor,
                letterSpacing: -0.8,
              ),
            ),
          ),

          // 2. The Visual Arc & Ruler (Custom Painted)
          Positioned.fill(
            top: widget.height * 0.1, // Relative offset
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: WeightRulerPainter(
                    currentValue: _currentValue,
                    minValue: widget.minValue,
                    maxValue: widget.maxValue,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    tickColor: widget.tickColor,
                    unit: widget.unit,
                  ),
                ),
              ),
            ),
          ),

          // 3. Center Indicator (Needle with Point)
          Positioned(
            bottom: widget.height * 0.01, // Relative to height
            child: CustomPaint(
              size: Size(8, widget.height * 0.125), // Relative needle height
              painter: _TriangleIndicatorPainter(widget.activeColor),
            ),
          ),
          
          // 4. Invisible Interaction Layer (Scrollable Area)
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  // Soft Snapping Effect:
                  // Only snap if we are "close enough" to an integer to avoid 
                  // feeling forced or restrictive.
                  final double exactValue = (_scrollController.offset / _pixelsPerUnit) + widget.minValue;
                  final double nearestInteger = exactValue.roundToDouble();
                  final double distance = (exactValue - nearestInteger).abs();
                  
                  // Only snap if within 0.15 units of an integer
                  if (distance > 0.001 && distance < 0.15) {
                    final double targetOffset = (nearestInteger - widget.minValue) * _pixelsPerUnit;

                    Future.delayed(const Duration(milliseconds: 30), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          targetOffset,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic, // Smoother, more natural deceleration
                        );
                      }
                    });
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: (widget.maxValue - widget.minValue) * _pixelsPerUnit + 
                         MediaQuery.of(context).size.width,
                  height: widget.height,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws an elongated triangle needle with a point on top for the scale indicator.
class _TriangleIndicatorPainter extends CustomPainter {
  final Color color;
  _TriangleIndicatorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the balance-style point (circle) on top
    canvas.drawCircle(
      Offset(size.width / 2, 4), 
      4, 
      paint,
    );

    // Draw the needle body (elongated triangle) with a gap
    final path = Path()
      ..moveTo(size.width / 2, 14) 
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
