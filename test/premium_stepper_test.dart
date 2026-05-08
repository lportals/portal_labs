import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PremiumStepper', () {
    testWidgets('renders correctly with initial value', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumStepper(
              value: 10,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(tester.getSemantics(find.byKey(const ValueKey('flip_counter_semantics'))).label.contains('10'), isTrue);
      
      final minusNode = tester.getSemantics(find.byKey(const ValueKey('stepper_minus')));
      expect(minusNode.label, 'Decrement');
      expect(minusNode.flagsCollection.isButton, isTrue);
      expect(minusNode.flagsCollection.isEnabled, isTrue);
      
      final plusNode = tester.getSemantics(find.byKey(const ValueKey('stepper_plus')));
      expect(plusNode.label, 'Increment');
      expect(plusNode.flagsCollection.isButton, isTrue);
      expect(plusNode.flagsCollection.isEnabled, isTrue);
      
      handle.dispose();
    });

    testWidgets('triggers onChanged when increment is clicked', (WidgetTester tester) async {
      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumStepper(
              value: 10,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('stepper_plus')));
      await tester.pump();

      expect(changedValue, 11);
    });

    testWidgets('triggers onChanged when decrement is clicked', (WidgetTester tester) async {
      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumStepper(
              value: 10,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('stepper_minus')));
      await tester.pump();

      expect(changedValue, 9);
    });

    testWidgets('respects min/max limits', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      int? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumStepper(
              value: 0,
              max: 2,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final minusNode = tester.getSemantics(find.byKey(const ValueKey('stepper_minus')));
      expect(minusNode.flagsCollection.isEnabled, isFalse);
      
      await tester.tap(find.byKey(const ValueKey('stepper_minus')));
      await tester.pump();
      expect(changedValue, isNull);

      await tester.tap(find.byKey(const ValueKey('stepper_plus')));
      await tester.pump();
      expect(changedValue, 1);
      
      // Update widget with new value to check max
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumStepper(
              value: 2,
              max: 2,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final plusNode = tester.getSemantics(find.byKey(const ValueKey('stepper_plus')));
      expect(plusNode.flagsCollection.isEnabled, isFalse);
      
      handle.dispose();
    });
  });
}
