import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final AuthProvider authProvider;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.projectProvider,
    required this.taskProvider,
    required this.authProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  @override
  void initState() {
    super.initState();
    // Charger les tâches du projet
    widget.taskProvider.loadTasks(widget.project.id);
  }

  // Supprimer le projet
  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text(
            'Voulez-vous supprimer "${widget.project.name}" et toutes ses tâches ?'),
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
      await widget.projectProvider.deleteProject(widget.project.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: Color(widget.project.color),
        foregroundColor: Colors.white,
        // Actions : modifier et supprimer
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(
                    project: widget.project,
                    projectProvider: widget.projectProvider,
                    authProvider: widget.authProvider,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.taskProvider,
        builder: (context, _) {
          final tasks = widget.taskProvider.tasks;
          final taskStats = widget.taskProvider.taskCountByStatus;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // En-tête coloré
                Container(
                  width: double.infinity,
                  color: Color(widget.project.color).withOpacity(0.15),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.project.description != null &&
                          widget.project.description!.isNotEmpty)
                        Text(
                          widget.project.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Date de création
                      Text(
                        'Créé le ${widget.project.createdAt.day}/${widget.project.createdAt.month}/${widget.project.createdAt.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistiques tâches — chips par statut
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatChip(
                        'À faire',
                        taskStats[TaskStatus.todo] ?? 0,
                        AppColors.statusTodo,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'En cours',
                        taskStats[TaskStatus.inProgress] ?? 0,
                        AppColors.statusInProgress,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Terminées',
                        taskStats[TaskStatus.done] ?? 0,
                        AppColors.statusDone,
                      ),
                    ],
                  ),
                ),

                // Liste des tâches
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Tâches (${tasks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                tasks.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune tâche pour ce projet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: tasks[index],
                      onTap: () {
                        // sera complété avec TaskDetailScreen
                      },
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      // FAB pour ajouter une tâche
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(widget.project.color),
        foregroundColor: Colors.white,
        onPressed: () {
          // sera complété avec TaskFormScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Chip statistique
  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        '$label : $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color),
    );
  }
}