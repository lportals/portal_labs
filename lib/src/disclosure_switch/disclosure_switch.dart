import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../theme/portal_theme.dart';

/// A premium, high-fidelity switch component that "discloses" or reveals additional content
/// when toggled on.
///
/// Features a custom gradient-track switch, smooth size transitions for revealed content,
/// and a refined iOS-inspired aesthetic.
class DisclosureSwitch extends StatefulWidget {
  /// Creates a [DisclosureSwitch].
  const DisclosureSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.revealedChild,
    this.activeGradient,
    this.activeColor = Colors.black,
    this.backgroundColor,
    this.borderColor,
  });

  /// The primary label displayed for the switch.
  final String title;

  /// Whether the switch is toggled on.
  final bool value;

  /// Callback triggered when the switch value changes.
  final ValueChanged<bool> onChanged;

  /// Optional icon displayed to the left of the title.
  final Widget? icon;

  /// The widget to be revealed below the main row when [value] is true.
  final Widget? revealedChild;

  /// The gradient used for the switch track when [value] is true.
  /// Takes precedence over [activeColor].
  final Gradient? activeGradient;

  /// The color used for the switch track when [value] is true and [activeGradient] is null.
  /// Defaults to [PortalThemeData.colors.primary].
  final Color? activeColor;

  /// The background color of the main container.
  final Color? backgroundColor;

  /// The color of the border around the container.
  final Color? borderColor;

  @override
  State<DisclosureSwitch> createState() => _DisclosureSwitchState();
}

class _DisclosureSwitchState extends State<DisclosureSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // We use the controller directly as the animation because animateWith handles the values
    _expandAnimation = _expandController;

    if (widget.value) {
      _expandController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DisclosureSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      // Use different spring behaviors for opening vs closing
      final spring = widget.value
          ? const SpringDescription(
              mass: 1.0,
              stiffness: 250, // Powerful opening
              damping: 12, // Under-damped = nice bounce
            )
          : const SpringDescription(
              mass: 1.0,
              stiffness: 200, // Slightly softer closing
              damping: 28, // Critically damped = no bounce back up
            );

      final simulation = SpringSimulation(
        spring,
        _expandController.value,
        widget.value ? 1.0 : 0.0,
        _expandController.velocity,
      );

      _expandController.animateWith(simulation);
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    final bg = widget.backgroundColor ?? theme.colors.surface;
    final border = widget.borderColor ?? theme.colors.border;
    final primary = widget.activeColor ?? theme.colors.primary;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        // Clamp the animation for visual properties like alpha
        final animValue = _expandAnimation.value.clamp(0.0, 1.0);

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03 * animValue),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // We use foregroundDecoration to paint the border OVER the white revealed content
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: border.withValues(alpha: animValue),
              width: 1.5,
            ),
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grey Inset Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2.5,
              vertical: 2.5,
            ), // Slightly more inset for the "Island"
            child: Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF2F2F7,
                ), // Grey background for the header "island"
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  _PremiumSwitch(
                    value: widget.value,
                    onChanged: widget.onChanged,
                    activeGradient: widget.activeGradient,
                    activeColor: primary,
                    inactiveColor: theme.colors.border,
                  ),
                ],
              ),
            ),
          ),

          // Revealed Content Area
          if (widget.revealedChild != null)
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final double t = _expandAnimation.value;

                // If practically closed, don't take any space
                if (t <= 0.001 && !widget.value) {
                  return const SizedBox.shrink();
                }

                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: t.clamp(0.0, 1.0),
                    child: child!,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 2,
                    ), // Tighter gap for better "island" integrity
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                        right: 20,
                        top: 8,
                        bottom: 24,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_expandAnimation),
                        child: widget.revealedChild,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Internal custom switch with premium animations and gradient track.
class _PremiumSwitch extends StatelessWidget {
  const _PremiumSwitch({
    required this.value,
    required this.onChanged,
    this.activeGradient,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Gradient? activeGradient;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    const double width = 56;
    const double height = 32;
    const double thumbSize = 26;
    const double padding = 3;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: value ? activeGradient : null,
          color: value
              ? (activeGradient == null ? activeColor : null)
              : inactiveColor,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: value ? width - thumbSize - padding : padding,
              top: padding,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
}
