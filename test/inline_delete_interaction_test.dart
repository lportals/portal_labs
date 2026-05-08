import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('InlineDeleteInteraction', () {
    final testItems = [
      const InlineAction(title: 'Edit', icon: Icons.edit),
      const InlineAction(title: 'Delete', icon: Icons.delete, isDestructive: true),
    ];

    testWidgets('renders title and items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineDeleteInteraction(
              title: 'OPTIONS',
              items: testItems,
              onCloseRequested: () {},
            ),
          ),
        ),
      );

      expect(find.text('OPTIONS'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows confirmation buttons on destructive item tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineDeleteInteraction(
              title: 'OPTIONS',
              items: testItems,
              onCloseRequested: () {},
            ),
          ),
        ),
      );

      // Initially confirm button is not visible
      expect(find.text('Confirm Delete'), findsNothing);

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('triggers onConfirm when confirmation button is tapped', (WidgetTester tester) async {
      bool deleteTriggered = false;
      bool closeRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineDeleteInteraction(
              title: 'OPTIONS',
              items: [
                const InlineAction(title: 'Edit', icon: Icons.edit),
                InlineAction(
                  title: 'Delete',
                  icon: Icons.delete,
                  isDestructive: true,
                  onTap: () => deleteTriggered = true,
                ),
              ],
              onCloseRequested: () => closeRequested = true,
            ),
          ),
        ),
      );

      // Open confirm state
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap Confirm Delete
      await tester.tap(find.text('Confirm Delete'));
      await tester.pumpAndSettle();

      expect(deleteTriggered, isTrue);
      expect(closeRequested, isTrue);
    });

    testWidgets('returns to normal state on cancel tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineDeleteInteraction(
              title: 'OPTIONS',
              items: testItems,
              onCloseRequested: () {},
            ),
          ),
        ),
      );

      // Open confirm state
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delete'), findsNothing);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('triggers onCloseRequested when close icon is tapped', (WidgetTester tester) async {
      bool closeRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineDeleteInteraction(
              title: 'OPTIONS',
              items: testItems,
              onCloseRequested: () => closeRequested = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closeRequested, isTrue);
    });
  });
}
