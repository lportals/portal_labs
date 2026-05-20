import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('SubscriptionPricingPicker Widget Tests', () {
    final List<PricingPlan> monthlyPlans = [
      const PricingPlan(
        id: 'basic_mo',
        title: 'Basic',
        price: 9.99,
        periodText: 'mo',
      ),
      const PricingPlan(
        id: 'pro_mo',
        title: 'Pro',
        price: 19.99,
        periodText: 'mo',
        isPopular: true,
      ),
    ];

    final List<PricingPlan> yearlyPlans = [
      const PricingPlan(
        id: 'basic_yr',
        title: 'Basic',
        price: 99.00,
        periodText: 'yr',
      ),
      const PricingPlan(
        id: 'pro_yr',
        title: 'Pro',
        price: 199.00,
        periodText: 'yr',
        isPopular: true,
      ),
    ];

    testWidgets('Should render monthly plans by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalTheme(
              data: PortalThemeData.light(),
              child: SubscriptionPricingPicker(
                monthlyPlans: monthlyPlans,
                yearlyPlans: yearlyPlans,
              ),
            ),
          ),
        ),
      );

      // Verify plans are shown
      expect(find.text('Basic'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      // Verify monthly price
      expect(find.bySemanticsLabel('9'), findsOneWidget); // Basic int part
      expect(find.bySemanticsLabel('19'), findsOneWidget); // Pro int part
      expect(
        find.bySemanticsLabel('99'),
        findsNWidgets(2),
      ); // Both decimal parts
    });

    testWidgets('Should toggle to yearly plans', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalTheme(
              data: PortalThemeData.light(),
              child: SubscriptionPricingPicker(
                monthlyPlans: monthlyPlans,
                yearlyPlans: yearlyPlans,
              ),
            ),
          ),
        ),
      );

      // Tap on Yearly toggle
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();

      // Verify yearly price
      expect(
        find.bySemanticsLabel('99'),
        findsOneWidget,
      ); // Basic int part (99.00)
      expect(
        find.bySemanticsLabel('199'),
        findsOneWidget,
      ); // Pro int part (199.00)
    });

    testWidgets('Should call onSelect when a plan is tapped', (
      WidgetTester tester,
    ) async {
      PricingPlan? selectedPlan;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalTheme(
              data: PortalThemeData.light(),
              child: SubscriptionPricingPicker(
                monthlyPlans: monthlyPlans,
                yearlyPlans: yearlyPlans,
                onSelect: (plan, period) => selectedPlan = plan,
              ),
            ),
          ),
        ),
      );

      // Tap on 'Basic' plan
      await tester.tap(find.text('Basic'));
      await tester.pumpAndSettle();

      expect(selectedPlan, monthlyPlans[0]);
    });

    testWidgets('Should call onActionPressed when CTA is tapped', (
      WidgetTester tester,
    ) async {
      PricingPlan? actionPlan;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortalTheme(
              data: PortalThemeData.light(),
              child: SubscriptionPricingPicker(
                monthlyPlans: monthlyPlans,
                yearlyPlans: yearlyPlans,
                onActionPressed: (plan, period) => actionPlan = plan,
              ),
            ),
          ),
        ),
      );

      // Tap on 'Get Started'
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(actionPlan, monthlyPlans[1]);
    });
  });
}
