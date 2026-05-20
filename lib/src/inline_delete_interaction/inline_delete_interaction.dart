import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/inline_delete_style.dart';
import '../common/portal_animations.dart';

/// Represents an action item within the [InlineDeleteInteraction].
class InlineAction {
  /// Creates an [InlineAction].
  const InlineAction({
    required this.title,
    this.icon,
    this.leading,
    this.isDestructive = false,
    this.confirmLabel,
    this.cancelLabel,
    this.onTap,
  }) : assert(
         icon != null || leading != null || isDestructive,
         'Either icon or leading must be provided for non-destructive items.',
       );

  /// The title text of the action.
  final String title;

  /// Optional icon for the action.
  final IconData? icon;

  /// Optional custom leading widget for the action.
  final Widget? leading;

  /// Whether this action is destructive (renders with red highlights).
  final bool isDestructive;

  /// Optional custom label for the confirmation button.
  final String? confirmLabel;

  /// Optional custom label for the cancel button.
  final String? cancelLabel;

  /// Callback triggered when the action is selected.
  final VoidCallback? onTap;
}

/// A premium, inline interactive component for performing actions,
/// specialized for deletion with a two-step confirmation flow.
class InlineDeleteInteraction extends StatefulWidget {
  /// Creates an [InlineDeleteInteraction].
  const InlineDeleteInteraction({
    super.key,
    required this.items,
    required this.title,
    required this.onCloseRequested,
    this.style = const InlineDeleteStyle(),
    this.appearanceAnimation,
  });

  /// The list of actions to display in the menu.
  final List<InlineAction> items;

  /// The title displayed in the menu header.
  final String title;

  /// Callback triggered when the menu should be closed.
  final VoidCallback onCloseRequested;

  /// Style configuration for the interaction.
  final InlineDeleteStyle style;

  /// Optional external animation to drive the menu appearance.
  final Animation<double>? appearanceAnimation;

  @override
  State<InlineDeleteInteraction> createState() =>
      _InlineDeleteInteractionState();
}

class _InlineDeleteInteractionState extends State<InlineDeleteInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _confirmController;
  late Animation<double> _confirmAnimation;

  @override
  void initState() {
    super.initState();
    _confirmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _confirmAnimation = CurvedAnimation(
      parent: _confirmController,
      curve: PortalSpringCurve(
        mass: widget.style.springMass,
        stiffness: widget.style.springStiffness,
        damping: widget.style.springDamping,
      ),
    );
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleConfirm(bool show) {
    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    if (show) {
      _confirmController.forward();
    } else {
      _confirmController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style.resolve(context);
    final normalItems = widget.items.where((i) => !i.isDestructive).toList();
    final destructiveItem = widget.items.firstWhere(
      (i) => i.isDestructive,
      orElse: () => const InlineAction(
        title: 'Delete',
        icon: Icons.delete_outline,
        isDestructive: true,
      ),
    );

    final outerRadius = style.borderRadius?.topLeft.x ?? 24.0;

    return IntrinsicHeight(
      child: Container(
        width: style.width,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: style.borderColor ?? Colors.transparent,
            width: style.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(style),
              ...List.generate(normalItems.length, (index) {
                final item = normalItems[index];
                return _buildAnimatedItem(
                  index,
                  _MenuRow(
                    item: item,
                    style: style,
                    onTap: () {
                      item.onTap?.call();
                      widget.onCloseRequested();
                    },
                  ),
                );
              }),
              _buildAnimatedItem(
                normalItems.length,
                _InteractiveRow(
                  item: destructiveItem,
                  style: style,
                  animation: _confirmAnimation,
                  onToggle: _toggleConfirm,
                  onConfirm: () {
                    destructiveItem.onTap?.call();
                    widget.onCloseRequested();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(InlineDeleteStyle style) {
    // For the header, we use a slightly larger padding to allow the title
    // to "breathe" within the large radius corner.
    final headerPadding = style.modalPadding + 2;

    return _buildAnimatedItem(
      -1,
      Container(
        height: style.rowHeight,
        padding: EdgeInsets.symmetric(horizontal: headerPadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: style.borderColor ?? Colors.transparent,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(widget.title, style: style.titleStyle)),
            GestureDetector(
              onTap: widget.onCloseRequested,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    if (widget.appearanceAnimation == null) return child;

    final animation = CurvedAnimation(
      parent: widget.appearanceAnimation!,
      curve: Interval(
        (0.1 + (index + 1) * 0.05).clamp(0.0, 1.0),
        (0.6 + (index + 1) * 0.05).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1.0 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

class _InteractiveRow extends StatelessWidget {
  const _InteractiveRow({
    required this.item,
    required this.style,
    required this.animation,
    required this.onToggle,
    required this.onConfirm,
  });

  final InlineAction item;
  final InlineDeleteStyle style;
  final Animation<double> animation;
  final ValueChanged<bool> onToggle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final double itemHeight = style.rowHeight;
    // Uniform padding for perfect concentricity: matches visual rhythm
    const double uniformPadding = 8.0;

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;

          return Stack(
            children: [
              Transform.translate(
                offset: Offset(0, -itemHeight * t),
                child: Offstage(
                  offstage: t >= 1.0,
                  child: Opacity(
                    opacity: (1.0 - t).clamp(0.0, 1.0),
                    child: _MenuRow(
                      item: item,
                      style: style,
                      onTap: () => onToggle(true),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, itemHeight * (1.0 - t)),
                child: Offstage(
                  offstage: t <= 0.0,
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Container(
                      height: itemHeight,
                      padding: const EdgeInsets.all(uniformPadding),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ConfirmButton(
                              label: item.confirmLabel ?? 'Confirm Delete',
                              color: style.confirmButtonColor,
                              onTap: onConfirm,
                              isDestructive: true,
                              style: style,
                              padding: uniformPadding,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ConfirmButton(
                              label: item.cancelLabel ?? 'Cancel',
                              color:
                                  style.cancelButtonColor ?? Colors.transparent,
                              onTap: () => onToggle(false),
                              style: style,
                              padding: uniformPadding,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.item,
    required this.style,
    required this.onTap,
  });

  final InlineAction item;
  final InlineDeleteStyle style;
  final VoidCallback onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.item.isDestructive
        ? widget.style.destructiveTextStyle
        : widget.style.itemTextStyle;

    final iconColor = widget.item.isDestructive
        ? widget.style.destructiveIconColor
        : widget.style.iconColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.style.rowHeight,
        padding: EdgeInsets.symmetric(
          horizontal: widget.style.modalPadding + 4,
        ),
        color: _isPressed
            ? (widget.style.borderColor ?? Colors.black.withValues(alpha: 0.05))
                  .withValues(alpha: 0.15)
            : Colors.transparent,
        child: Row(
          children: [
            if (widget.item.icon != null || widget.item.leading != null) ...[
              widget.item.leading ??
                  Icon(widget.item.icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
            ],
            Text(widget.item.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.style,
    required this.padding,
    this.isDestructive = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final InlineDeleteStyle style;
  final double padding;
  final bool isDestructive;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Exact concentric radius formula: OuterRadius - Padding
    final outerRadius = widget.style.borderRadius?.topLeft.x ?? 24.0;
    final buttonRadius = (outerRadius - widget.padding).clamp(0.0, outerRadius);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(buttonRadius),
            border: widget.isDestructive
                ? null
                : Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isDestructive ? Colors.white : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
