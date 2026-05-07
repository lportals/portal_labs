import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class SignatureDrawPadShowcase extends StatelessWidget {
  const SignatureDrawPadShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Signature Draw Pad',
      description:
          'A premium, high-fidelity signature pad featuring physical stroke simulation, real-time color morphing, and an off-screen PNG export engine with document integrity locking.',
      codeSnippet: '''SignatureDrawPad(
  label: 'Authorize Transaction',
  onConfirm: () async {
    final image = await _controller.toImage(width: 800, height: 400);
    print('Signature captured as image');
  },
  style: SignatureDrawPadStyle(
    activeColor: Colors.black,
    confirmButtonText: 'HOLD TO SIGN',
  ),
)''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SignatureDrawPad(
                paletteColors: const [
                  Color(0xFF000000), // Pure Black
                  Color(0xFFFF3B30), // iOS Red
                  Color(0xFF34C759), // iOS Green
                  Color(0xFF007AFF), // iOS Blue
                  Color(0xFFAF52DE), // iOS Purple
                ],
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signature confirmed!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
