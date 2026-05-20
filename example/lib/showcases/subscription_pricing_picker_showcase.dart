import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class SubscriptionPricingPickerShowcase extends StatefulWidget {
  const SubscriptionPricingPickerShowcase({super.key});

  @override
  State<SubscriptionPricingPickerShowcase> createState() =>
      _SubscriptionPricingPickerShowcaseState();
}

class _SubscriptionPricingPickerShowcaseState
    extends State<SubscriptionPricingPickerShowcase> {
  final List<PricingPlan> _monthlyPlans = const [
    PricingPlan(id: 'free', title: 'Free', price: 0.0, periodText: 'month'),
    PricingPlan(
      id: 'starter',
      title: 'Starter',
      price: 9.99,
      periodText: 'month',
      isPopular: true,
      badgeText: 'Popular',
    ),
    PricingPlan(id: 'pro', title: 'Pro', price: 19.99, periodText: 'month'),
  ];

  final List<PricingPlan> _yearlyPlans = const [
    PricingPlan(id: 'free_year', title: 'Free', price: 0.0, periodText: 'year'),
    PricingPlan(
      id: 'starter_year',
      title: 'Starter',
      price: 99.90,
      periodText: 'year',
      isPopular: true,
      badgeText: 'Save 20%',
    ),
    PricingPlan(
      id: 'pro_year',
      title: 'Pro',
      price: 199.90,
      periodText: 'year',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Subscription Picker',
      description:
          'High-fidelity SaaS pricing selector with animated monthly/yearly '
          'billing toggle. Popular badge support, haptic feedback, and native '
          'light/dark mode via the PortalTheme design system.',
      codeSnippet: '''SubscriptionPricingPicker(
  monthlyPlans: [
    PricingPlan(id: 'free', title: 'Free', price: 0.0, periodText: 'month'),
    PricingPlan(id: 'pro', title: 'Pro', price: 9.99,
      periodText: 'month', isPopular: true),
  ],
  yearlyPlans: [ /* ... */ ],
  onSelect: (plan, period) => print('\${plan.title} \${period.name}'),
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SubscriptionPricingPicker(
                  monthlyPlans: _monthlyPlans,
                  yearlyPlans: _yearlyPlans,
                  onSelect: (plan, period) {
                    debugPrint('Selection: ${plan.title} - ${period.name}');
                  },
                  onActionPressed: (plan, period) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${plan.title} (${period.name})',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
