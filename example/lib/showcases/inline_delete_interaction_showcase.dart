import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class InlineDeleteInteractionShowcase extends StatelessWidget {
  const InlineDeleteInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Inline Delete',
      backgroundColor: const Color(0xFFF8F8F8),
      description:
          'A premium interaction featuring a high-fidelity inline destructive confirmation flow with spring physics and mathematical concentricity.',
      codeSnippet: '''InlineDeleteInteraction(
  title: 'Post Options',
  onCloseRequested: () => Navigator.pop(context),
  items: [
    InlineAction(
      title: 'Edit', 
      icon: Icons.edit_outlined,
    ),
    InlineAction(
      title: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline,
      confirmLabel: 'Confirm Delete',
    ),
  ],
)''',
      child: const SafeArea(child: Center(child: _MenuTrigger())),
    );
  }
}

class _MenuTrigger extends StatefulWidget {
  const _MenuTrigger();

  @override
  State<_MenuTrigger> createState() => _MenuTriggerState();
}

class _MenuTriggerState extends State<_MenuTrigger> {
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  bool _isPressed = false;

  void _showMenu() {
    setState(() => _isOpen = true);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ContextualMenu(
          layerLink: _layerLink,
          appearanceAnimation: animation,
          onClose: () {
            Navigator.pop(context);
            setState(() => _isOpen = false);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the target scale:
    // 1. If menu is open, we stay at a slightly reduced scale.
    // 2. If finger is down (pressed), we go even lower for that "click" feel.
    double targetScale = 1.0;
    if (_isPressed) {
      targetScale = _isOpen ? 0.88 : 0.95;
    } else if (_isOpen) {
      targetScale = 0.92;
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showMenu();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.23, 1, 0.32, 1), // Strong ease-out
          padding: const EdgeInsets.all(10),
          transform: Matrix4.diagonal3Values(targetScale, targetScale, 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.02 : 0.05),
                blurRadius: _isPressed ? 4 : 10,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Icon(
            Icons.more_vert_rounded,
            color: _isOpen ? Colors.black : Colors.black54,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ContextualMenu extends StatelessWidget {
  const _ContextualMenu({
    required this.layerLink,
    required this.appearanceAnimation,
    required this.onClose,
  });

  final LayerLink layerLink;
  final Animation<double> appearanceAnimation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: AnimatedBuilder(
            animation: appearanceAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2.0 * appearanceAnimation.value,
                  sigmaY: 2.0 * appearanceAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.02 * appearanceAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          followerAnchor: Alignment.center,
          targetAnchor: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(
                  parent: appearanceAnimation,
                  curve: const Cubic(0.23, 1, 0.32, 1),
                ),
              ),
              child: FadeTransition(
                opacity: appearanceAnimation,
                child: InlineDeleteInteraction(
                  title: 'Post Options',
                  onCloseRequested: onClose,
                  appearanceAnimation: appearanceAnimation,
                  items: [
                    InlineAction(
                      title: 'Edit',
                      icon: Icons.edit_outlined,
                      onTap: () => debugPrint('Edit tapped'),
                    ),
                    InlineAction(
                      title: 'Share',
                      icon: Icons.share_outlined,
                      onTap: () => debugPrint('Share tapped'),
                    ),
                    InlineAction(
                      title: 'Archive',
                      icon: Icons.archive_outlined,
                      onTap: () => debugPrint('Archive tapped'),
                    ),
                    InlineAction(
                      title: 'Delete',
                      icon: Icons.delete_outline,
                      isDestructive: true,
                      confirmLabel: 'Delete Now',
                      onTap: () => debugPrint('Delete confirmed'),
                    ),
                  ],
                  style: InlineDeleteStyle(
                    borderRadius: BorderRadius.circular(28),
                    rowHeight: 52,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
