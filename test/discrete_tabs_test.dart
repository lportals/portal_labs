import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('DiscreteTabs Widget Tests', () {
    final List<DiscreteTab> mockTabs = [
      const DiscreteTab(
        label: 'Home',
        icon: Icons.home,
        activeColor: Colors.blue,
      ),
      const DiscreteTab(
        label: 'Search',
        icon: Icons.search,
        activeColor: Colors.green,
      ),
      const DiscreteTab(
        label: 'Profile',
        icon: Icons.person,
        activeColor: Colors.red,
      ),
    ];

    testWidgets('Should render initial selection correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscreteTabs(
              tabs: mockTabs,
            ),
          ),
        ),
      );

      // Verify the first tab label is visible (selected)
      expect(find.text('Home'), findsOneWidget);
      // Verify other tab labels are not visible
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);
      
      // All icons should be present
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Should change selection when a different tab is tapped', (WidgetTester tester) async {
      int? selectedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscreteTabs(
              tabs: mockTabs,
              onSelect: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      // Tap on the second tab (Search)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('Should respect external currentIndex control', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscreteTabs(
              tabs: mockTabs,
              currentIndex: 2,
            ),
          ),
        ),
      );

      // Initially should show Profile
      expect(find.text('Profile'), findsOneWidget);

      // Update to Home
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscreteTabs(
              tabs: mockTabs,
              currentIndex: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
    });
  });
}
