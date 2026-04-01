import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class MorphingInputButtonShowcase extends StatelessWidget {
  const MorphingInputButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morphing Input Button'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: MorphingInputButton(
                buttonText: 'Notify Me',
                placeholder: 'Enter your email...',
                icon: Icons.notifications_rounded,
                onSubmitted: (email) => _showSuccess(context, email),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received: $value'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
