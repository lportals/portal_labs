import 'package:flutter/material.dart';

/// Represents a single piece of data displayed within the [CardStackInteraction].
///
/// Each item includes a title, subtitle, date, and an icon which are used
/// to populate the card's UI.
class CardStackItem {

  /// Creates a [CardStackItem] with all required display properties.
  const CardStackItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    this.iconBackgroundColor,
  });
  /// The main heading of the card (e.g., 'Camping').
  final String title;

  /// The secondary information for the card (e.g., 'Yosemite Park').
  final String subtitle;

  /// The date or timestamp associated with this item (e.g., '5 August').
  final String date;

  /// The icon representing the category or type of this card.
  final IconData icon;

  /// Optional background color for the icon container.
  final Color? iconBackgroundColor;
}
