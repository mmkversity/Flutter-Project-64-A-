import 'package:flutter/widgets.dart';

import 'todo_provider.dart';

/// Minimal dependency-injection scope built on Flutter's [InheritedNotifier].
///
/// It replaces the `provider` package: [watch] rebuilds the caller whenever the
/// notifier fires, [read] looks the notifier up without subscribing.
class AppStateScope extends InheritedNotifier<TodoProvider> {
  const AppStateScope({super.key, required TodoProvider notifier, required super.child})
    : super(notifier: notifier);

  static TodoProvider watch(BuildContext context) {
    return _scopeOf(context, dependOn: true);
  }

  static TodoProvider read(BuildContext context) {
    return _scopeOf(context, dependOn: false);
  }

  static TodoProvider _scopeOf(BuildContext context, {required bool dependOn}) {
    final AppStateScope? scope = dependOn
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()
        : context.getInheritedWidgetOfExactType<AppStateScope>();

    assert(scope != null, 'AppStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}