import 'package:flutter/foundation.dart';

/// Represents a grouping for tasks in the [TodoListInteraction].
@immutable
class TodoCategory {
  /// Creates a [TodoCategory].
  const TodoCategory({required this.id, required this.title});

  /// Unique identifier for the category.
  final String id;

  /// The display title of the category.
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
