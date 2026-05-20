import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/split_to_edit/widgets/split_to_edit_duration.dart';
import 'package:portal_labs/src/split_to_edit/models/split_to_edit_style.dart';

void main() {
  group('SplitToEditDuration', () {
    testWidgets('renders correctly in collapsed state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SplitToEditDuration(hours: 2, minutes: 30)),
          ),
        ),
      );

      // Verify values are displayed
      expect(find.text('2'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Hr.'), findsOneWidget);
      expect(find.text('Min.'), findsOneWidget);

      // Verify edit icon
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });

    testWidgets('toggles to editing state when tapping edit icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SplitToEditDuration(hours: 2, minutes: 30)),
          ),
        ),
      );

      // Tap the edit icon (Action Segment)
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pump();
      // ElasticOutCurve takes a while to settle
      await tester.pump(const Duration(seconds: 1));

      // Verify check icon appears
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify text fields are enabled
      final hourField = tester.widget<TextField>(
        find
            .ancestor(of: find.text('2'), matching: find.byType(TextField))
            .first,
      );
      expect(hourField.enabled, isTrue);
    });

    testWidgets('updates values when editing and clicking check', (
      WidgetTester tester,
    ) async {
      int? updatedHours;
      int? updatedMinutes;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SplitToEditDuration(
                hours: 2,
                minutes: 30,
                onChanged: (h, m) {
                  updatedHours = h;
                  updatedMinutes = m;
                },
              ),
            ),
          ),
        ),
      );

      // Enter editing mode
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      // Find the TextField for hours and enter "5"
      // Note: text is currently "2"
      final hourFinder = find
          .ancestor(of: find.text('2'), matching: find.byType(TextField))
          .first;
      await tester.enterText(hourFinder, '5');

      // Find the TextField for minutes and enter "45"
      final minFinder = find
          .ancestor(of: find.text('30'), matching: find.byType(TextField))
          .first;
      await tester.enterText(minFinder, '45');

      // Click check icon to commit
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(updatedHours, 5);
      expect(updatedMinutes, 45);
    });

    testWidgets('clamps values to max limits', (WidgetTester tester) async {
      int? updatedHours;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SplitToEditDuration(
                hours: 2,
                minutes: 30,
                maxLeftValue: 12,
                onChanged: (h, m) {
                  updatedHours = h;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      final hourFinder = find
          .ancestor(of: find.text('2'), matching: find.byType(TextField))
          .first;
      await tester.enterText(hourFinder, '20'); // Past max of 12

      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(updatedHours, 12);
    });

    testWidgets('custom style is respected', (WidgetTester tester) async {
      const customStyle = SplitToEditStyle(
        backgroundColor: Colors.blueGrey,
        borderRadius: 10.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SplitToEditDuration(
                hours: 2,
                minutes: 30,
                style: customStyle,
              ),
            ),
          ),
        ),
      );

      // Check the background color of a segment wrapper
      // We can look for the Container inside the _SegmentWrapper
      final containerFinder = find
          .descendant(of: find.byType(Row), matching: find.byType(Container))
          .first;

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blueGrey);
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
