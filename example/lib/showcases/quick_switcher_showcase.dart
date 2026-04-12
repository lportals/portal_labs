import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class QuickSwitcherShowcase extends StatefulWidget {
  const QuickSwitcherShowcase({super.key});

  @override
  State<QuickSwitcherShowcase> createState() => _QuickSwitcherShowcaseState();
}

class _QuickSwitcherShowcaseState extends State<QuickSwitcherShowcase> {
  final List<QuickSwitcherOption> _options = const [
    QuickSwitcherOption(
      label: 'Ask Anything',
      icon: Icons.auto_awesome_rounded,
      placeholder: 'Ask Anything',
    ),
    QuickSwitcherOption(
      label: 'Generate Image',
      icon: Icons.image_rounded,
      placeholder: 'Generate Image',
    ),
    QuickSwitcherOption(
      label: 'Analyze Files',
      icon: Icons.folder_zip_rounded,
      placeholder: 'Analyze Files',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quick Switcher',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickSwitcher(
                options: _options,
                onOptionChanged: (index) {
                  print('Option changed to: ${_options[index].label}');
                },
                onSubmitted: (text) {
                  print('Submitted: $text');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
