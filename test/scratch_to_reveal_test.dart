import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('ScratchToReveal Interaction Tests', () {
    testWidgets('renders ScratchToReveal with title and surface', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: ScratchToReveal(
                  title: 'Test Reward',
                  child: Text('REVEALED'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Reward'), findsOneWidget);
      expect(find.byType(ScratchSurface), findsOneWidget);
    });

    testWidgets('scratching surface updates progress and reveals content', (WidgetTester tester) async {
      double? currentProgress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: ScratchSurface(
                  onProgress: (p) => currentProgress = p,
                  onCompleted: () {},
                  child: const Text('REVEALED'),
                ),
              ),
            ),
          ),
        ),
      );

      final surfaceFinder = find.byType(ScratchSurface);
      final center = tester.getCenter(surfaceFinder);
      
      // Perform a scratch gesture
      await tester.dragFrom(center, const Offset(50, 50));
      await tester.pump();

      expect(currentProgress, isNotNull);
      expect(currentProgress!, greaterThan(0));
    });

    testWidgets('ScratchController programmatically reveals and resets', (WidgetTester tester) async {
      final controller = ScratchController();
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: ScratchToReveal(
                  controller: controller,
                  title: 'Controlled',
                  onCompleted: () => completed = true,
                  child: const Text('REVEALED'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(controller.progress, 0.0);
      expect(controller.isCompleted, false);

      controller.reveal();
      await tester.pump(); // Start fade
      await tester.pump(const Duration(seconds: 1)); // Wait for animation

      expect(controller.isCompleted, true);
      expect(completed, true);
      expect(find.text('Start again'), findsOneWidget);

      await tester.tap(find.text('Start again'));
      await tester.pump(); // Start reset
      await tester.pump(const Duration(seconds: 1));

      expect(controller.isCompleted, false);
      expect(controller.progress, 0.0);
    });

    testWidgets('haptics are triggered on scratch start', (WidgetTester tester) async {
      // Setup haptic interceptor
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
            body: ScratchSurface(
              child: Text('REVEALED'),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ScratchSurface), const Offset(50, 50));
      await tester.pump();

      // Check if any haptic was called (lightImpact uses 'HapticFeedback.vibrate' with specific arguments or similar)
      // Actually Flutter tests for haptics can be tricky, but we can verify the call was made.
      expect(log.length, greaterThan(0));
    });
  });
}
