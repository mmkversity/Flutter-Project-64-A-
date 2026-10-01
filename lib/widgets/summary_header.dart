import 'package:flutter/material.dart';

import '../providers/todo_provider.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    super.key,
    required this.total,
    required this.active,
    required this.completed,
    required this.progress,
  });

  final int total;
  final int active;
  final int completed;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Progress', style: theme.textTheme.titleMedium),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _Stat(label: 'Total', value: total, color: theme.colorScheme.primary),
                _Stat(label: 'Active', value: active, color: Colors.orange.shade700),
                _Stat(
                  label: 'Done',
                  value: completed,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.current, required this.onChanged});

  final TodoFilter current;
  final ValueChanged<TodoFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TodoFilter>(
      segments: const <ButtonSegment<TodoFilter>>[
        ButtonSegment<TodoFilter>(value: TodoFilter.all, label: Text('All')),
        ButtonSegment<TodoFilter>(value: TodoFilter.active, label: Text('Active')),
        ButtonSegment<TodoFilter>(
          value: TodoFilter.completed,
          label: Text('Done'),
        ),
      ],
      selected: <TodoFilter>{current},
      showSelectedIcon: false,
      onSelectionChanged: (Set<TodoFilter> selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
    );
  }
}