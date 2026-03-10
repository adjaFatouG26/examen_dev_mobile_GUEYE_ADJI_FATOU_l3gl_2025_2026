import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/models/Task.dart';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  static StorageService? _instance;

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========
  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if(_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingConmplete = 'onboarding_complete';


  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

   Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }

//ici on crée un clé utilisateur

  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';

  // aprés on récupére ts les utilisateurs

  List<User> getUsers() {
    final data = _prefs.getString(_keyUsers);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => User.fromMap(e)).toList();
  }
  // on sauvegarde un utilisateur

  Future<void> saveUser(User user) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    final list = users.map((u) => u.toMap()).toList();
    await _prefs.setString(_keyUsers, jsonEncode(list));
  }
  // enfin ici on récupére les utilisateurs courant

  User? getCurrentUser() {
    final data = _prefs.getString(_keyCurrentUser);
    if (data == null) return null;
    return User.fromMap(jsonDecode(data));
  }

  // Sauvegarder l'utilisateur courant

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  // Supprimer l'utilisateur courant

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }
  // ======== Clés Projets & Tâches =========
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ======== Projets =========

  // Récupérer tous les projets
  List<Project> getProjects(String userId) {
    final data = _prefs.getString(_keyProjects);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list
        .map((e) => Project.fromMap(e))
        .where((p) => p.userId == userId)
        .toList();
  }

  // Sauvegarder un projet
  Future<void> saveProject(Project project) async {
    final data = _prefs.getString(_keyProjects);
    final List<dynamic> list = data != null ? jsonDecode(data) : [];
    final projects = list.map((e) => Project.fromMap(e)).toList();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(
        _keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  // Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    final data = _prefs.getString(_keyProjects);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final projects = list
        .map((e) => Project.fromMap(e))
        .where((p) => p.id != projectId)
        .toList();
    await _prefs.setString(
        _keyProjects, jsonEncode(projects.map((p) => p.toMap()).toList()));
  }

  // ======== Tâches =========

  // Récupérer les tâches d'un projet
  List<Task> getTasks(String projectId) {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list
        .map((e) => Task.fromMap(e))
        .where((t) => t.projectId == projectId)
        .toList();
  }

  // Sauvegarder une tâche
  Future<void> saveTask(Task task) async {
    final data = _prefs.getString(_keyTasks);
    final List<dynamic> list = data != null ? jsonDecode(data) : [];
    final tasks = list.map((e) => Task.fromMap(e)).toList();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  // Supp une tâche
  Future<void> deleteTask(String taskId) async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final tasks = list
        .map((e) => Task.fromMap(e))
        .where((t) => t.id != taskId)
        .toList();
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  // Supp ttes ls tâches du projet

  Future<void> deleteTasksByProjectId(String projectId) async {
    final data = _prefs.getString(_keyTasks);
    if (data == null) return;
    final List<dynamic> list = jsonDecode(data);
    final tasks = list
        .map((e) => Task.fromMap(e))
        .where((t) => t.projectId != projectId)
        .toList();
    await _prefs.setString(
        _keyTasks, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
}