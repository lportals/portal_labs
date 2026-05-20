import 'package:flutter/material.dart';

/// A model representing an item in the [CardSplittingAccordion].
class AccordionItem {
  /// Creates a new [AccordionItem].
  const AccordionItem({required this.title, required this.content, this.icon});

  /// The title of the item.
  final String title;

  /// The description or content shown when expanded.
  final String content;

  /// An optional icon to display.
  final IconData? icon;
}
