import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/panel_style.dart';

/// The header of the notification panel, visible in both states.
class PanelHeader extends StatefulWidget {
  final int notificationCount;
  final String subtitle;
  final bool isExpanded;
  final IconData? icon;
  final CollapsibleNotificationPanelStyle style;
  final Animation<double> expansionAnimation;
  final VoidCallback onToggle;

  const PanelHeader({
    super.key,
    required this.notificationCount,
    required this.subtitle,
    required this.isExpanded,
    this.icon,
    required this.style,
    required this.expansionAnimation,
    required this.onToggle,
  });

  @override
  State<PanelHeader> createState() => _PanelHeaderState();
}

class _PanelHeaderState extends State<PanelHeader> with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    _bellController.forward(from: 0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.expansionAnimation,
      builder: (context, child) {
        final t = widget.expansionAnimation.value;
        
        // Standardized padding for symmetry: top and sides are now equal
        const double verticalPadding = 16.0; 
        const double horizontalPadding = 16.0;
        final double iconSize = 52.0 - (8.0 * t); // 52 -> 44
        final double fontSize = 18.0 - (3.0 * t); // 18 -> 15

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _handleToggle,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              padding: widget.style.headerPadding,
              decoration: BoxDecoration(
                color: widget.style.backgroundColor,
                borderRadius: BorderRadius.circular(widget.style.borderRadius),
              ),
              child: Row(
                children: [
                  _buildBellIcon(iconSize),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: iconSize, // Match icon height for perfect vertical centering
                      child: Stack(
                        children: [
                          // Title: Always perfectly centered vertically
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                // When collapsed (t=0), shift slightly up to make room for subtitle
                                // When expanded (t=1), shift to 0 (perfect center)
                                bottom: (1.0 - t) * 16.0,
                              ),
                              child: Text(
                                '${widget.notificationCount} New Activities',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w800,
                                  color: widget.style.titleColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          // Subtitle: Positioned below the title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Opacity(
                                opacity: (1.0 - t * 4.0).clamp(0.0, 1.0),
                                child: Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.style.subtitleColor.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildToggleButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBellIcon(double size) {
    return AnimatedBuilder(
      animation: _bellController,
      builder: (context, child) {
        final double rotation = math.sin(_bellController.value * math.pi * 4) * 0.15 * (1.0 - _bellController.value);
        return Transform.rotate(
          angle: rotation,
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.style.iconGradientColors,
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Center(
          child: Icon(
            widget.icon ?? Icons.notifications_rounded,
            color: Colors.white,
            size: size * 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return AnimatedRotation(
      turns: widget.isExpanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF8E8E93),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.expand_more_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
