import 'package:flutter/foundation.dart';

/// Represents a single task in the [TodoListInteraction].
@immutable
class TodoItem {
  /// Unique identifier for the task.
  final String id;

  /// The text description of the task.
  final String title;

  /// The ID of the category this task belongs to.
  final String categoryId;

  /// Whether the task is finished.
  final bool isCompleted;

  const TodoItem({
    required this.id,
    required this.title,
    required this.categoryId,
    this.isCompleted = false,
  });

  /// Creates a copy of this task with updated fields.
  TodoItem copyWith({
    String? title,
    String? categoryId,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          categoryId == other.categoryId &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ categoryId.hashCode ^ isCompleted.hashCode;
}
