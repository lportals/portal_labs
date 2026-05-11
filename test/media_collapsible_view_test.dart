import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  // A simple 1x1 transparent PNG as memory image data
  final Uint8List transparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ]);

  group('MediaCollapsibleView Widget Tests', () {
    final List<MediaComment> mockComments = [
      MediaComment(
        id: '1',
        userName: 'John Doe',
        text: 'This is amazing!',
        avatarImage: MemoryImage(transparentImage),
        createdAt: DateTime.now(),
      ),
      MediaComment(
        id: '2',
        userName: 'Jane Smith',
        text: 'Love the transition.',
        avatarImage: MemoryImage(transparentImage),
        createdAt: DateTime.now(),
      ),
    ];

    testWidgets('Should render initial state with media', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaCollapsibleView(
            mediaImage: MemoryImage(transparentImage),
            userAvatarImage: MemoryImage(transparentImage),
            comments: mockComments,
            mediaBuilder: (context) => Container(color: Colors.red, key: const Key('media_content')),
          ),
        ),
      );

      // Verify media content is present
      expect(find.byKey(const Key('media_content')), findsOneWidget);
      
      // Verify action buttons are present
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('Should expand comments sheet on chat button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaCollapsibleView(
            mediaImage: MemoryImage(transparentImage),
            userAvatarImage: MemoryImage(transparentImage),
            comments: mockComments,
            mediaBuilder: (context) => Container(color: Colors.red),
          ),
        ),
      );

      // Tap on chat button
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();

      // Verify sheet is expanded and showing comments title
      expect(find.text('Comments'), findsOneWidget);
      
      // Verify initial comments are listed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('Should call onSendComment when submitting', (WidgetTester tester) async {
      String? sentComment;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaCollapsibleView(
            mediaImage: MemoryImage(transparentImage),
            userAvatarImage: MemoryImage(transparentImage),
            comments: mockComments,
            mediaBuilder: (context) => Container(color: Colors.red),
            onSendComment: (val) => sentComment = val,
          ),
        ),
      );

      // Expand sheet
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello World');
      
      // Tap send
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(sentComment, 'Hello World');
      // TextField should be cleared
      expect(find.text('Hello World'), findsNothing);
    });
  });
}
