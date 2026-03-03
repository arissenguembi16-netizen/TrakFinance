/// Fichier : budget_model.dart
/// Description : Modèle de données pour un budget mensuel par catégorie
/// Auteur : TrackFinance Team — ESITECH L3
/// Date : 2025

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;   // Limite de budget définie par l'utilisateur
  double spent;          // Montant dépensé (mis à jour dynamiquement)
  final int month;       // Mois concerné (1-12)
  final int year;        // Année concernée

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.spent = 0.0,
    required this.month,
    required this.year,
  });

  // ─── Getters calculés ────────────────────────────────────────────────────

  /// Montant restant disponible dans le budget
  double get remaining => amount - spent;

  /// Pourcentage d'utilisation entre 0.0 et 1.0 (plafonné à 1.0)
  double get progressPercentage => amount > 0
      ? (spent / amount).clamp(0.0, 1.0)
      : 0.0;

  /// Vrai si le budget est dépassé
  bool get isExceeded => spent > amount;

  /// Vrai si on approche de la limite (>= 80%) sans l'avoir dépassée
  bool get isNearLimit => progressPercentage >= 0.8 && !isExceeded;

  // ─── Sérialisation SQLite ─────────────────────────────────────────────────

  /// Crée une instance depuis une Map SQLite
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

  /// Convertit en Map pour insertion SQLite
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

  /// Crée une copie avec des champs modifiés
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

  @override
  String toString() =>
      'BudgetModel(id: $id, categoryId: $categoryId, '
          'amount: $amount, spent: $spent, month: $month, year: $year)';
}