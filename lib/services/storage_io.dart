import 'dart:convert';
import 'dart:io';

import 'storage_service.dart';

/// File backed store used on mobile, desktop and in tests.
TodoStore createStore() => FileTodoStore();

/// File backed store for mobile, desktop and command line platforms.
class FileTodoStore implements TodoStore {
  FileTodoStore({Directory? directory})
    : directory = directory ?? _defaultDirectory();

  final Directory directory;

  static const String fileName = 'project_64a_store.json';

  static Directory _defaultDirectory() {
    final Map<String, String> env = Platform.environment;
    final List<String> candidates = <String>[
      if (env['LOCALAPPDATA'] != null) env['LOCALAPPDATA']!,
      if (env['APPDATA'] != null) env['APPDATA']!,
      if (env['HOME'] != null) env['HOME']!,
      if (env['USERPROFILE'] != null) env['USERPROFILE']!,
    ];

    for (final String candidate in candidates) {
      final Directory dir = Directory(_join(candidate, 'project_64a'));
      if (_canWrite(dir)) {
        return dir;
      }
    }

    return Directory(_join(Directory.systemTemp.path, 'project_64a'));
  }

  static String _join(String parent, String child) {
    final String separator = Platform.pathSeparator;
    final String trimmed = parent.endsWith(separator)
        ? parent.substring(0, parent.length - 1)
        : parent;
    return '$trimmed$separator$child';
  }

  static bool _canWrite(Directory dir) {
    try {
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final File probe = File(_join(dir.path, '.probe'));
      probe.writeAsStringSync('ok');
      probe.deleteSync();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  File get _file => File(_join(directory.path, fileName));

  @override
  Future<String?> read(String key) async {
    try {
      if (!_file.existsSync()) {
        return null;
      }
      final Map<String, dynamic> json = _decode(_file.readAsStringSync());
      return json[key] as String?;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      final Map<String, dynamic> json = _file.existsSync()
          ? _decode(_file.readAsStringSync())
          : <String, dynamic>{};
      json[key] = value;
      _file.writeAsStringSync(_encode(json));
    } on FileSystemException {
      // Storage is best effort: a failed write must not break the UI.
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      if (!_file.existsSync()) {
        return;
      }
      final Map<String, dynamic> json = _decode(_file.readAsStringSync());
      json.remove(key);
      _file.writeAsStringSync(_encode(json));
    } on FileSystemException {
      // ignored
    }
  }

  static Map<String, dynamic> _decode(String raw) {
    if (raw.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }
    return decoded;
  }

  static String _encode(Map<String, dynamic> json) => jsonEncode(json);
}