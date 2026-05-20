import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('CinematicTextTransition Widget Tests', () {
    testWidgets('renders initial text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CinematicTextTransition(text: 'Initial')),
        ),
      );

      // We search for individual characters since the widget splits them
      expect(find.text('I'), findsWidgets);
      expect(find.text('n'), findsWidgets);
      expect(find.text('t'), findsWidgets);
    });

    testWidgets('starts animation when text changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CinematicTextTransition(text: 'First')),
        ),
      );

      // Change text
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CinematicTextTransition(text: 'Second')),
        ),
      );

      // Wait for transition to start
      await tester.pump(const Duration(milliseconds: 600));

      // Both layers should be present (characters from both words)
      expect(find.text('F'), findsWidgets);
      expect(find.text('S'), findsWidgets);

      // Finish animation
      await tester.pumpAndSettle();

      expect(find.text('F'), findsNothing);
      expect(find.text('S'), findsWidgets);
    });

    testWidgets('respects custom duration from style', (
      WidgetTester tester,
    ) async {
      const duration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CinematicTextTransition(
              text: 'A',
              style: CinematicTextTransitionStyle(duration: duration),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CinematicTextTransition(
              text: 'B',
              style: CinematicTextTransitionStyle(duration: duration),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 250)); // Halfway
      expect(find.text('B'), findsWidgets);

      await tester.pump(
        const Duration(milliseconds: 300),
      ); // Should be finished
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsWidgets);
    });
  });
}
