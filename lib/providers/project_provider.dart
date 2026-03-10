import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/services/storage_service.dart';


class ProjectProvider extends ChangeNotifier {

// Propriétés privées
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

// Getters
  List<Project> get projects => _projects;

  Project? get selectedProject => _selectedProject;

  int get projectCount => _projects.length;

// Méthodes CRUD
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();
    _projects = StorageService.instance.getProjects(userId);
    _isLoading = false;
    notifyListeners();
  }

// créer un projet
  Future<void> createProject(Project project) async {
    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  // Modifier un projet

  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  // supprimer un projet

  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    await StorageService.instance.deleteTasksByProjectId(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  // selectionner un projet

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}

