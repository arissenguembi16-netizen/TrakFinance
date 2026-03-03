/// Fichier : category_model.dart
/// Description : Modèle de données pour une catégorie de transaction

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Représente une catégorie de transaction
class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;  // Code du MaterialIcon
  final int colorValue;     // Valeur ARGB de la couleur
  final String type;        // 'income' ou 'expense'
  final bool isDefault;     // Catégorie système (non supprimable)

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  /// Retourne l'icône Material
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Retourne la couleur
  Color get color => Color(colorValue);

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['icon'] as int,
      colorValue: map['color'] as int,
      type: map['type'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': iconCodePoint,
      'color': colorValue,
      'type': type,
      'is_default': isDefault ? 1 : 0,
    };
  }

  /// Liste des catégories par défaut pré-chargées
  static List<CategoryModel> get defaults => [
    // --- DÉPENSES ---
    CategoryModel(id: 'cat_food', name: 'Alimentation',
      iconCodePoint: Icons.fastfood.codePoint,
      colorValue: AppColors.categoryColors[0].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_transport', name: 'Transport',
      iconCodePoint: Icons.directions_car.codePoint,
      colorValue: AppColors.categoryColors[1].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_home', name: 'Logement',
      iconCodePoint: Icons.home.codePoint,
      colorValue: AppColors.categoryColors[2].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_health', name: 'Santé',
      iconCodePoint: Icons.local_hospital.codePoint,
      colorValue: AppColors.categoryColors[3].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_leisure', name: 'Loisirs',
      iconCodePoint: Icons.sports_esports.codePoint,
      colorValue: AppColors.categoryColors[4].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_education', name: 'Éducation',
      iconCodePoint: Icons.school.codePoint,
      colorValue: AppColors.categoryColors[5].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_clothes', name: 'Vêtements',
      iconCodePoint: Icons.checkroom.codePoint,
      colorValue: AppColors.categoryColors[6].value,
      type: 'expense', isDefault: true),
    CategoryModel(id: 'cat_other_exp', name: 'Autres',
      iconCodePoint: Icons.more_horiz.codePoint,
      colorValue: AppColors.categoryColors[7].value,
      type: 'expense', isDefault: true),
    // --- REVENUS ---
    CategoryModel(id: 'cat_salary', name: 'Salaire',
      iconCodePoint: Icons.work.codePoint,
      colorValue: AppColors.categoryColors[8].value,
      type: 'income', isDefault: true),
    CategoryModel(id: 'cat_freelance', name: 'Freelance',
      iconCodePoint: Icons.laptop.codePoint,
      colorValue: AppColors.categoryColors[9].value,
      type: 'income', isDefault: true),
    CategoryModel(id: 'cat_invest', name: 'Investissement',
      iconCodePoint: Icons.trending_up.codePoint,
      colorValue: AppColors.categoryColors[10].value,
      type: 'income', isDefault: true),
    CategoryModel(id: 'cat_gift', name: 'Cadeau',
      iconCodePoint: Icons.card_giftcard.codePoint,
      colorValue: AppColors.categoryColors[11].value,
      type: 'income', isDefault: true),
    CategoryModel(id: 'cat_other_inc', name: 'Autres revenus',
      iconCodePoint: Icons.attach_money.codePoint,
      colorValue: AppColors.categoryColors[0].value,
      type: 'income', isDefault: true),
  ];
}