import 'package:flutter/material.dart';

import '../models/app_notification.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({
    super.key,
    required this.notifications,
    this.onNotificationsChanged,
  });

  final List<AppNotification> notifications;
  final ValueChanged<List<AppNotification>>? onNotificationsChanged;

  static Future<void> show(
    BuildContext context, {
    required List<AppNotification> notifications,
    ValueChanged<List<AppNotification>>? onNotificationsChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => NotificationsSheet(
        notifications: notifications,
        onNotificationsChanged: onNotificationsChanged,
      ),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<AppNotification>.from(widget.notifications);
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((AppNotification n) => n.copyWith(isRead: true))
          .toList();
    });
    widget.onNotificationsChanged?.call(_notifications);
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    widget.onNotificationsChanged?.call(_notifications);
  }

  void _toggleRead(String id) {
    setState(() {
      final int index = _notifications.indexWhere((AppNotification n) => n.id == id);
      if (index >= 0) {
        final AppNotification item = _notifications[index];
        _notifications[index] = item.copyWith(isRead: !item.isRead);
      }
    });
    widget.onNotificationsChanged?.call(_notifications);
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((AppNotification n) => n.id == id);
    });
    widget.onNotificationsChanged?.call(_notifications);
  }

  String _formatRelativeTime(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int unreadCount = _notifications.where((AppNotification n) => !n.isRead).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.notifications_outlined, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'Notifications',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadCount new',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_notifications.isNotEmpty) ...<Widget>[
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: _markAllAsRead,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Mark read'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Clear all',
                      visualDensity: VisualDensity.compact,
                      onPressed: _clearAll,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 56,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'You have caught up with all updates and reminders.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _notifications.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(indent: 72, endIndent: 16, height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final AppNotification notification = _notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          onDismissed: (_) => _removeNotification(notification.id),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: notification.iconColor.withValues(alpha: 0.15),
                              foregroundColor: notification.iconColor,
                              child: Icon(notification.icon, size: 22),
                            ),
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatRelativeTime(notification.timestamp),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                notification.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: notification.isRead
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            trailing: !notification.isRead
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : null,
                            onTap: () => _toggleRead(notification.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
