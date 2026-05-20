import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('JournalNavigation Widget Tests', () {
    final List<JournalItem> mockItems = [
      JournalItem(
        date: DateTime(2023, 10),
        title: 'Day 1',
        content: 'Content 1',
      ),
      JournalItem(
        date: DateTime(2023, 10, 2),
        title: 'Day 2',
        content: 'Content 2',
      ),
      JournalItem(
        date: DateTime(2023, 10, 3),
        title: 'Day 3',
        content: 'Content 3',
      ),
    ];

    testWidgets('Should render initial item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalNavigation(
              items: mockItems,
              initialDate: DateTime(2023, 10),
            ),
          ),
        ),
      );

      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
    });

    testWidgets('Should navigate with arrows', (WidgetTester tester) async {
      JournalItem? selectedItem;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalNavigation(
              items: mockItems,
              onDateChanged: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      // Tap next arrow
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Day 2'), findsOneWidget);
      expect(selectedItem!.title, 'Day 2');
    });

    testWidgets('Should navigate with vertical scroller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: JournalNavigation(items: mockItems)),
        ),
      );

      // Find '03' in the scroller
      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      expect(find.text('Day 3'), findsOneWidget);
    });
  });
}
