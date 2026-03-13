import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/Comment.dart';
import 'package:sunu_task/services/storage_service.dart';

class CommentProvider extends ChangeNotifier {

  // ici On a ls propriétés privées

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;

  // Getters publics

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charge ls commentaires d'une tâche

  Future<void> loadComments(String taskId) async {
    _isLoading = true;
    notifyListeners();
    _comments = StorageService.instance.getCommentsByTaskId(taskId);
    _isLoading = false;
    notifyListeners();
  }

  // Ajoute un commentaire

  Future<void> addComment(Comment comment) async {
    _isLoading = true;
    notifyListeners();
    await StorageService.instance.saveComment(comment);
    _comments = StorageService.instance.getCommentsByTaskId(comment.taskId);
    _isLoading = false;
    notifyListeners();
  }

  //  Supp un commentaire

  Future<void> deleteComment(String commentId, String taskId) async {
    _isLoading = true;
    notifyListeners();
    await StorageService.instance.deleteComment(commentId);
    _comments = StorageService.instance.getCommentsByTaskId(taskId);
    _isLoading = false;
    notifyListeners();
  }

  // Effacer l'erreur
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}