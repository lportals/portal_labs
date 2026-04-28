import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class ScratchToRevealShowcase extends StatelessWidget {
  const ScratchToRevealShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Scratch to Reveal',
      description:
          'Physical scratching simulation using advanced canvas blend modes. '
          'Procedurally generated diagonal grid texture mimics real scratch '
          'cards. Auto-reveals once a configurable coverage threshold is reached.',
      codeSnippet: '''ScratchToReveal(
  title: 'Apple Credits',
  icon: Icons.apple_rounded,
  onCompleted: () => print('Reward revealed!'),
  child: Center(
    child: Text('\$100', style: TextStyle(fontSize: 48)),
  ),
)''',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              ScratchToReveal(
                title: 'Apple Credits',
                icon: Icons.apple_rounded,
                onCompleted: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward Unlocked! 🍎'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You won',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$100',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
