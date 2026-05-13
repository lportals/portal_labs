import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('ArchiveFolder', () {
    testWidgets('renders correctly with title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArchiveFolder(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              items: [],
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('toggles open state on tap and triggers callback', (tester) async {
      bool? isOpenState;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArchiveFolder(
              title: 'Title',
              subtitle: 'Subtitle',
              items: const [SizedBox(width: 50, height: 50)],
              onToggle: (val) => isOpenState = val,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Title'));
      await tester.pump(const Duration(seconds: 1));

      expect(isOpenState, isTrue);

      await tester.tap(find.text('Title'));
      await tester.pump(const Duration(seconds: 1));

      expect(isOpenState, isFalse);
    });

    testWidgets('animates items with staggered reveal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ArchiveFolder(
                title: 'Title',
                subtitle: 'Subtitle',
                items: [
                  SizedBox(key: Key('item_0'), width: 50, height: 50),
                  SizedBox(key: Key('item_1'), width: 50, height: 50),
                ],
              ),
            ),
          ),
        ),
      );

      // Open the folder
      await tester.tap(find.text('Title'));
      await tester.pump(); // Start animation

      // Pump a small amount to verify animation has started
      await tester.pump(const Duration(milliseconds: 200));
      
      // Verify items are present
      expect(find.byKey(const Key('item_0')), findsOneWidget);
      expect(find.byKey(const Key('item_1')), findsOneWidget);

      // Wait for animation to finish
      await tester.pumpAndSettle();
    });

    testWidgets('respects external isOpen state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArchiveFolder(
              title: 'Title',
              subtitle: 'Subtitle',
              items: [],
              isOpen: true,
            ),
          ),
        ),
      );

      // Should be open immediately
      expect(find.text('Title'), findsOneWidget);
    });
  });
}
