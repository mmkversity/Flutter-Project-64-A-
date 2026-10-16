import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/todo_item.dart';
import '../providers/app_state_scope.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_todo_sheet.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/summary_header.dart';
import '../widgets/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AppNotification> _notifications = <AppNotification>[
    AppNotification(
      id: '1',
      title: 'Welcome to Project 64A',
      message: 'Organize, prioritize, and achieve your daily goals seamlessly.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      type: NotificationType.info,
    ),
    AppNotification(
      id: '2',
      title: 'Task Reminder',
      message: 'Review pending tasks and check them off once finished.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      type: NotificationType.reminder,
    ),
    AppNotification(
      id: '3',
      title: 'Great Progress',
      message: 'Keep going to achieve 100% completion today!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      type: NotificationType.achievement,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppStateScope.read(context).init();
      }
    });
  }

  void _openNotifications() {
    NotificationsSheet.show(
      context,
      notifications: _notifications,
      onNotificationsChanged: (List<AppNotification> updated) {
        setState(() {
          _notifications = updated;
        });
      },
    );
  }

  void _openProfile(TodoState state) {
    ProfileSheet.show(
      context,
      totalTasks: state.totalCount,
      completedTasks: state.completedCount,
      activeTasks: state.activeCount,
    );
  }

  void _openAddSheet() {
    final TodoProvider provider = AppStateScope.read(context);
    AddTodoSheet.show(context, onSubmit: provider.addItem);
  }

  void _deleteWithUndo(String id) {
    final TodoProvider provider = AppStateScope.read(context);
    final TodoState state = provider.state;
    final int index = state.items.indexWhere((TodoItem item) => item.id == id);
    if (index < 0) {
      return;
    }

    final TodoItem removed = state.items[index];
    provider.removeItem(id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${removed.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => provider.restoreItem(removed, index: index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // `watch` subscribes this screen to notifier changes.
    final TodoState state = AppStateScope.watch(context).state;
    final TodoProvider provider = AppStateScope.read(context);
    final int unreadNotifications =
        _notifications.where((AppNotification n) => !n.isRead).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Tasks',
        unreadNotificationsCount: unreadNotifications,
        isRefreshing: state.isRefreshing,
        onReloadPressed: provider.reload,
        onNotificationsPressed: _openNotifications,
        onProfilePressed: () => _openProfile(state),
        onClearCompleted: provider.clearCompleted,
      ),
      body: SafeArea(child: _buildBody(context, state)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar:
          state.status == LoadStatus.ready && state.completedCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: OutlinedButton.icon(
                  onPressed: provider.clearCompleted,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear completed tasks'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, TodoState state) {
    if (state.status == LoadStatus.loading ||
        state.status == LoadStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == LoadStatus.failure) {
      return EmptyState(
        title: 'Something went wrong',
        message: state.errorMessage ?? 'Unable to load your tasks.',
      );
    }

    final TodoProvider provider = AppStateScope.read(context);
    final List<Widget> children = <Widget>[
      SummaryHeader(
        total: state.totalCount,
        active: state.activeCount,
        completed: state.completedCount,
        progress: state.progress,
      ),
      const SizedBox(height: 16),
      FilterBar(current: state.filter, onChanged: provider.setFilter),
      const SizedBox(height: 16),
      if (state.visibleItems.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: EmptyState(
            title: 'Nothing here yet',
            message: 'Tap the Add button to create your first task.',
          ),
        )
      else
        ...state.visibleItems.map(
          (TodoItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TodoTile(
              key: ValueKey<String>(item.id),
              item: item,
              onToggle: () => provider.toggleItem(item.id),
              onDelete: () => _deleteWithUndo(item.id),
            ),
          ),
        ),
      const SizedBox(height: 96),
    ];

    return RefreshIndicator(
      onRefresh: provider.reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: children,
      ),
    );
  }
}