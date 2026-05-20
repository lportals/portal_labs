import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PremiumSortableGrid', () {
    testWidgets('renders all items', (WidgetTester tester) async {
      final items = [1, 2, 3];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumSortableGrid<int>(
              items: items,
              idBuilder: (item) => item,
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, item) => Text('Item $item'),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('triggers onReorder when item is dragged over another', (
      WidgetTester tester,
    ) async {
      int? reorderedOld;
      int? reorderedNew;

      final items = [1, 2, 3];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: PremiumSortableGrid<int>(
                items: items,
                idBuilder: (item) => item,
                onReorder: (oldIndex, newIndex) {
                  reorderedOld = oldIndex;
                  reorderedNew = newIndex;
                },
                style: const PremiumSortableGridStyle(spacing: 0),
                itemBuilder: (context, item) => SizedBox(
                  key: ValueKey('box_$item'),
                  width: 100,
                  height: 100,
                  child: Text('Item $item'),
                ),
              ),
            ),
          ),
        ),
      );

      // Long press to start drag on Item 1
      final firstItem = find.text('Item 1');
      final firstItemCenter = tester.getCenter(firstItem);

      final gesture = await tester.startGesture(firstItemCenter);
      await tester.pump(
        const Duration(milliseconds: 600),
      ); // Long press duration

      // Drag to Item 2
      final secondItem = find.text('Item 2');
      final secondItemCenter = tester.getCenter(secondItem);

      await gesture.moveTo(secondItemCenter);
      await tester.pump();

      expect(reorderedOld, 0);
      expect(reorderedNew, 1);

      await gesture.up();
      await tester.pump();
    });

    testWidgets('respects crossAxisCount', (WidgetTester tester) async {
      final items = [1, 2, 3, 4];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: PremiumSortableGrid<int>(
                items: items,
                idBuilder: (item) => item,
                onReorder: (oldIndex, newIndex) {},
                style: const PremiumSortableGridStyle(
                  crossAxisCount: 2,
                  spacing: 0,
                ),
                itemBuilder: (context, item) => Text('Item $item'),
              ),
            ),
          ),
        ),
      );

      // With width 200 and crossAxisCount 2, each item is 100x100.
      // Item 1 (index 0) is at (0, 0)
      // Item 2 (index 1) is at (100, 0)
      // Item 3 (index 2) is at (0, 100)
      // Item 4 (index 3) is at (100, 100)

      expect(tester.getTopLeft(find.text('Item 1')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('Item 2')), const Offset(100, 0));
      expect(tester.getTopLeft(find.text('Item 3')), const Offset(0, 100));
      expect(tester.getTopLeft(find.text('Item 4')), const Offset(100, 100));
    });
  });
}
