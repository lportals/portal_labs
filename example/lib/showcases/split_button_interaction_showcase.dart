import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class SplitButtonInteractionShowcase extends StatefulWidget {
  const SplitButtonInteractionShowcase({super.key});

  @override
  State<SplitButtonInteractionShowcase> createState() => _SplitButtonInteractionShowcaseState();
}

class _SplitButtonInteractionShowcaseState extends State<SplitButtonInteractionShowcase> {
  void _onAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $action'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
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
          'Split Button Interaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // THE WIDGET
              SplitButtonInteraction(
                initialLabel: 'New Project',
                actions: [
                  SplitAction(
                    label: 'iOS', 
                    onTap: () => _onAction('iOS'),
                    icon: Icons.apple_rounded,
                  ),
                  SplitAction(
                    label: 'macOS', 
                    onTap: () => _onAction('macOS'),
                    icon: Icons.laptop_mac_rounded,
                  ),
                  SplitAction(
                    label: 'tvOS', 
                    onTap: () => _onAction('tvOS'),
                    icon: Icons.tv_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
