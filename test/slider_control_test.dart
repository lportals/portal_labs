import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('SliderControl Tests', () {
    testWidgets('Should render track and floating badge with correct value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SliderControl(
                value: 20.0,
                min: 10.0,
                max: 30.0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify widget renders in the tree
      expect(find.byType(SliderControl), findsOneWidget);

      // Verify the value text is displayed inside the badge
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('Should trigger onChanged callback when dragging vertically', (WidgetTester tester) async {
      double? updatedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SliderControl(
                value: 20.0,
                min: 10.0,
                max: 30.0,
                onChanged: (v) {
                  updatedValue = v;
                },
                height: 300,
              ),
            ),
          ),
        ),
      );

      // Verify initial state text
      expect(find.text('20'), findsOneWidget);

      // Perform a vertical drag gesture on the track pill of the SliderControl
      final trackCenter = tester.getCenter(find.byType(GestureDetector));
      final gesture = await tester.startGesture(trackCenter);
      await gesture.moveBy(const Offset(0, -50)); // Drag up (values increase)
      await tester.pump();

      // Verify callback triggers
      expect(updatedValue, isNotNull);
      expect(updatedValue!, greaterThan(20.0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Should snap to nearest step on gesture release', (WidgetTester tester) async {
      double? finalValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SliderControl(
                value: 20.0,
                min: 10.0,
                max: 30.0,
                step: 5.0, // Large steps to easily check snap logic
                onChanged: (v) {
                  finalValue = v;
                },
                height: 300,
              ),
            ),
          ),
        ),
      );

      // Drag up slightly but release
      final trackCenter = tester.getCenter(find.byType(GestureDetector));
      final gesture = await tester.startGesture(trackCenter);
      await gesture.moveBy(const Offset(0, -60)); // Move up slightly
      await gesture.up();
      await tester.pumpAndSettle(); // Settle spring animations

      // Value should have snapped to either 20.0 or 25.0
      expect(finalValue, isNotNull);
      expect(finalValue! % 5.0, equals(0.0));
    });

    testWidgets('Should trigger onChangeEnd callback when drag is completed', (WidgetTester tester) async {
      double? endValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SliderControl(
                value: 20.0,
                min: 10.0,
                max: 30.0,
                onChanged: (_) {},
                onChangeEnd: (v) {
                  endValue = v;
                },
                height: 300,
              ),
            ),
          ),
        ),
      );

      final trackCenter = tester.getCenter(find.byType(GestureDetector));
      final gesture = await tester.startGesture(trackCenter);
      await gesture.moveBy(const Offset(0, -60)); // Move up slightly
      await gesture.up();
      await tester.pumpAndSettle(); // Settle spring animations

      expect(endValue, isNotNull);
      expect(endValue!, greaterThan(20.0));
    });
  });
}
