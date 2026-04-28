import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class DiscoveryBarShowcase extends StatelessWidget {
  const DiscoveryBarShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Discovery Bar',
      backgroundColor: const Color(0xFFF2F2F5),
      description:
          'Morphing search and discovery component with elastic container '
          'transitions. Dual containers physically expand and shrink for a '
          'seamless category-to-search morph with micro-bounce physics.',
      codeSnippet: '''DiscoveryBar(
  options: const [
    DiscoveryOption(
      label: 'Popular',
      icon: Icons.local_fire_department_rounded,
      activeColor: Color(0xFFFF3B30),
    ),
    DiscoveryOption(
      label: 'Favorites',
      icon: Icons.favorite_rounded,
      activeColor: Color(0xFFFF3B30),
    ),
  ],
  onOptionSelected: (option) => print('Selected: \${option.label}'),
  onSearchSubmitted: (query) => print('Query: \$query'),
)''',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              DiscoveryBar(
                options: const [
                  DiscoveryOption(
                    label: 'Popular',
                    icon: Icons.local_fire_department_rounded,
                    activeColor: Color(0xFFFF3B30),
                  ),
                  DiscoveryOption(
                    label: 'Favorites',
                    icon: Icons.favorite_rounded,
                    activeColor: Color(0xFFFF3B30),
                  ),
                ],
                onOptionSelected: (option) =>
                    _showToast(context, 'Selected: ${option.label}'),
                onSearchSubmitted: (query) =>
                    _showToast(context, 'Searching for: $query'),
              ),
              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
