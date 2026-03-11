// dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

class DashboardTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const DashboardTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard'),
    );
  }
}