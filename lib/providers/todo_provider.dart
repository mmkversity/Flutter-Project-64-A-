import 'package:flutter/foundation.dart';

import '../models/todo_item.dart';
import '../services/todo_repository.dart';

enum LoadStatus { initial, loading, ready, failure }

enum TodoFilter { all, active, completed }

@immutable
class TodoState {
  const TodoState({
    this.status = LoadStatus.initial,
    this.items = const <TodoItem>[],
    this.filter = TodoFilter.all,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final LoadStatus status;
  final List<TodoItem> items;
  final TodoFilter filter;
  final String? errorMessage;
  final bool isRefreshing;

  List<TodoItem> get visibleItems => switch (filter) {
    TodoFilter.all => items,
    TodoFilter.active => items
        .where((TodoItem item) => !item.isDone)
        .toList(growable: false),
    TodoFilter.completed => items
        .where((TodoItem item) => item.isDone)
        .toList(growable: false),
  };

  int get totalCount => items.length;

  int get completedCount => items.where((TodoItem item) => item.isDone).length;

  int get activeCount => totalCount - completedCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  TodoState copyWith({
    LoadStatus? status,
    List<TodoItem>? items,
    TodoFilter? filter,
    String? errorMessage,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return TodoState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// State container built on Flutter's own [ChangeNotifier].
///
/// No third-party state management package is required.
class TodoProvider extends ChangeNotifier {
  TodoProvider(this._repository);

  final TodoRepository _repository;

  TodoState _state = const TodoState();
  TodoState get state => _state;

  Future<void> init() async {
    if (_state.status == LoadStatus.loading ||
        _state.status == LoadStatus.ready) {
      return;
    }

    _emit(_state.copyWith(status: LoadStatus.loading, clearError: true));

    try {
      final List<TodoItem> items = await _repository.load();
      _emit(
        _state.copyWith(
          status: LoadStatus.ready,
          items: items,
          clearError: true,
        ),
      );
      await _persist();
    } catch (error) {
      _emit(
        _state.copyWith(status: LoadStatus.failure, errorMessage: '$error'),
      );
    }
  }

  /// Re-reads the stored tasks, used by pull-to-refresh.
  Future<void> reload() async {
    if (_state.isRefreshing) {
      return;
    }
    _emit(_state.copyWith(isRefreshing: true, clearError: true));

    try {
      final List<TodoItem> items = await _repository.load();
      _emit(
        _state.copyWith(
          status: LoadStatus.ready,
          items: items,
          isRefreshing: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isRefreshing: false,
          errorMessage: 'Could not reload saved tasks.',
        ),
      );
    }
  }

  void addItem(String title, String note) {
    final String cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      return;
    }

    final TodoItem item = TodoItem(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      title: cleanTitle,
      note: note.trim(),
      isDone: false,
      createdAt: DateTime.now(),
    );

    _emit(_state.copyWith(items: <TodoItem>[item, ..._state.items]));
    _persist();
  }

  void toggleItem(String id) {
    _emit(
      _state.copyWith(
        items: _state.items
            .map(
              (TodoItem item) => item.id == id
                  ? item.copyWith(isDone: !item.isDone)
                  : item,
            )
            .toList(),
      ),
    );
    _persist();
  }

  void removeItem(String id) {
    _emit(
      _state.copyWith(
        items: _state.items.where((TodoItem item) => item.id != id).toList(),
      ),
    );
    _persist();
  }

  /// Restores the last removed task at its original position.
  void restoreItem(TodoItem item, {required int index}) {
    final List<TodoItem> items = List<TodoItem>.of(_state.items);
    items.insert(index.clamp(0, items.length), item);
    _emit(_state.copyWith(items: items));
    _persist();
  }

  void setFilter(TodoFilter filter) {
    if (filter == _state.filter) {
      return;
    }
    _emit(_state.copyWith(filter: filter));
  }

  void clearCompleted() {
    if (_state.completedCount == 0) {
      return;
    }
    _emit(
      _state.copyWith(
        items: _state.items
            .where((TodoItem item) => !item.isDone)
            .toList(),
      ),
    );
    _persist();
  }

  void clearError() => _emit(_state.copyWith(clearError: true));

  void _emit(TodoState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> _persist() => _repository.save(_state.items);
}