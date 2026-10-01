import 'dart:convert';

import '../models/todo_item.dart';
import 'storage_service.dart';

class TodoRepository {
  TodoRepository({required this.storage}) : seed = _defaultSeed();

  TodoRepository.seeded({required this.storage, required this.seed});

  final StorageService storage;
  final List<TodoItem> seed;

  /// Reads saved tasks, falling back to the seed list on first run.
  Future<List<TodoItem>> load() async {
    final String? raw = await storage.readString(StorageService.todoKey);
    if (raw == null || raw.isEmpty) {
      return List<TodoItem>.of(seed);
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return List<TodoItem>.of(seed);
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TodoItem.fromJson)
          .toList();
    } on FormatException {
      return List<TodoItem>.of(seed);
    }
  }

  Future<void> save(List<TodoItem> items) async {
    final String raw = jsonEncode(
      items.map((TodoItem item) => item.toJson()).toList(),
    );
    await storage.writeString(StorageService.todoKey, raw);
  }

  Future<void> clear() => storage.remove(StorageService.todoKey);

  static List<TodoItem> _defaultSeed() {
    final DateTime now = DateTime.now();
    return <TodoItem>[
      TodoItem(
        id: 'seed-1',
        title: 'Read Flutter docs',
        note: 'widgets, state and layout guides',
        isDone: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TodoItem(
        id: 'seed-2',
        title: 'Build home page layout',
        note: 'Scaffold + AppBar + body widgets',
        isDone: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TodoItem(
        id: 'seed-3',
        title: 'Wire up state management',
        note: 'ChangeNotifier + InheritedNotifier',
        isDone: false,
        createdAt: now,
      ),
    ];
  }
}
