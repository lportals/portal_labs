import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class PremiumChoiceChipsShowcase extends StatelessWidget {
  const PremiumChoiceChipsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Premium Choice Chips',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const SafeArea(
        bottom: true,
        child: Center(
          child: PremiumChoiceChips(
            items: [
              // Example of how to use Icons or Images:
              // ChoiceItem(label: 'Design', icon: Icons.palette_outlined),
              // ChoiceItem(label: 'Photography', imagePath: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=100'),
              ChoiceItem(label: 'Roadtrip', emoji: '🚙'),
              ChoiceItem(label: 'Football', emoji: '⚽'),
              ChoiceItem(label: 'Music', emoji: '🎵'),
              ChoiceItem(label: 'Art', emoji: '🎨'),
              ChoiceItem(label: 'Pets', emoji: '🐶'),
              ChoiceItem(label: 'Camping', emoji: '⛺'),
              ChoiceItem(label: 'Beach', emoji: '🏖️'),
              ChoiceItem(label: 'Travel', emoji: '🚂'),
              ChoiceItem(label: 'Baking', emoji: '🎂'),
              ChoiceItem(label: 'Hiking', emoji: '🥾'),
              ChoiceItem(label: 'Piano', emoji: '🎹'),
              ChoiceItem(label: 'Drums', emoji: '🥁'),
              ChoiceItem(label: 'Journaling', emoji: '📓'),
              ChoiceItem(label: 'Carnivals', emoji: '🎡'),
              ChoiceItem(label: 'Pottery', emoji: '🏺'),
              ChoiceItem(label: 'Snowboarding', emoji: '🏂'),
              ChoiceItem(label: 'Trekking', emoji: '🎒'),
              ChoiceItem(label: 'Walking', emoji: '🚶'),
              ChoiceItem(label: 'Cooking', emoji: '🍳'),
              ChoiceItem(label: 'Running', emoji: '🏃'),
              ChoiceItem(label: 'Mediation', emoji: '🧘'),
              ChoiceItem(label: 'Dancing', emoji: '💃'),
              ChoiceItem(label: 'Museum', emoji: '🏛️'),
              ChoiceItem(label: 'Crafting', emoji: '🪁'),
              ChoiceItem(label: 'Flying', emoji: '✈️'),
              ChoiceItem(label: 'Blogging', emoji: '📝'),
              ChoiceItem(label: 'Kites', emoji: '🪁'),
              ChoiceItem(label: 'Concerts', emoji: '🎟️'),
              ChoiceItem(label: 'Shopping', emoji: '🛒'),
              ChoiceItem(label: 'Knitting', emoji: '🧦'),
              ChoiceItem(label: 'Desserts', emoji: '🍰'),
              ChoiceItem(label: 'Organizing', emoji: '📁'),
              ChoiceItem(label: 'Telescopes', emoji: '🔭'),
              ChoiceItem(label: 'Science', emoji: '🔬'),
            ],
          ),
        ),
      ),
    );
  }
}
