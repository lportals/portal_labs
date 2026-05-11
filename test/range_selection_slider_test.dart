import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('RangeSelectionSlider Widget Tests', () {
    testWidgets('Should render title and initial values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RangeSelectionSlider(
              values: RangeValues(1000, 4000),
              title: 'Test Price Range',
            ),
          ),
        ),
      );

      expect(find.text('Test Price Range'), findsOneWidget);
      // Verify flip counters show initial values (formatted with commas)
      expect(find.bySemanticsLabel('1,000'), findsOneWidget);
      expect(find.bySemanticsLabel('4,000'), findsOneWidget);
    });

    testWidgets('Should call onChanged when dragging slider', (WidgetTester tester) async {
      RangeValues? changedValues;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelectionSlider(
              values: const RangeValues(1000, 4000),
              onChanged: (val) => changedValues = val,
            ),
          ),
        ),
      );

      // Find the RangeSlider
      final Finder sliderFinder = find.byType(RangeSlider);
      final Offset topLeft = tester.getTopLeft(sliderFinder);
      final double width = tester.getSize(sliderFinder).width;
      
      // Calculate position of the first handle (1000 is 20% of 5000)
      // RangeSlider has some internal padding (usually 24 pixels on each side)
      final double xPos = topLeft.dx + (width * 0.2);
      final Offset handlePos = Offset(xPos, topLeft.dy + 24); // 24 is approximate vertical center
      
      await tester.dragFrom(handlePos, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(changedValues, isNotNull);
      expect(changedValues!.start, lessThan(1000));
    });

    testWidgets('Should allow manual entry of values', (WidgetTester tester) async {
      RangeValues? changedValues;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelectionSlider(
              values: const RangeValues(1000, 4000),
              onChanged: (val) => changedValues = val,
            ),
          ),
        ),
      );

      // Tap on the 'From' field to focus
      // Since it's a stack with a gesture detector on top, we can find it by key
      await tester.tap(find.byKey(const ValueKey('from_field')));
      await tester.pumpAndSettle();

      // Enter new value
      await tester.enterText(find.byType(TextField).first, '500');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(changedValues!.start, 500.0);
      expect(find.bySemanticsLabel('500'), findsOneWidget);
    });

    testWidgets('Should call onApply when Apply button is pressed', (WidgetTester tester) async {
      RangeValues? appliedValues;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelectionSlider(
              values: const RangeValues(1000, 4000),
              onApply: (val) => appliedValues = val,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(appliedValues, const RangeValues(1000, 4000));
    });

    testWidgets('Should call onCancel when Cancel button is pressed', (WidgetTester tester) async {
      bool cancelled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RangeSelectionSlider(
              values: const RangeValues(1000, 4000),
              onApply: (v) {},
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
