import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('RevealCopyInteraction Widget Tests', () {
    const String secretValue = '1234 5678 9012 3456';

    testWidgets('Should render masked text initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RevealCopyInteraction(value: secretValue)),
        ),
      );

      // Default masking for credit card is "1234 ×××× ×××× 3456"
      // Based on _getMaskedString: '${parts[0]} $mask$mask$mask$mask $mask$mask$mask$mask ${parts[3]}'
      expect(find.text('1234 ×××× ×××× 3456'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Should reveal text on tap', (WidgetTester tester) async {
      bool revealed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 100,
                child: RevealCopyInteraction(
                  value: secretValue,
                  onRevealed: () => revealed = true,
                  revealDuration: const Duration(seconds: 5),
                ),
              ),
            ),
          ),
        ),
      );

      // Initially masked
      expect(find.textContaining('×'), findsOneWidget);

      // Tap on the action button
      await tester.tap(find.byKey(const ValueKey('reveal_copy_action_button')));
      // Wait for scramble (500ms)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(revealed, isTrue);
      expect(find.textContaining('1234'), findsOneWidget);
    });

    testWidgets('Should copy text on tap when revealed', (
      WidgetTester tester,
    ) async {
      bool copied = false;
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 100,
                  child: RevealCopyInteraction(
                    value: secretValue,
                    onCopied: () => copied = true,
                    revealDuration: const Duration(seconds: 30),
                  ),
                ),
              ),
            ),
          ),
        );

        // Reveal first
        await tester.tap(
          find.byKey(const ValueKey('reveal_copy_action_button')),
        );
        await tester.pump(const Duration(milliseconds: 600));

        // Tap to copy
        await tester.tap(
          find.byKey(const ValueKey('reveal_copy_action_button')),
        );
        await tester.pump(const Duration(milliseconds: 600));
      });

      expect(copied, isTrue);
    });

    testWidgets('Should auto-hide after duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 100,
                child: RevealCopyInteraction(
                  value: secretValue,
                  revealDuration: Duration(milliseconds: 200),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('reveal_copy_action_button')));
      await tester.pumpAndSettle();

      // Wait for auto-hide
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.textContaining('×'), findsOneWidget);
    });
  });
}
