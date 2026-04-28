import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class DiscreteTabsShowcase extends StatelessWidget {
  const DiscreteTabsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Discrete Tabs',
      description:
          'Minimalist pill-expanding tab bar with bounce and shimmer text on '
          'selection. Supports both internal self-managed state and external '
          'currentIndex for complete synchronization with other views.',
      backgroundColor: const Color(0xFFF2F2F7),
      codeSnippet: '''DiscreteTabs(
  tabs: [
    DiscreteTab(
      label: 'Inbox',
      icon: Icons.mark_email_unread_rounded,
      activeColor: Color(0xFF007AFF),
    ),
    DiscreteTab(
      label: 'Planner',
      icon: Icons.grid_view_rounded,
      activeColor: Color(0xFFFF2D55),
    ),
  ],
  onSelect: (index) => setState(() => _page = index),
)''',
      child: Center(
        child: DiscreteTabs(
          tabs: const [
            DiscreteTab(
              label: 'Inbox',
              icon: Icons.mark_email_unread_rounded,
              activeColor: Color(0xFF007AFF),
            ),
            DiscreteTab(
              label: 'Planner',
              icon: Icons.grid_view_rounded,
              activeColor: Color(0xFFFF2D55),
            ),
            DiscreteTab(
              label: 'Alerts',
              icon: Icons.notifications_rounded,
              activeColor: Colors.black,
            ),
          ],
          onSelect: (index) => debugPrint('Tab: $index'),
        ),
      ),
    );
  }
}
