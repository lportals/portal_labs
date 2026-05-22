import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('CoverflowCarousel Tests', () {
    final mockChildren = List.generate(
      5,
      (index) => Container(
        key: ValueKey('card_$index'),
        color: Colors.red,
        child: Center(child: Text('Card $index')),
      ),
    );

    testWidgets('Should render initial card and index label correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              initialIndex: 2,
              children: mockChildren,
            ),
          ),
        ),
      );

      // Cards should be present in the tree
      expect(find.byKey(const ValueKey('card_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('card_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('card_4')), findsOneWidget);

      // The active integer index label "2" should be rendered
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Should change index when swipe gesture occurs', (
      WidgetTester tester,
    ) async {
      int? updatedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              children: mockChildren,
              onIndexChanged: (idx) => updatedIndex = idx,
            ),
          ),
        ),
      );

      // Drag the carousel to the left using dragFrom
      await tester.dragFrom(const Offset(400.0, 150.0), const Offset(-200.0, 0.0));
      await tester.pumpAndSettle();

      // Index should be updated to 1
      expect(updatedIndex, equals(1));
    });

    testWidgets('Should respect controller navigation commands', (
      WidgetTester tester,
    ) async {
      final controller = CoverflowCarouselController(initialPage: 1);
      int? activeIdx = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              controller: controller,
              children: mockChildren,
              onIndexChanged: (idx) => activeIdx = idx,
            ),
          ),
        ),
      );

      expect(activeIdx, 1);

      // Programmatic jump
      controller.jumpToPage(3);
      await tester.pumpAndSettle();
      expect(activeIdx, 3);

      // Programmatic animation
      controller.animateToPage(0, duration: const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(activeIdx, 0);
    });

    testWidgets('Should navigate to side card when tapped', (
      WidgetTester tester,
    ) async {
      int? activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              children: mockChildren,
              onIndexChanged: (idx) => activeIndex = idx,
            ),
          ),
        ),
      );

      // Tap on card 1 (placed on the right of the center card).
      // Card 0 (center) is at Offset(400.0, 150.0). Card 1 is translated to the right.
      // Tapping at Offset(520.0, 150.0) lands on Card 1.
      await tester.tapAt(const Offset(520.0, 150.0));
      await tester.pumpAndSettle();

      expect(activeIndex, 1);
    });

    testWidgets('Should toggle slider and index indicators based on style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              style: const CoverflowCarouselStyle(
                showSlider: false,
                showIndexIndicator: false,
              ),
              children: mockChildren,
            ),
          ),
        ),
      );

      // Index label "0" should not be visible
      expect(find.text('0'), findsNothing);
    });

    testWidgets('Should duplicate cards when enableReflection is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoverflowCarousel(
              style: const CoverflowCarouselStyle(
                enableReflection: true,
                spacing: -100.0,
              ),
              children: mockChildren,
            ),
          ),
        ),
      );

      // If reflection is enabled, the cards are duplicated (one for real, one for reflection)
      expect(find.byKey(const ValueKey('card_0')), findsNWidgets(2));
      expect(find.byKey(const ValueKey('card_2')), findsNWidgets(2));
    });
  });
}
