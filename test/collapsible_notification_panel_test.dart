import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('CollapsibleNotificationPanel', () {
    final testItems = [
      NotificationItem(
        id: '1',
        title: 'Test Title 1',
        description: 'Test Description 1',
        timestamp: 'Just Now',
        icon: Icons.notifications,
        onTap: () {},
      ),
      NotificationItem(
        id: '2',
        title: 'Test Title 2',
        description: 'Test Description 2',
        timestamp: '5m ago',
        icon: Icons.message,
        onTap: () {},
      ),
    ];

    testWidgets('renders header correctly in collapsed state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleNotificationPanel(
              items: testItems,
              collapsedSubtitle: 'Collapsed Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('2 New Activities'), findsOneWidget);
      expect(find.text('Collapsed Subtitle'), findsOneWidget);
    });

    testWidgets('expands and shows items when header is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleNotificationPanel(
              items: testItems,
            ),
          ),
        ),
      );

      // Tap header to expand
      await tester.tap(find.text('2 New Activities'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title 1'), findsOneWidget);
      expect(find.text('Test Title 2'), findsOneWidget);
    });

    testWidgets('triggers onExpansionChanged callback', (WidgetTester tester) async {
      bool expanded = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleNotificationPanel(
              items: testItems,
              onExpansionChanged: (val) => expanded = val,
            ),
          ),
        ),
      );

      await tester.tap(find.text('2 New Activities'));
      await tester.pumpAndSettle();

      expect(expanded, isTrue);
    });

    testWidgets('triggers onItemTap callback', (WidgetTester tester) async {
      NotificationItem? tappedItem;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleNotificationPanel(
              items: testItems,
              initiallyExpanded: true,
              onItemTap: (item) => tappedItem = item,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Title 1'));
      await tester.pumpAndSettle();

      expect(tappedItem?.id, '1');
    });

    testWidgets('respects style configurations', (WidgetTester tester) async {
      const customStyle = CollapsibleNotificationPanelStyle(
        backgroundColor: Colors.red,
        borderRadius: 10,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleNotificationPanel(
              items: [],
              style: customStyle,
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });
  });
}
