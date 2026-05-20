import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('CardStackInteraction Widget Tests', () {
    final List<CardStackItem> mockItems = [
      const CardStackItem(
        title: 'Camping',
        subtitle: 'Yosemite Park',
        date: '5 Aug',
        icon: Icons.landscape,
      ),
      const CardStackItem(
        title: 'Road Trip',
        subtitle: 'Highway 1',
        date: '10 Aug',
        icon: Icons.directions_car,
      ),
      const CardStackItem(
        title: 'Beach Day',
        subtitle: 'Malibu',
        date: '15 Aug',
        icon: Icons.beach_access,
      ),
    ];

    testWidgets('Should render initial collapsed state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CardStackInteraction(items: mockItems)),
        ),
      );

      // Verify titles are present (though some might be overlapped, they should exist in the tree)
      expect(find.text('Camping'), findsOneWidget);
      expect(find.text('Road Trip'), findsOneWidget);
      expect(find.text('Beach Day'), findsOneWidget);

      // Verify the button shows "Show All"
      expect(find.text('Show All'), findsOneWidget);
    });

    testWidgets('Should toggle expansion on button tap', (
      WidgetTester tester,
    ) async {
      bool? isExpanded;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardStackInteraction(
              items: mockItems,
              onExpansionChanged: (val) => isExpanded = val,
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Show All'), findsOneWidget);

      // Tap button to expand
      await tester.tap(find.text('Show All'));
      await tester.pumpAndSettle();

      expect(isExpanded, true);
      expect(find.text('Hide'), findsOneWidget);

      // Tap button to collapse
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(isExpanded, false);
      expect(find.text('Show All'), findsOneWidget);
    });

    testWidgets('Should only show up to 3 items', (WidgetTester tester) async {
      final List<CardStackItem> manyItems = List.generate(
        5,
        (i) => CardStackItem(
          title: 'Item $i',
          subtitle: 'Sub $i',
          date: 'Date $i',
          icon: Icons.star,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CardStackInteraction(items: manyItems)),
        ),
      );

      // Should find items 0, 1, 2
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);

      // Should NOT find item 3 and 4 (they are taken via .take(3))
      expect(find.text('Item 3'), findsNothing);
      expect(find.text('Item 4'), findsNothing);
    });
  });
}
