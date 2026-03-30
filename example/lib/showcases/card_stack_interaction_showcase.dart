import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class CardStackInteractionShowcase extends StatefulWidget {
  const CardStackInteractionShowcase({super.key});

  @override
  State<CardStackInteractionShowcase> createState() =>
      _CardStackInteractionShowcaseState();
}

class _CardStackInteractionShowcaseState
    extends State<CardStackInteractionShowcase> {
  final List<CardStackItem> _items = const [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
          'Stack Interaction',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CardStackInteraction(items: _items),
          ),
        ),
      ),
    );
  }
}
