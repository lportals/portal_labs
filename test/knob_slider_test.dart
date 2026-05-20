import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('KnobSlider Widget Tests', () {
    testWidgets('Should render initial value correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: KnobSlider(value: 50.0, onChanged: (val) {})),
          ),
        ),
      );

      // Verify the initial value via semantics label (PremiumFlipCounter uses Semantics)
      expect(find.bySemanticsLabel('50'), findsOneWidget);
    });

    testWidgets('Should call onChanged when dragged', (
      WidgetTester tester,
    ) async {
      double? newValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: KnobSlider(
                value: 50.0,
                onChanged: (val) => newValue = val,
                size: 200,
              ),
            ),
          ),
        ),
      );

      final Finder sliderFinder = find.byType(KnobSlider);
      final Offset center = tester.getCenter(sliderFinder);

      // Start drag at the top
      final TestGesture gesture = await tester.startGesture(
        center + const Offset(0, -60),
      );
      await tester.pump();
      // Move in a small arc to the right
      await gesture.moveTo(center + const Offset(42, -42));
      await tester.pump();
      await gesture.moveTo(center + const Offset(60, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(newValue, isNotNull);
      expect(newValue!, greaterThan(50.0));
    });

    testWidgets('Should respect boundaries', (WidgetTester tester) async {
      double? lastValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: KnobSlider(
                value: 95.0,
                onChanged: (val) => lastValue = val,
                size: 200,
              ),
            ),
          ),
        ),
      );

      final Offset center = tester.getCenter(find.byType(KnobSlider));

      // Drag clockwise significantly to hit the max
      final TestGesture gesture = await tester.startGesture(
        center + const Offset(60, 0),
      ); // Right
      await tester.pump();
      await gesture.moveTo(center + const Offset(0, 60)); // Bottom
      await tester.pump();
      await gesture.moveTo(center + const Offset(-60, 0)); // Left
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Should be clamped at 100
      expect(lastValue, 100.0);
    });
  });
}
