import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('AdaptiveSliderInteraction Widget Tests', () {
    testWidgets('Should render title and initial value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSliderInteraction(
              value: 100,
              onChanged: (val) {},
            ),
          ),
        ),
      );

      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('kCal'), findsOneWidget);
      // Flip counter should show 100
      expect(find.bySemanticsLabel('100'), findsOneWidget);
    });

    testWidgets('Should call onChanged and snap value when tapped', (WidgetTester tester) async {
      double? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSliderInteraction(
              value: 0,
              max: 500,
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      // Find the track (GestureDetector is a child of the Column)
      // We can find it by finding the CustomPaint or by finding the parent container
      final Finder trackFinder = find.byType(GestureDetector).last;
      
      // Tap at the center (should be 250)
      await tester.tap(trackFinder);
      await tester.pump();

      expect(changedValue, 250.0);
    });

    testWidgets('Should call onChanged when dragging', (WidgetTester tester) async {
      double? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveSliderInteraction(
              value: 0,
              max: 500,
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      final Finder trackFinder = find.byType(GestureDetector).last;
      
      // Drag from left to right
      await tester.drag(trackFinder, const Offset(100, 0));
      await tester.pump();

      expect(changedValue, greaterThan(0));
      // Should be snapped to 50, 100, etc.
      expect(changedValue! % 50, 0.0);
    });
  });
}
