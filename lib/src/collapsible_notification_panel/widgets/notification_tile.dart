import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../models/panel_style.dart';

/// A premium tile representing a single notification.
class NotificationTile extends StatefulWidget {
  /// Creates a [NotificationTile].
  const NotificationTile({
    super.key,
    required this.item,
    required this.style,
    this.onTap,
    this.opacity = 1.0,
    this.yOffset = 0.0,
  });

  /// The notification data to display.
  final NotificationItem item;

  /// The style configuration for the tile.
  final CollapsibleNotificationPanelStyle style;

  /// Optional callback when the tile is tapped.
  /// If null, uses [item.onTap].
  final VoidCallback? onTap;

  /// The opacity of the tile (used for animations).
  final double opacity;

  /// The vertical offset of the tile (used for animations).
  final double yOffset;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, widget.yOffset),
      child: Opacity(
        opacity: widget.opacity,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap ?? widget.item.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: widget.style.tilePadding,
              decoration: BoxDecoration(
                color: _isPressed ? const Color(0xFFF2F2F7) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: widget.style.titleColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              widget.item.timestamp,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.style.subtitleColor.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.style.descriptionColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.style.iconGradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          widget.item.icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
