import 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    as backend;

/// Raw key/value persistence backend.
///
/// Implemented with `dart:io` on mobile/desktop and with an in-memory map on
/// the web, so the app needs no third-party storage package.
abstract class TodoStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Backend used by tests: never touches the file system.
class MemoryTodoStore implements TodoStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

class StorageService {
  StorageService(this._store);

  /// Creates the platform default store.
  factory StorageService.create() => StorageService(backend.createStore());

  /// In-memory store, handy for tests and previews.
  factory StorageService.memory() => StorageService(MemoryTodoStore());

  static const String todoKey = 'project_64a.todo_items';

  final TodoStore _store;

  Future<String?> readString(String key) => _store.read(key);

  Future<void> writeString(String key, String value) => _store.write(key, value);

  Future<void> remove(String key) => _store.delete(key);
}