import 'package:flutter/material.dart';

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.activeTasks,
    this.userName = 'Raitul Hasan',
    this.userEmail = 'raitul@example.com',
  });

  final int totalTasks;
  final int completedTasks;
  final int activeTasks;
  final String userName;
  final String userEmail;

  static Future<void> show(
    BuildContext context, {
    required int totalTasks,
    required int completedTasks,
    required int activeTasks,
    String userName = 'Raitul Hasan',
    String userEmail = 'raitul@example.com',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => ProfileSheet(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        activeTasks: activeTasks,
        userName: userName,
        userEmail: userEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            children: <Widget>[
              // Profile Header with Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      userName.isNotEmpty
                          ? userName
                              .split(' ')
                              .map((String s) => s.isNotEmpty ? s[0] : '')
                              .take(2)
                              .join()
                              .toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Task statistics cards
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _StatColumn(
                        label: 'Total',
                        value: '$totalTasks',
                        color: theme.colorScheme.primary,
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'Active',
                        value: '$activeTasks',
                        color: Colors.orange,
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'Done',
                        value: '$completedTasks',
                        color: Colors.green,
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'Rate',
                        value: '${completionRate.toStringAsFixed(0)}%',
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account & App Settings List
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.person_outline),
                title: const Text('Account Details'),
                subtitle: const Text('Manage your profile and settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account details opened')),
                  );
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notification Preferences'),
                subtitle: const Text('Daily reminders and task alerts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification preferences saved'),
                    ),
                  );
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Appearance'),
                subtitle: const Text('System theme active'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appearance settings opened')),
                  );
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.info_outline),
                title: const Text('About Project 64A'),
                subtitle: const Text('Version 1.0.0+1'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Project 64A',
                    applicationVersion: '1.0.0+1',
                    applicationLegalese: '© 2026 Project 64A contributors',
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully')),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
