import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class RevealCopyShowcase extends StatefulWidget {
  const RevealCopyShowcase({super.key});

  @override
  State<RevealCopyShowcase> createState() => _RevealCopyShowcaseState();
}

class _RevealCopyShowcaseState extends State<RevealCopyShowcase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reveal & Copy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              RevealCopyInteraction(
                value: '4485 2291 0034 7516',
                onCopied: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
