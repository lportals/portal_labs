import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/discovery_bar/discovery_bar.dart';
import 'package:portal_labs/src/discovery_bar/models/discovery_bar_models.dart';

void main() {
  group('DiscoveryBar', () {
    final options = [
      const DiscoveryOption(label: 'Coffee', icon: Icons.coffee),
      const DiscoveryOption(label: 'Food', icon: Icons.restaurant),
      const DiscoveryOption(label: 'Hotels', icon: Icons.hotel),
    ];

    testWidgets('renders in searching state by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryBar(
              options: options,
              searchPlaceholder: 'Search here',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search here'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Coffee'), findsNothing);
    });

    testWidgets('toggles to discovery state when close icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryBar(
              options: options,
            ),
          ),
        ),
      );

      // Tap the close icon to switch to discovery mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Hotels'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('toggles back to search state when search icon is tapped in discovery mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryBar(
              options: options,
            ),
          ),
        ),
      );

      // Switch to discovery
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Tap search icon to switch back
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Coffee'), findsNothing);
    });

    testWidgets('triggers onOptionSelected when an option is tapped', (WidgetTester tester) async {
      DiscoveryOption? selectedOption;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryBar(
              options: options,
              onOptionSelected: (opt) => selectedOption = opt,
            ),
          ),
        ),
      );

      // Switch to discovery
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Tap 'Food'
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      expect(selectedOption, isNotNull);
      expect(selectedOption?.label, 'Food');
    });

    testWidgets('triggers onSearchSubmitted when search is submitted', (WidgetTester tester) async {
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscoveryBar(
              options: options,
              onSearchSubmitted: (val) => submittedText = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Testing 123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedText, 'Testing 123');
    });
  });
}
