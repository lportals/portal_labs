import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PinnableList', () {
    final testItems = [
      const PinnableItem(id: '1', title: 'Item 1', subtitle: 'Subtitle 1', isPinned: true),
      const PinnableItem(id: '2', title: 'Item 2', subtitle: 'Subtitle 2'),
      const PinnableItem(id: '3', title: 'Item 3', subtitle: 'Subtitle 3'),
    ];

    testWidgets('renders section headers and items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinnableList(
              items: testItems,
            ),
          ),
        ),
      );

      expect(find.text('Pinned Items'), findsOneWidget);
      expect(find.text('All Items'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('toggles pinned state on tap', (WidgetTester tester) async {
      List<PinnableItem>? updatedItems;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinnableList(
              items: testItems,
              onChanged: (items) => updatedItems = items,
            ),
          ),
        ),
      );

      // Tap the pin icon for Item 2
      final pinIcon = find.byIcon(Icons.push_pin_outlined).first;
      await tester.tap(pinIcon);
      // Use manual pumps to avoid timeout
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(updatedItems, isNotNull);
      final item2 = updatedItems!.firstWhere((it) => it.id == '2');
      expect(item2.isPinned, isTrue);
    });

    testWidgets('shows badge with correct count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinnableList(
              items: testItems,
            ),
          ),
        ),
      );

      // 1 pinned, 2 unpinned.
      expect(find.text('1'), findsOneWidget); // Badge for pinned
      expect(find.text('2'), findsOneWidget); // Badge for unpinned
    });

    testWidgets('uses custom itemBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinnableList(
              items: testItems,
              itemBuilder: (context, item, onToggle) {
                return ListTile(
                  title: Text('Custom ${item.title}'),
                  onTap: onToggle,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Custom Item 1'), findsOneWidget);
      expect(find.text('Custom Item 2'), findsOneWidget);
    });
  });
}
