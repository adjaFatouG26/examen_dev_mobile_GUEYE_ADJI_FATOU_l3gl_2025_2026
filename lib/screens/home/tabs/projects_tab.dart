// projects_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';

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
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, _) {
        final projects = projectProvider.projects;

        // État vide
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun projet pour le moment',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez sur + pour créer un projet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Liste des projets
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              taskCount: 0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(
                      project: project,
                      projectProvider: projectProvider,
                      taskProvider: TaskProvider(),
                      authProvider: authProvider,
                    ),
                  ),
                );

              },
              onEdit: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(
                        project: project,
                        projectProvider: projectProvider,
                        authProvider: authProvider,
                      ),
                    ),
                );

              },
              onDelete: () async {
                // Confirmation avant suppression
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer le projet'),
                    content: Text(
                        'Voulez-vous supprimer "${project.name}" ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await projectProvider.deleteProject(project.id);
                }
              },
            );
          },
        );
      },
    );
  }
}