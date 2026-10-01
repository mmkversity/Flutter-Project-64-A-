import 'package:flutter/material.dart';

import '../core/utils/date_format.dart';
import '../models/todo_item.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String stamp = formatDateTime(item.createdAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: item.isDone,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isDone
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    if (item.note.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        item.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stamp,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: scheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}