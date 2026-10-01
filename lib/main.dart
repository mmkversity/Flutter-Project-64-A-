import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_state_scope.dart';
import 'providers/todo_provider.dart';
import 'screens/home_page.dart';
import 'services/storage_service.dart';
import 'services/todo_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final TodoRepository repository = TodoRepository(
    storage: StorageService.create(),
  );

  runApp(ProjectApp(repository: repository));
}

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key, required this.repository});

  final TodoRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: TodoProvider(repository),
      child: MaterialApp(
        title: 'Project 64A',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}