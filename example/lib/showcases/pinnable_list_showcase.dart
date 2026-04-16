import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class PinnableListShowcase extends StatelessWidget {
  const PinnableListShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Pinnable List Interaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PinnableList(
                style: PinnableListStyle(
                  badgeBackgroundColor: Colors.black.withOpacity(0.05),
                  badgeTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                items: const [
                  PinnableItem(
                    id: '1',
                    title: 'Apple Store',
                    subtitle: 'Electronics · Closes 9:00 PM',
                    isPinned: true,
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  ),
                  PinnableItem(
                    id: '2',
                    title: 'Airbnb Home',
                    subtitle: 'Accommodation · Check-in 3:00 PM',
                    isPinned: true,
                    icon: Icon(Icons.home_outlined, color: Colors.black),
                  ),
                  PinnableItem(
                    id: '3',
                    title: 'Uber Ride',
                    subtitle: 'Transportation · Available 24/7',
                    isPinned: false,
                    icon: Icon(Icons.directions_car_outlined, color: Colors.black),
                  ),
                  PinnableItem(
                    id: '4',
                    title: 'Library Downtown',
                    subtitle: 'Library · Closes 8:00 PM',
                    isPinned: false,
                    icon: Icon(Icons.menu_book_outlined, color: Colors.black),
                  ),
                  PinnableItem(
                    id: '5',
                    title: 'Spotify Premium',
                    subtitle: 'Music Streaming · Always Available',
                    isPinned: false,
                    icon: Icon(Icons.music_note_outlined, color: Colors.black),
                  ),
                  PinnableItem(
                    id: '6',
                    title: 'Starbucks Coffee',
                    subtitle: 'Coffee · Open until 11:00 PM',
                    isPinned: false,
                    icon: Icon(Icons.coffee_outlined, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Spacing at bottom
            ],
          ),
        ),
      ),
    );
  }
}
