import 'package:flutter/material.dart';
import '../components/journal_navigation/journal_navigation.dart';
import '../components/journal_navigation/models/journal_item.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Journal Navigation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          children: [
            JournalNavigation(
              items: items,
              initialDate: now,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _getTitle(DateTime date) {
    if (date.day % 11 == 0) return "Morning run in the park 🏃‍♂️. New PR!";
    if (date.day % 9 == 0) return "A walk among the ancient trees 🌲🌳. Breathing deep.";
    if (date.day % 7 == 0) return "A day for deep focus and productivity 🚀.";
    if (date.day % 6 == 0) return "Sudden breakthrough for the project 💡✨.";
    if (date.day % 5 == 0) return "Hit the gym after work 🏋️. Feeling strong.";
    if (date.day % 4 == 0) return "Discovered a beautiful hidden bridge 🏗️ city today.";
    if (date.day % 3 == 0) return "Small wins lead to big changes over time 📈.";
    if (date.day % 2 == 0) return "Peaceful meditation by the shore 🧘‍♂️🐚.";
    return "Quiet moments are when the best ideas happen ✨.";
  }

  String _getContent(DateTime date) {
    if (date.day % 11 == 0) return "Paced myself at 5:30 min/km. The air was crisp and fresh. 🌬️";
    if (date.day % 9 == 0) return "Found a new trail in the woods. The forest scent is magic. 🌿";
    if (date.day % 7 == 0) return "Zero distractions. Completed the core feature before noon. 🎯";
    if (date.day % 6 == 0) return "Sketched out a three-phase plan... the vision is finally clear! 🏔️";
    if (date.day % 5 == 0) return "Leg day was brutal but the endorphins are worth it. Tomorrow: rest. 🛌";
    if (date.day % 4 == 0) return "The architecture here is stunning. Took way too many photos. 📸";
    if (date.day % 3 == 0) return "One step at a time. Consistency is my secret superpower. 🧱";
    if (date.day % 2 == 0) return "Just 15 minutes of silence. The mental clarity is life-changing. 🌙";
    return "Reflected on the week's events and planned for the days ahead. ✍️";
  }
}
