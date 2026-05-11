import 'package:flutter/material.dart';

/// A data model representing a single user comment in the [MediaCollapsibleView].
class MediaComment {
  /// Creates a [MediaComment] with all required fields.
  MediaComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.avatarImage,
    required this.createdAt,
  });

  /// Unique identifier for the comment.
  final String id;

  /// Display name of the comment author.
  final String userName;

  /// The body text of the comment.
  final String text;

  /// The image provider for the author's avatar.
  final ImageProvider avatarImage;

  /// The timestamp when the comment was created.
  final DateTime createdAt;
}
