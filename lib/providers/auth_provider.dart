/// Fichier : auth_provider.dart
/// Description : Gestion de l'authentification locale (SharedPreferences)

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// Hash du mot de passe avec SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Vérifie si un utilisateur est déjà connecté au lancement
  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = UserModel.fromMap(jsonDecode(userJson));
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Inscrit un nouvel utilisateur
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Vérifier si l'email existe déjà
      final usersJson = prefs.getString('users') ?? '[]';
      final List users = jsonDecode(usersJson);
      if (users.any((u) => u['email'] == email)) {
        _errorMessage = 'Cet email est déjà utilisé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = UserModel(
        id: const Uuid().v4(),
        name: name,
        email: email,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      users.add(user.toMap());
      await prefs.setString('users', jsonEncode(users));
      await prefs.setString('current_user', jsonEncode(user.toMap()));

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connecte un utilisateur existant
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List users = jsonDecode(usersJson);

      final userMap = users.firstWhere(
        (u) => u['email'] == email &&
               u['passwordHash'] == _hashPassword(password),
        orElse: () => null,
      );

      if (userMap == null) {
        _errorMessage = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = UserModel.fromMap(userMap);
      await prefs.setString('current_user', jsonEncode(userMap));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur de connexion';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _currentUser = null;
    notifyListeners();
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({String? name, String? currency}) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();

    _currentUser = _currentUser!.copyWith(name: name, currency: currency);

    // Mettre à jour dans la liste des utilisateurs
    final usersJson = prefs.getString('users') ?? '[]';
    final List users = jsonDecode(usersJson);
    final index = users.indexWhere((u) => u['id'] == _currentUser!.id);
    if (index != -1) users[index] = _currentUser!.toMap();
    await prefs.setString('users', jsonEncode(users));
    await prefs.setString('current_user', jsonEncode(_currentUser!.toMap()));

    notifyListeners();
  }
}