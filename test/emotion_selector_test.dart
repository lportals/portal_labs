import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/emotion_selector/emotion_selector.dart';
import 'package:portal_labs/src/emotion_selector/models/emotion_selector_style.dart';

void main() {
  group('EmotionSelector Tests', () {
    testWidgets('renders all idle pills correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionSelector(
              style: EmotionSelectorStyle(),
            ),
          ),
        ),
      );

      // Verify that all 5 pills are present using their explicit keys
      expect(find.byKey(const ValueKey('pill_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('pill_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pill_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('pill_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('pill_4')), findsOneWidget);

      // Verify no text label is shown initially
      expect(find.text('Neutral'), findsNothing);
    });

    testWidgets('expands on tap and shows expanded content and label', (tester) async {
      int? submittedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmotionSelector(
              title: 'How are you feeling?',
              style: const EmotionSelectorStyle(
                animationDuration: Duration(milliseconds: 10), // fast for tests
              ),
              onSubmitted: (index) {
                submittedIndex = index;
              },
              expandedContentBuilder: (context, index) {
                return Text('Expanded $index');
              },
            ),
          ),
        ),
      );

      // Tap the Neutral pill (index 2) by its explicit key
      await tester.tap(find.byKey(const ValueKey('pill_2')));
      await tester.pumpAndSettle();

      // Verify the top label crossfaded from the title to the specific label
      expect(find.text('Neutral'), findsOneWidget);

      // Verify expanded content shows up
      expect(find.text('Expanded 2'), findsOneWidget);

      // Tap submit button
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(submittedIndex, 2);
    });
  });
}
