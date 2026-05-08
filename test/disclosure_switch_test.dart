import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('DisclosureSwitch', () {
    testWidgets('renders title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisclosureSwitch(
              title: 'Notifications',
              value: false,
              onChanged: (_) {},
              icon: const Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('triggers onChanged when tapped', (WidgetTester tester) async {
      bool? newValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisclosureSwitch(
              title: 'Toggle Me',
              value: false,
              onChanged: (val) => newValue = val,
            ),
          ),
        ),
      );

      // Find the switch track (GestureDetector in _PremiumSwitch)
      // We can tap the title or the switch. The title row is wrapped in a Container, 
      // but the switch itself is a GestureDetector.
      await tester.tap(find.text('Toggle Me'));
      // Wait, let's check if the title row is interactive.
      // _DisclosureSwitchState.build -> Row -> _PremiumSwitch
      // Only _PremiumSwitch has a GestureDetector.
      
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();

      expect(newValue, isTrue);
    });

    testWidgets('shows revealedChild when value is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisclosureSwitch(
              title: 'Show Details',
              value: true,
              onChanged: (_) {},
              revealedChild: const Text('Hidden Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Hidden Content'), findsOneWidget);
    });

    testWidgets('hides revealedChild when value is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisclosureSwitch(
              title: 'Hide Details',
              value: false,
              onChanged: (_) {},
              revealedChild: const Text('Hidden Content'),
            ),
          ),
        ),
      );

      // It might be in the tree but with opacity 0 or height 0.
      // The implementation uses Align with heightFactor: t.clamp(0.0, 1.0)
      // and returns SizedBox.shrink() if t <= 0.001.
      
      await tester.pumpAndSettle();
      expect(find.text('Hidden Content'), findsNothing);
    });
  });
}
