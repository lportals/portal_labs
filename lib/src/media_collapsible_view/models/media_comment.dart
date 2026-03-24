import 'package:flutter/material.dart';

/// A professional-grade model for comments.
class MediaComment {
  final String id;
  final String userName;
  final String text;
  final String avatarUrl;
  final DateTime createdAt;

  MediaComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.avatarUrl,
    required this.createdAt,
  });
}
