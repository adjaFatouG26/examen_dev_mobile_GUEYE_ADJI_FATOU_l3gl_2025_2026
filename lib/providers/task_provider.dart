
import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/services/storage_service.dart';


class TaskProvider extends ChangeNotifier {
  // propirétés privées
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

// Getters
  // Retourne les tâches filtrées et triées

  List<Task> get tasks {
    var filtered = _tasks.where((t) {
      if (_statusFilter != null && t.status != _statusFilter) return false;
      if (_priorityFilter != null && t.priority != _priorityFilter)
        return false;
      return true;
    }).toList();

    // Tri : inProgress > todo > done, puis high > medium > low
    filtered.sort((a, b) {
      final statusOrder = {
        TaskStatus.inProgress: 0,
        TaskStatus.todo: 1,
        TaskStatus.done: 2
      };
      int cmp = statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
      if (cmp != 0) return cmp;
      final priorityOrder = {
        TaskPriority.high: 0,
        TaskPriority.medium: 1,
        TaskPriority.low: 2
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
    return filtered;
  }

// Compteur par statut
  Map<TaskStatus, int> get taskCountByStatus {
    return {
      TaskStatus.todo: _tasks
          .where((t) => t.status == TaskStatus.todo)
          .length,
      TaskStatus.inProgress: _tasks
          .where((t) => t.status == TaskStatus.inProgress)
          .length,
      TaskStatus.done: _tasks
          .where((t) => t.status == TaskStatus.done)
          .length,
    };
  }

// Méthodes CRUD
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    _tasks = StorageService.instance.getTasks(projectId);
    _isLoading = false;
    notifyListeners();
  }

// Créer une tâche
  Future<void> createTask(Task task) async {
    await StorageService.instance.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

// Modifier une tâche
  Future<void> updateTask(Task task) async {
    await StorageService.instance.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    await StorageService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

// Mettre à jour le statut
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final updated = _tasks[index].copyWith(status: status);
      await StorageService.instance.saveTask(updated);
      _tasks[index] = updated;
      notifyListeners();
    }
  }

// Filtres
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}

