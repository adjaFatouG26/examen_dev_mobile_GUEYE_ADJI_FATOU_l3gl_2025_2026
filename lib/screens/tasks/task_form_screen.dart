import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = création, non-null = modification
  final String projectId;
  final TaskProvider taskProvider;
  final AuthProvider authProvider;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.projectId,
    required this.taskProvider,
    required this.authProvider,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Statut sélectionné
  TaskStatus _selectedStatus = TaskStatus.todo;

  // Priorité sélectionnée
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Date d'échéance
  DateTime? _dueDate;

  // Mode édition ?
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    // Pré-remplir si modification
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Sauvegarder
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = widget.authProvider.currentUser;
    if (user == null) return;

    if (_isEditing) {
      // Modification
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _dueDate,
      );
      await widget.taskProvider.updateTask(updated);
    } else {
      // Création
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: widget.projectId,
        userId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
      );
      await widget.taskProvider.createTask(task);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  // Supprimer la tâche
  Future<void> _delete() async {
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
      await widget.taskProvider.deleteTask(widget.task!.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // Sélecteur de date
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier tâche' : 'Nouvelle tâche'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // Bouton suppression uniquement en mode modification
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Titre
                CustomTextField(
                  label: 'Titre',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Titre obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  label: 'Description (optionnel)',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Sélecteur statut — 3 conteneurs animés
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
                  children: [
                    _buildStatusSelector(
                      'À faire',
                      TaskStatus.todo,
                      AppColors.statusTodo,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusSelector(
                      'En cours',
                      TaskStatus.inProgress,
                      AppColors.statusInProgress,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusSelector(
                      'Terminée',
                      TaskStatus.done,
                      AppColors.statusDone,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sélecteur priorité — 3 conteneurs animés
                const Text(
                  'Priorité',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPrioritySelector(
                      'Haute',
                      TaskPriority.high,
                      AppColors.priorityHigh,
                    ),
                    const SizedBox(width: 8),
                    _buildPrioritySelector(
                      'Moyenne',
                      TaskPriority.medium,
                      AppColors.priorityMedium,
                    ),
                    const SizedBox(width: 8),
                    _buildPrioritySelector(
                      'Basse',
                      TaskPriority.low,
                      AppColors.priorityLow,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Date d'échéance
                const Text(
                  "Date d'échéance",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate != null
                              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _dueDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(Icons.clear,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton sauvegarder
                ListenableBuilder(
                  listenable: widget.taskProvider,
                  builder: (context, _) {
                    return CustomButton(
                      text: _isEditing ? 'Modifier' : 'Créer',
                      onPressed: _save,
                      isLoading: widget.taskProvider.isLoading,
                      color: AppColors.primary,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Conteneur animé pour le statut
  Widget _buildStatusSelector(
      String label, TaskStatus status, Color color) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => setState(() => _selectedStatus = status),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Conteneur animé pour la priorité
  Widget _buildPrioritySelector(
      String label, TaskPriority priority, Color color) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => setState(() => _selectedPriority = priority),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}