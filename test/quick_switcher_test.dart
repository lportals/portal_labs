import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('QuickSwitcher', () {
    final List<QuickSwitcherOption> testOptions = [
      const QuickSwitcherOption(label: 'Search', icon: Icons.search, placeholder: 'Search something...'),
      const QuickSwitcherOption(label: 'Link', icon: Icons.link, placeholder: 'Enter URL...'),
      const QuickSwitcherOption(label: 'Email', icon: Icons.email, placeholder: 'Email address...'),
    ];

    testWidgets('renders current option icon and placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickSwitcher(
              options: testOptions,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search something...'), findsOneWidget);
    });

    testWidgets('toggles to next option on tap', (WidgetTester tester) async {
      int? changedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickSwitcher(
              options: testOptions,
              onOptionChanged: (index) => changedIndex = index,
            ),
          ),
        ),
      );

      // Tap the switch button (first child of the Row)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(changedIndex, 1);
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.text('Enter URL...'), findsOneWidget);
    });

    testWidgets('shows menu on long press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickSwitcher(
              options: testOptions,
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.search));
      // Pump several times for the menu animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Menu should be visible. In the menu, it displays the placeholder.
      // We expect at least one more instance of the placeholders.
      expect(find.text('Search something...'), findsAtLeast(1));
      expect(find.text('Enter URL...'), findsAtLeast(1));
      expect(find.text('Email address...'), findsOneWidget); 
    });

    testWidgets('submits text when action button is tapped', (WidgetTester tester) async {
      String? submittedText;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickSwitcher(
              options: testOptions,
              onSubmitted: (text) => submittedText = text,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(submittedText, 'Hello World');
    });
  });
}
