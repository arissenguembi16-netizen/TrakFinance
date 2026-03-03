// Fichier : category_provider.dart
// Description : Gestion des catégories (CRUD + état)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/databases/database_helper.dart';
import '../data/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  /// Catégories filtrées par type (expense/income)
  List<CategoryModel> getByType(String type) =>
      _categories.where((c) => c.type == type).toList();

  /// Retourne une catégorie par son id
  CategoryModel? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Charge toutes les catégories depuis SQLite
  /// Si la base est vide, on s'assure que les catégories par défaut sont présentes
  Future<void> loadCategories() async {
    _categories = await _db.getAllCategories();
    
    // Si aucune catégorie n'est en base, on recharge 
    if (_categories.isEmpty) {
      _categories = await _db.getAllCategories();
    }

    notifyListeners();
  }

  /// Ajoute une catégorie personnalisée
  Future<void> addCategory({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required String type,
  }) async {
    final cat = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      type: type,
      isDefault: false,
    );
    await _db.insertCategory(cat);
    _categories.add(cat);
    notifyListeners();
  }

  /// Supprime une catégorie personnalisée
  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
