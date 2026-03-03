/// Fichier : budget_model.dart
/// Description : Modèle de données pour un budget mensuel par catégorie

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;   // Limite de budget
  double spent;          // Montant dépensé (mis à jour dynamiquement)
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.spent = 0.0,
    required this.month,
    required this.year,
  });

  /// Montant restant disponible
  double get remaining => amount - spent;

  /// Pourcentage d'utilisation (0.0 à 1.0, plafonné à 1.0)
  double get progressPercentage => (spent / amount).clamp(0.0, 1.0);

  /// Vrai si le budget est dépassé
  bool get isExceeded => spent > amount;

  /// Vrai si on approche de la limite (>= 80%)
  bool get isNearLimit => progressPercentage >= 0.8 && !isExceeded;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'spent': spent,
      'month': month,
      'year': year,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    double? spent,
    int? month,
    int? year,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}