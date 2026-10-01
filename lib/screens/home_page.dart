import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../providers/app_state_scope.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_todo_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_header.dart';
import '../widgets/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppStateScope.read(context).init();
      }
    });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload',
            onPressed: state.isRefreshing ? null : provider.reload,
            icon: state.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'clear') {
                provider.clearCompleted();
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Text('Clear completed'),
                  ),
                ],
          ),
        ],
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