
import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
// Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
// Getters publics
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser !=null; // true si _currentUser != null
  bool get isLoading =>  _isLoading;
  String? get error => _error;

  // Charge l'utilisateur depuis le stockage
  Future<void> init() async {
    _currentUser = StorageService.instance.getCurrentUser();
    notifyListeners();
  }
  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final users = StorageService.instance.getUsers();
    final user = users.where (
            (u) => u.email == email && u.password == password
    ).firstOrNull;
    if (user != null) {
      _currentUser = user;
      await StorageService.instance.saveCurrentUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email ou mot de passe incorrect';
      _isLoading = false;
      notifyListeners();
      return false;
    }

  }
  // Inscription
  Future<bool> register(String name, String email, String password) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  final users = StorageService.instance.getUsers();
  final exists = users.any((u) => u.email == email);

  if (exists) {
  _error = 'Cet email est déjà utilisé';
  _isLoading = false;
  notifyListeners();
  return false;

  }

  final newUser = User(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: name,
  email: email,
  password: password,

  );

  await StorageService.instance.saveUser(newUser);
  await StorageService.instance.saveCurrentUser(newUser);
  _currentUser = newUser;
  _isLoading = false;
  notifyListeners();
  return true;
}

  // Déconnexion
  Future<void> logout() async{
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }
  // Mise à jour profil
  Future<void> updateProfile({String? name, String? email})async{
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, email: email);
    await StorageService.instance.saveUser(updated);
    await StorageService.instance.saveCurrentUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  // Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
