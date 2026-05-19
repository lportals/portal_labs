import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('FolderTabs Widget Tests', () {
    testWidgets('renders all tab labels and the active child content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FolderTabs(
              tabs: const ['Tab A', 'Tab B', 'Tab C'],
              children: const [
                Text('Content A'),
                Text('Content B'),
                Text('Content C'),
              ],
            ),
          ),
        ),
      );

      // Verify all tab labels are visible on screen
      expect(find.text('Tab A'), findsOneWidget);
      expect(find.text('Tab B'), findsOneWidget);
      expect(find.text('Tab C'), findsOneWidget);

      // Verify initial active tab child is rendered
      expect(find.text('Content A'), findsOneWidget);
      expect(find.text('Content B'), findsNothing);
      expect(find.text('Content C'), findsNothing);
    });

    testWidgets('switches content and invokes callback on tab tap',
        (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FolderTabs(
              tabs: const ['Tab A', 'Tab B', 'Tab C'],
              onSelect: (index) => selectedIndex = index,
              children: const [
                Text('Content A'),
                Text('Content B'),
                Text('Content C'),
              ],
            ),
          ),
        ),
      );

      // Tap on Tab B
      await tester.tap(find.text('Tab B'));

      // Complete animations (physics-based spring and AnimatedSwitcher)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify callback is triggered with index 1
      expect(selectedIndex, equals(1));

      // Verify content B is now visible
      expect(find.text('Content B'), findsOneWidget);
      expect(find.text('Content A'), findsNothing);
    });

    testWidgets('supports controlled state using currentIndex',
        (WidgetTester tester) async {
      int activeIndex = 0;

      // Stateful wrapper to mock parent state changes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FolderTabs(
                  tabs: const ['Tab X', 'Tab Y'],
                  currentIndex: activeIndex,
                  onSelect: (index) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                  children: const [
                    Text('Content X'),
                    Text('Content Y'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify Content X is active initially
      expect(find.text('Content X'), findsOneWidget);
      expect(find.text('Content Y'), findsNothing);

      // Tap on Tab Y
      await tester.tap(find.text('Tab Y'));

      // Let animations settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify activeIndex updated and Content Y is now displayed
      expect(activeIndex, equals(1));
      expect(find.text('Content Y'), findsOneWidget);
      expect(find.text('Content X'), findsNothing);
    });
  });
}
