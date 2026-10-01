import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_64a/core/theme/app_theme.dart';
import 'package:project_64a/core/utils/date_format.dart';
import 'package:project_64a/models/todo_item.dart';
import 'package:project_64a/providers/app_state_scope.dart';
import 'package:project_64a/providers/todo_provider.dart';
import 'package:project_64a/screens/home_page.dart';
import 'package:project_64a/services/storage_service.dart';
import 'package:project_64a/services/todo_repository.dart';
import 'package:project_64a/widgets/summary_header.dart';

TodoRepository _repository() =>
    TodoRepository(storage: StorageService.memory());

Widget _buildApp(TodoProvider provider) {
  return AppStateScope(
    notifier: provider,
    child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
  );
}

void main() {
  test('TodoState computes counters and filtered lists', () {
    final DateTime now = DateTime.now();
    final TodoState state = TodoState(
      items: <TodoItem>[
        TodoItem(id: '1', title: 'a', note: '', isDone: true, createdAt: now),
        TodoItem(id: '2', title: 'b', note: '', isDone: false, createdAt: now),
      ],
      filter: TodoFilter.active,
    );

    expect(state.totalCount, 2);
    expect(state.completedCount, 1);
    expect(state.activeCount, 1);
    expect(state.progress, 0.5);
    expect(state.visibleItems.single.id, '2');
  });

  test('TodoItem survives a JSON round trip', () {
    final TodoItem item = TodoItem(
      id: '9',
      title: 'Round trip',
      note: 'json',
      isDone: true,
      createdAt: DateTime(2026, 3, 4, 5, 6),
    );

    final TodoItem decoded = TodoItem.fromJson(item.toJson());

    expect(decoded.id, item.id);
    expect(decoded.title, item.title);
    expect(decoded.isDone, isTrue);
    expect(decoded.createdAt, item.createdAt);
  });

  test('date formatter builds a readable stamp', () {
    expect(formatDateTime(DateTime(2026, 3, 4, 9, 5)), '4 Mar, 09:05');
    expect(formatTime(DateTime(2026, 3, 4, 0, 5)), '12:05 AM');
    expect(formatTime(DateTime(2026, 3, 4, 13, 5)), '1:05 PM');
  });

  testWidgets('HomePage renders AppBar, summary and seeded tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(TodoProvider(_repository())));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Read Flutter docs'), findsOneWidget);
  });

  testWidgets('Filter bar narrows the visible list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp(TodoProvider(_repository())));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(FilterBar), matching: find.text('Done')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Read Flutter docs'), findsOneWidget);
    expect(find.text('Build home page layout'), findsNothing);
  });

  testWidgets('Toggling a checkbox updates the summary counters', (
    WidgetTester tester,
  ) async {
    final TodoProvider provider = TodoProvider(_repository());
    await tester.pumpWidget(_buildApp(provider));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    expect(provider.state.completedCount, 2);
  });
}