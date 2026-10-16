import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title = 'My Tasks',
    this.unreadNotificationsCount = 0,
    required this.onNotificationsPressed,
    required this.onProfilePressed,
    required this.onReloadPressed,
    this.isRefreshing = false,
    this.onClearCompleted,
  });

  final String title;
  final int unreadNotificationsCount;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onReloadPressed;
  final bool isRefreshing;
  final VoidCallback? onClearCompleted;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppBar(
      title: Text(title),
      actions: <Widget>[
        IconButton(
          tooltip: 'Reload',
          onPressed: isRefreshing ? null : onReloadPressed,
          icon: isRefreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotificationsPressed,
          icon: Badge(
            isLabelVisible: unreadNotificationsCount > 0,
            label: Text('$unreadNotificationsCount'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        IconButton(
          tooltip: 'Profile',
          onPressed: onProfilePressed,
          icon: CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: const Icon(Icons.person, size: 18),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'clear' && onClearCompleted != null) {
              onClearCompleted!();
            }
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'clear',
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete_sweep_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Clear completed'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
