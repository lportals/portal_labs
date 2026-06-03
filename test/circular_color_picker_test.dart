import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('CircularColorPicker Tests', () {
    final List<Color> mockColors = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ];

    testWidgets('Should render all colors as rings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularColorPicker(
                colors: mockColors,
                selectedIndex: 0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders with correct structure
      expect(find.byType(CircularColorPicker), findsOneWidget);

      // Each color should be represented by a ring container in the widget tree.
      // We can search by key which contains the index.
      for (int i = 0; i < mockColors.length; i++) {
        expect(find.byKey(ValueKey('color_item_$i')), findsOneWidget);
      }
    });

    testWidgets('Should trigger onChanged callback when tapping a color', (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularColorPicker(
                colors: mockColors,
                selectedIndex: 0,
                onChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      // Tap on the blue color item (index 2)
      await tester.tap(find.byKey(const ValueKey('color_item_2')));
      await tester.pumpAndSettle();

      // Callback should have triggered with index 2
      expect(selectedIndex, equals(2));
    });

    testWidgets('Should not trigger onChanged when tapping disabled picker', (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularColorPicker(
                colors: mockColors,
                selectedIndex: 0,
                enabled: false,
                onChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      // Tap on the blue color item (index 2)
      await tester.tap(find.byKey(const ValueKey('color_item_2')));
      await tester.pumpAndSettle();

      // Callback should not be triggered since enabled is false
      expect(selectedIndex, isNull);
    });

    testWidgets('Should not trigger onChanged when tapping already selected color', (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularColorPicker(
                colors: mockColors,
                selectedIndex: 0,
                onChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      // Tap on the red color item (index 0), which is already selected
      await tester.tap(find.byKey(const ValueKey('color_item_0')));
      await tester.pumpAndSettle();

      // Callback should not be triggered since index 0 is already selected
      expect(selectedIndex, isNull);
    });
  });
}
