import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/premium_flip_counter.dart';
import '../theme/portal_theme.dart';
import 'models/pricing_plan.dart';

/// A high-fidelity subscription pricing picker with a minimalist design.
/// Optimized for SaaS or mobile app subscription flows.
///
/// Features:
/// *   Monthly/Yearly period toggle.
/// *   Selection highlighting with animated borders.
/// *   Customizable popular badges.
/// *   Tactile feedback on selection.
class SubscriptionPricingPicker extends StatefulWidget {

  /// Creates a [SubscriptionPricingPicker] with the required plan lists.
  const SubscriptionPricingPicker({
    super.key,
    required this.monthlyPlans,
    required this.yearlyPlans,
    this.onSelect,
    this.onActionPressed,
    this.monthlyLabel = 'Monthly',
    this.yearlyLabel = 'Yearly',
    this.actionButtonLabel = 'Get Started',
    this.initialSelectedIndex = 1,
    this.initialPeriod = PricingPeriod.monthly,
  });
  /// The list of plans available for the 'monthly' period.
  final List<PricingPlan> monthlyPlans;

  /// The list of plans available for the 'yearly' period.
  final List<PricingPlan> yearlyPlans;

  /// Callback triggered when a plan is selected.
  final void Function(PricingPlan plan, PricingPeriod period)? onSelect;

  /// Callback triggered when the main CTA button is pressed.
  final void Function(PricingPlan plan, PricingPeriod period)? onActionPressed;

  /// The label for the monthly toggle option.
  final String monthlyLabel;

  /// The label for the yearly toggle option.
  final String yearlyLabel;

  /// The label for the main CTA button.
  final String actionButtonLabel;

  /// The initial selection index for plans.
  final int initialSelectedIndex;

  /// The initial pricing period.
  final PricingPeriod initialPeriod;

  @override
  State<SubscriptionPricingPicker> createState() =>
      _SubscriptionPricingPickerState();
}

class _SubscriptionPricingPickerState extends State<SubscriptionPricingPicker> {
  late PricingPeriod _currentPeriod;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _currentPeriod = widget.initialPeriod;
    _selectedIndex = widget.initialSelectedIndex;
  }

  void _onPeriodToggle(PricingPeriod period) {
    if (_currentPeriod == period) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentPeriod = period;
    });
  }

  void _onPlanSelected(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedIndex = index;
    });
    final currentPlans = _currentPeriod == PricingPeriod.monthly
        ? widget.monthlyPlans
        : widget.yearlyPlans;
    widget.onSelect?.call(currentPlans[index], _currentPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final currentPlans = _currentPeriod == PricingPeriod.monthly
        ? widget.monthlyPlans
        : widget.yearlyPlans;
    final theme = PortalTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colors.border, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Period Toggle
          _PricingToggle(
            period: _currentPeriod,
            monthlyLabel: widget.monthlyLabel,
            yearlyLabel: widget.yearlyLabel,
            onToggle: _onPeriodToggle,
          ),
          const SizedBox(height: 24),

          // 2. Plans List
          ...List.generate(currentPlans.length, (index) {
            final plan = currentPlans[index];
            final isSelected = _selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PricingCard(
                plan: plan,
                period: _currentPeriod,
                isSelected: isSelected,
                onTap: () => _onPlanSelected(index),
              ),
            );
          }),

          const SizedBox(height: 12),

          // 3. CTA Action Button
          _ActionButton(
            label: widget.actionButtonLabel,
            onPressed: () => widget.onActionPressed?.call(
              currentPlans[_selectedIndex],
              _currentPeriod,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingToggle extends StatelessWidget {

  const _PricingToggle({
    required this.period,
    required this.monthlyLabel,
    required this.yearlyLabel,
    required this.onToggle,
  });
  final PricingPeriod period;
  final String monthlyLabel;
  final String yearlyLabel;
  final ValueChanged<PricingPeriod> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colors.border,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo,
            alignment: period == PricingPeriod.monthly
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(PricingPeriod.monthly),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      monthlyLabel,
                      style: theme.typography.labelButton.copyWith(
                        fontWeight: period == PricingPeriod.monthly
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: period == PricingPeriod.monthly
                            ? theme.colors.primary
                            : theme.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(PricingPeriod.yearly),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      yearlyLabel,
                      style: theme.typography.labelButton.copyWith(
                        fontWeight: period == PricingPeriod.yearly
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: period == PricingPeriod.yearly
                            ? theme.colors.primary
                            : theme.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {

  const _PricingCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.period,
  });
  final PricingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final PricingPeriod period;

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _upward = true;

  @override
  void didUpdateWidget(_PricingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan.price != oldWidget.plan.price) {
      _upward = widget.plan.price > (oldWidget.plan.price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);

    // Split price into integer and decimal parts for independent flip animation
    final int intPart = widget.plan.price.floor();
    final int decPart = ((widget.plan.price - intPart) * 100).round();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: BorderRadius.circular(theme.cardRadius),
          border: Border.all(
            color: widget.isSelected
                ? theme.colors.primary
                : theme.colors.border,
            width: 2.0, // Fixed width for both states
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.plan.title, style: theme.typography.h4),
                      if (widget.plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.plan.badgeText,
                            style: theme.typography.caption.copyWith(
                              color: theme.colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$',
                        style: theme.typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      PremiumFlipCounter(
                        value: intPart,
                        upward: _upward,
                        padWithZero: false,
                        style: theme.typography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (decPart > 0 || widget.plan.price == 0) ...[
                        Text(
                          '.',
                          style: theme.typography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PremiumFlipCounter(
                          value: decPart,
                          upward: _upward,
                          style: theme.typography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      Text(
                        '/${widget.plan.periodText}',
                        style: theme.typography.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _SelectionIndicator(isSelected: widget.isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {

  const _SelectionIndicator({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = PortalTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? theme.colors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? theme.colors.primary : theme.colors.border,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: isSelected
            ? const Center(
                key: ValueKey('check_icon'),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              )
            : const SizedBox.shrink(key: ValueKey('empty_icon')),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {

  const _ActionButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => setState(() => _isPressed = true),
      onPanCancel: () => setState(() => _isPressed = false),
      onPanEnd: (_) => setState(() => _isPressed = false),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.96 : 1.0,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: PortalTheme.of(context).colors.primary,
            borderRadius: BorderRadius.circular(
              PortalTheme.of(context).borderRadius,
            ),
            boxShadow: [
              BoxShadow(
                color: PortalTheme.of(
                  context,
                ).colors.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: PortalTheme.of(context).typography.labelButton.copyWith(
                color: PortalTheme.of(context).colors.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
