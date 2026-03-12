import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project; // null = création, non-null = modification
  final ProjectProvider projectProvider;
  final AuthProvider authProvider;

  const ProjectFormScreen({
    super.key,
    this.project,
    required this.projectProvider,
    required this.authProvider,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Couleur sélectionnée
  int _selectedColor = AppColors.projectColors[0];

  // Mode édition ?
  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    // Pré-remplir si modification
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = widget.authProvider.currentUser;
    if (user == null) return;

    if (_isEditing) {
      // Modification
      final updated = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
      );
      await widget.projectProvider.updateProject(updated);
    } else {
      // Création
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: user.id,
        color: _selectedColor,
        createdAt: DateTime.now(),
      );
      await widget.projectProvider.createProject(project);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier projet' : 'Nouveau projet'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Nom du projet
                CustomTextField(
                  label: 'Nom du projet',
                  controller: _nameController,
                  prefixIcon: Icons.folder,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom obligatoire';
                    }
                    if (value.length < 3) {
                      return 'Minimum 3 caractères';
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

                // Sélecteur couleur
                const Text(
                  'Couleur du projet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // 8 cercles de couleur dans un Wrap
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.projectColors.map((colorValue) {
                    final isSelected = colorValue == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorValue),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Aperçu en temps réel avec ProjectCard
                const Text(
                  'Aperçu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ListenableBuilder(
                  listenable: _nameController,
                  builder: (context, _) {
                    return ProjectCard(
                      project: Project(
                        id: 'preview',
                        name: _nameController.text.isEmpty
                            ? 'Nom du projet'
                            : _nameController.text,
                        description: _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                        userId: '',
                        color: _selectedColor,
                        createdAt: DateTime.now(),
                      ),
                      taskCount: 0,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Bouton sauvegarder
                ListenableBuilder(
                  listenable: widget.projectProvider,
                  builder: (context, _) {
                    return CustomButton(
                      text: _isEditing ? 'Modifier' : 'Créer',
                      onPressed: _save,
                      isLoading: widget.projectProvider.isLoading,
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
}