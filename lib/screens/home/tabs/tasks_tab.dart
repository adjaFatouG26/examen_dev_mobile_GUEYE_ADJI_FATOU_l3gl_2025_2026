// tasks_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

class TasksTab extends StatelessWidget {
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const TasksTab({
    super.key,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tâches'),
    );
  }
}