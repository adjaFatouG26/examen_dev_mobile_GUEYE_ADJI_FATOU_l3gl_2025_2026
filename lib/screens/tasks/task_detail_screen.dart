import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/models/Comment.dart';
import 'package:sunu_task/providers/comment_provider.dart';
import 'package:sunu_task/widgets/cards/comment_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final TaskProvider taskProvider;
  final AuthProvider authProvider;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.taskProvider,
    required this.authProvider,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {

  // Provider commentaires local
  final _commentProvider = CommentProvider();

  // Controller champ commentaire
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les commentaires de la tâche dés l'ouverture de l'ecran
    _commentProvider.loadComments(widget.task.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Couleur selon le statut
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  // Texte selon le statut
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'À faire';
      case TaskStatus.inProgress:
        return 'En cours';
      case TaskStatus.done:
        return 'Terminée';
    }
  }

  // Couleur selon la priorité
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  // Texte selon la priorité
  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Basse';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.high:
        return 'Haute';
    }
  }

  // Supprimer la tâche
  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Voulez-vous supprimer cette tâche ?'),
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
      await widget.taskProvider.deleteTask(widget.task.id);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  // Ajouter un commentaire
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final user = widget.authProvider.currentUser;
    if (user == null) return;
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: widget.task.id,
      userId: user.id,
      userName: user.name,
      content: _commentController.text.trim(),
    );
    await _commentProvider.addComment(comment);
    _commentController.clear();
  }

  // Supprimer un commentaire
  Future<void> _deleteComment(Comment comment) async {
    await _commentProvider.deleteComment(comment.id, widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // Actions : modifier et supprimer
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(
                    task: widget.task,
                    projectId: widget.task.projectId,
                    taskProvider: widget.taskProvider,
                    authProvider: widget.authProvider,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.taskProvider,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Titre
                Text(
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                if (widget.task.description != null &&
                    widget.task.description!.isNotEmpty) ...[
                  Text(
                    widget.task.description!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(),
                const SizedBox(height: 16),

                // Statut avec changement rapide
                const Text(
                  'Statut',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: TaskStatus.values.map((status) {
                    final isSelected = widget.task.status == status;
                    final color = _getStatusColor(status);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: () async {
                              await widget.taskProvider.updateTaskStatus(
                                  widget.task.id, status);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withOpacity(0.15)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? color : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusText(status),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? color
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Priorité avec indicateur visuel
                const Text(
                  'Priorité',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(widget.task.priority)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _getPriorityColor(widget.task.priority)),
                  ),
                  child: Text(
                    _getPriorityText(widget.task.priority),
                    style: TextStyle(
                      color: _getPriorityColor(widget.task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Date d'échéance
                if (widget.task.dueDate != null) ...[
                  const Text(
                    "Date d'échéance",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Section commentaires
                const Text(
                  'Commentaires',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Champ ajout commentaire
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Ajouter un commentaire...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                      color: AppColors.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Liste commentaires
                ListenableBuilder(
                  listenable: _commentProvider,
                  builder: (context, _) {
                    final comments = _commentProvider.comments;
                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun commentaire',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentCard(
                          comment: comments[index],
                          onDelete: () => _deleteComment(comments[index]),
                        );
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
    );
  }
}