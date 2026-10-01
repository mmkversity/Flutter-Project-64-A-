import 'storage_service.dart';

/// Web has no `dart:io` file system, so the store falls back to memory.
TodoStore createStore() => MemoryTodoStore();