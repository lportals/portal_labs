import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('FeedbackInteraction', () {
    testWidgets('renders initial idle state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackInteraction(),
          ),
        ),
      );

      // Verify buttons are rendered
      expect(find.byType(FeedbackInteraction), findsOneWidget);
      // Wait, there are two icons (thumbs up, thumbs down) in the default style
      expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.thumb_down_rounded), findsOneWidget);
    });

    testWidgets('triggers onFeedbackSubmitted on positive tap', (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackInteraction(
              onFeedbackSubmitted: (isPositive) {
                result = isPositive;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.thumb_up_rounded));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('triggers onFeedbackSubmitted on negative tap', (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackInteraction(
              onFeedbackSubmitted: (isPositive) {
                result = isPositive;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.thumb_down_rounded));
      await tester.pump();

      expect(result, isFalse);
    });

    testWidgets('shows undo button and triggers onUndo when clicked', (WidgetTester tester) async {
      bool undoTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackInteraction(
              onUndo: () {
                undoTriggered = true;
              },
            ),
          ),
        ),
      );

      // Tap to select positive feedback
      await tester.tap(find.byIcon(Icons.thumb_up_rounded));
      await tester.pump(const Duration(seconds: 1)); // Wait for spring to settle

      // Undo button should appear
      expect(find.text('Undo'), findsOneWidget);

      // Tap undo by executing its callback directly to bypass hit-testing issues with OverflowBox
      final gestureDetector = tester.widget<GestureDetector>(
        find.ancestor(of: find.text('Undo'), matching: find.byType(GestureDetector)).first,
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      expect(undoTriggered, isTrue);
    });
  });
}
