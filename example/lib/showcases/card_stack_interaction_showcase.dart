import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class CardStackInteractionShowcase extends StatelessWidget {
  const CardStackInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Card Stack Interaction',
      description:
          'Chronological card stack with symmetric center-point expansion. '
          'A 3-level visual hierarchy hides extra cards until expanded, '
          'with elastic easeOutBack curves for a tactile pop effect.',
      codeSnippet: '''CardStackInteraction(
  items: [
    CardStackItem(
      title: 'Camping',
      subtitle: 'Yosemite Park',
      date: '5 August',
      icon: Icons.terrain_rounded,
    ),
  ],
  onExpansionChanged: (isExpanded) => print('Expanded: \$isExpanded'),
)''',
      child: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CardStackInteraction(
              items: [
                CardStackItem(
                  title: 'Camping',
                  subtitle: 'Yosemite Park',
                  date: '5 August',
                  icon: Icons.terrain_rounded,
                ),
                CardStackItem(
                  title: 'Boating',
                  subtitle: 'Lake Tahoe Park',
                  date: '2 August',
                  icon: Icons.directions_boat_rounded,
                ),
                CardStackItem(
                  title: 'Barbecue',
                  subtitle: 'Greenfield Shores',
                  date: '28 July',
                  icon: Icons.outdoor_grill_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
