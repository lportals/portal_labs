import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class JournalNavigationShowcase extends StatelessWidget {
  const JournalNavigationShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 30));
    final List<JournalItem> items = List.generate(60, (index) {
      final date = startDate.add(Duration(days: index));
      return JournalItem(
        date: date,
        title: _getTitle(date),
        content: _getContent(date),
      );
    });

    return ShowcaseShell(
      title: 'Journal Navigation',
      description:
          'Vertical date-based navigator with 3D flip counters and snapping '
          'transitions. Direction-aware flip animations indicate past/future '
          'state. Decoupled architecture allows any widget as entry content.',
      codeSnippet: '''JournalNavigation(
  initialDate: DateTime.now(),
  items: [
    JournalItem(
      date: DateTime.now(),
      title: 'Morning run in the park 🏃',
      content: 'Hit a new personal record today.',
    ),
  ],
  onDateChanged: (item) => print('Viewing: \${item.title}'),
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            children: [
              JournalNavigation(items: items, initialDate: now),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(DateTime date) {
    if (date.day % 11 == 0) return "Morning run in the park 🏃‍♂️. New PR!";
    if (date.day % 9 == 0) return "A walk among the ancient trees 🌲.";
    if (date.day % 7 == 0) return "A day for deep focus and productivity 🚀.";
    if (date.day % 6 == 0) return "Sudden breakthrough for the project 💡.";
    if (date.day % 5 == 0) return "Hit the gym after work 🏋️. Feeling strong.";
    if (date.day % 4 == 0) return "Discovered a hidden bridge 🏗️ in the city.";
    if (date.day % 3 == 0) return "Small wins lead to big changes 📈.";
    if (date.day % 2 == 0) return "Peaceful meditation by the shore 🧘‍♂️.";
    return "Quiet moments are when the best ideas happen ✨.";
  }

  String _getContent(DateTime date) {
    if (date.day % 11 == 0) return "Paced myself at 5:30 min/km. 🌬️";
    if (date.day % 9 == 0) return "Found a new trail in the woods. 🌿";
    if (date.day % 7 == 0) return "Zero distractions. Core feature done. 🎯";
    if (date.day % 6 == 0) return "Three-phase plan finally clear! 🏔️";
    if (date.day % 5 == 0) return "Leg day was brutal. Worth it. 🛌";
    if (date.day % 4 == 0) return "Stunning architecture. Too many photos. 📸";
    if (date.day % 3 == 0) return "Consistency is my superpower. 🧱";
    if (date.day % 2 == 0) return "15 minutes of silence. Clarity. 🌙";
    return "Reflected on the week. Planning ahead. ✍️";
  }
}
