import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('MorphingInputButton Interaction Tests', () {
    testWidgets('renders initial state with button text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingInputButton(
              buttonText: 'Join Waitlist',
              placeholder: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.text('Join Waitlist'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify TextField is initially hidden (opacity 0)
      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(MorphingInputButton),
          matching: find.byType(AnimatedOpacity),
        ).first,
      );
      expect(opacity.opacity, 0.0);
    });

    testWidgets('morphs to input state on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingInputButton(
              buttonText: 'Join',
              placeholder: 'Email',
            ),
          ),
        ),
      );

      // Initial width check
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(container.constraints?.maxWidth, 140.0);

      await tester.tap(find.text('Join'));
      await tester.pump(); // Start animation
      await tester.pumpAndSettle();

      // Expanded width check
      final expandedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(expandedContainer.constraints?.maxWidth, 320.0);
      
      // Verify TextField is now visible
      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(MorphingInputButton),
          matching: find.byType(AnimatedOpacity),
        ).first,
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('calls onSubmitted when text is entered and button is tapped', (WidgetTester tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingInputButton(
              buttonText: 'Submit',
              placeholder: 'Name',
              onSubmitted: (val) => submittedValue = val,
            ),
          ),
        ),
      );

      // Expand
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.pump();

      // Tap the button again to submit
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedValue, 'John Doe');
      
      // Verify it morphed back
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(container.constraints?.maxWidth, 140.0);
    });

    testWidgets('calls onSubmitted on keyboard submit', (WidgetTester tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingInputButton(
              buttonText: 'Go',
              placeholder: 'Search',
              onSubmitted: (val) => submittedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedValue, 'Flutter');
    });

    testWidgets('triggers haptics on toggle', (WidgetTester tester) async {
      final List<MethodCall> log = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            log.add(methodCall);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingInputButton(
              buttonText: 'Haptic',
              placeholder: 'Test',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Haptic'));
      await tester.pumpAndSettle();

      expect(log.length, 1);
      expect(log.first.arguments, 'HapticFeedbackType.lightImpact');
    });
  });
}
