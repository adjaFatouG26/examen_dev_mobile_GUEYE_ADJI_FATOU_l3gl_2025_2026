// projects_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';

class ProjectsTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectsTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Projets'),
    );
  }
}