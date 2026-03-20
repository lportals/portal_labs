import 'package:flutter/material.dart';

/// Model representing a single entry in the [JournalNavigation].
///
/// By default, it displays a [title] and [content] string, but can be
/// extended with a [child] widget for completely custom entry layouts.
class JournalItem {
  /// The specific date associated with this journal entry.
  final DateTime date;

  /// The main title of the entry (e.g., "Daily Reflection").
  final String title;

  /// The main text content of the entry.
  final String content;

  /// An optional custom widget to display instead of [title] and [content].
  ///
  /// If provided, the [JournalNavigation] will render this [child] in the
  /// content area, allowing for rich media, charts, or images.
  final Widget? child;

  JournalItem({
    required this.date,
    this.title = '',
    this.content = '',
    this.child,
  });
}
