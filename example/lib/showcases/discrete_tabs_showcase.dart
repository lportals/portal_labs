import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class DiscreteTabsShowcase extends StatefulWidget {
  const DiscreteTabsShowcase({super.key});

  @override
  State<DiscreteTabsShowcase> createState() => _DiscreteTabsShowcaseState();
}

class _DiscreteTabsShowcaseState extends State<DiscreteTabsShowcase> {
  final List<DiscreteTab> _tabs = [
    const DiscreteTab(
      label: 'Inbox',
      icon: Icons.mark_email_unread_rounded,
      activeColor: Color(0xFF007AFF), // Apple Blue
    ),
    const DiscreteTab(
      label: 'Planner',
      icon: Icons.grid_view_rounded,
      activeColor: Color(0xFFFF2D55), // Apple Red
    ),
    const DiscreteTab(
      label: 'Notifications',
      icon: Icons.notifications_rounded,
      activeColor: Colors.black,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Light iOS Background
      appBar: AppBar(
        title: const Text('Discrete Tabs'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // THE WIDGET
              DiscreteTabs(
                tabs: _tabs,
                onSelect: (index) {
                  debugPrint('Selected tab index: $index');
                },
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
