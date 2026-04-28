import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PremiumChoiceChipsShowcase extends StatelessWidget {
  const PremiumChoiceChipsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Premium Choice Chips',
      description:
          'Animated multi-selection chip component with flying media transitions. '
          'Supports Unicode emojis, Material icons, and image URLs. '
          'Kinetic landing animations and integrated Odometer-style counter.',
      codeSnippet: '''PremiumChoiceChips(
  items: [
    ChoiceItem(label: 'Flutter', icon: Icons.flutter_dash_rounded),
    ChoiceItem(label: 'Coffee',  emoji: '☕'),
    ChoiceItem(label: 'Photos',
      imagePath: 'https://images.unsplash.com/photo-xxx'),
  ],
  onSelectionChanged: (selected) => print('\${selected.length} selected'),
)''',
      child: const SafeArea(
        bottom: true,
        child: Center(
          child: PremiumChoiceChips(
            items: [
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
              ChoiceItem(label: 'Pottery', emoji: '🏺'),
              ChoiceItem(label: 'Snowboarding', emoji: '🏂'),
              ChoiceItem(label: 'Cooking', emoji: '🍳'),
              ChoiceItem(label: 'Running', emoji: '🏃'),
              ChoiceItem(label: 'Dancing', emoji: '💃'),
              ChoiceItem(label: 'Museum', emoji: '🏛️'),
              ChoiceItem(label: 'Science', emoji: '🔬'),
            ],
          ),
        ),
      ),
    );
  }
}
