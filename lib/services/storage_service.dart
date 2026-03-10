import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:sunu_task/models/User.dart';

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
}