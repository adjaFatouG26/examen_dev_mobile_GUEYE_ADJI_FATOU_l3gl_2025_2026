// dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart' show TaskStatus;
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';

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

  // Message selon l'heure

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = authProvider.currentUser;
        if (user != null) {
          await projectProvider.loadProjects(user.id);
        }
      },
      child: ListenableBuilder(
        listenable: projectProvider,
        builder: (context, _) {
          final user = authProvider.currentUser;
          final projects = projectProvider.projects;
          final taskStats = taskProvider.taskCountByStatus;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Message de bienvenue

                Text(
                  '${_getGreeting()}, ${user?.name ?? ''} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Voici un résumé de vos projets',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Cartes statistiques

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Projets',
                        projectProvider.projectCount.toString(),
                        Icons.folder,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'À faire',
                        (taskStats[TaskStatus.todo] ?? 0).toString(),
                        Icons.radio_button_unchecked,
                        AppColors.statusTodo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'En cours',
                        (taskStats[TaskStatus.inProgress] ?? 0).toString(),
                        Icons.autorenew,
                        AppColors.statusInProgress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Terminées',
                        (taskStats[TaskStatus.done] ?? 0).toString(),
                        Icons.check_circle,
                        AppColors.statusDone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Projets récents
                const Text(
                  'Projets récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                projects.isEmpty
                    ? Center(
                  child: Text(
                    'Aucun projet pour le moment',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projects.length > 3 ? 3 : projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      taskCount: taskProvider.tasks
                          .where((t) => t.projectId == project.id)
                          .length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(
                              project: project,
                              projectProvider: projectProvider,
                              taskProvider: taskProvider,
                              authProvider: authProvider,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}