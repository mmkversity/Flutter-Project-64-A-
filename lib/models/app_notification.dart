import 'package:flutter/material.dart';

enum NotificationType { info, reminder, achievement, system }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.info,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  IconData get icon => switch (type) {
    NotificationType.info => Icons.info_outline,
    NotificationType.reminder => Icons.notifications_active_outlined,
    NotificationType.achievement => Icons.emoji_events_outlined,
    NotificationType.system => Icons.settings_suggest_outlined,
  };

  Color get iconColor => switch (type) {
    NotificationType.info => Colors.blue,
    NotificationType.reminder => Colors.orange,
    NotificationType.achievement => Colors.amber,
    NotificationType.system => Colors.teal,
  };

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
