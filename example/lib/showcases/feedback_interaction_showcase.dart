import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class FeedbackInteractionShowcase extends StatelessWidget {
  const FeedbackInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Feedback Interaction'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FeedbackInteraction(),
          ],
        ),
      ),
    );
  }
}
