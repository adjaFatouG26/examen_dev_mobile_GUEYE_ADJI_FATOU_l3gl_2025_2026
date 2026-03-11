// tasks_tab.dart
import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

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
    return ListenableBuilder(
      listenable: taskProvider,
      builder: (context, _) {
        final tasks = taskProvider.tasks;

        return Column(
          children: [

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Filtre statut
                  _buildFilterChip(
                    context,
                    label: 'À faire',
                    color: AppColors.statusTodo,
                    onTap: () => taskProvider.setStatusFilter(
                        TaskStatus.todo),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'En cours',
                    color: AppColors.statusInProgress,
                    onTap: () => taskProvider.setStatusFilter(
                        TaskStatus.inProgress),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Terminées',
                    color: AppColors.statusDone,
                    onTap: () => taskProvider.setStatusFilter(
                        TaskStatus.done),
                  ),
                  const SizedBox(width: 8),
                  // Bouton reset filtres
                  ActionChip(
                    label: const Text('Tout voir'),
                    onPressed: () => taskProvider.clearFilters(),
                  ),
                ],
              ),
            ),

            // Liste tâches ou état vide
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune tâche',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: tasks[index],
                    onTap: () {

                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
      BuildContext context, {
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      side: BorderSide(color: color),
      onPressed: onTap,
    );
  }
}