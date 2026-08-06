import 'package:flutter/material.dart';

/// Domain model representing an activity event in the timeline & activity feed.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
}
