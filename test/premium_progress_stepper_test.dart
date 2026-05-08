import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PremiumProgressStepper', () {
    testWidgets('renders correctly and shows progress dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 0,
            ),
          ),
        ),
      );

      // Verify indicator is present
      expect(find.byType(PremiumProgressIndicator), findsOneWidget);
      // Verify "Continue" button is present
      expect(find.text('Continue'), findsOneWidget);
      // Verify "Back" button is not visible yet (currentStep is 0)
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('shows Back button when currentStep > 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows Finish on the last step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 2,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('triggers onStepChanged when Continue is tapped', (WidgetTester tester) async {
      int? nextStep;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 0,
              onStepChanged: (step) => nextStep = step,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(nextStep, 1);
    });

    testWidgets('triggers onStepChanged when Back is tapped', (WidgetTester tester) async {
      int? prevStep;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 1,
              onStepChanged: (step) => prevStep = step,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pump();

      expect(prevStep, 0);
    });

    testWidgets('triggers onFinish when Finish is tapped', (WidgetTester tester) async {
      bool finished = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 2,
              currentStep: 1,
              onFinish: () => finished = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pump();

      expect(finished, isTrue);
    });

    testWidgets('respects canContinue constraint', (WidgetTester tester) async {
      int? nextStep;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumProgressStepper(
              totalSteps: 3,
              currentStep: 0,
              canContinue: false,
              onStepChanged: (step) => nextStep = step,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(nextStep, isNull);
    });
  });
}
