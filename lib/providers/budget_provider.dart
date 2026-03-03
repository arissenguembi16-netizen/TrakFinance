// Fichier : budget_provider.dart
// Description : Gestion des budgets mensuels par catégorie

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/databases/database_helper.dart';
import '../data/models/budget_model.dart';
import '../data/models/transaction_model.dart';

class BudgetProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  /// Budgets du mois courant
  List<BudgetModel> get currentMonthBudgets {
    final now = DateTime.now();
    return _budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();
  }

  /// Synchronise les montants dépensés à partir des transactions
  void syncWithTransactions(List<TransactionModel> transactions) {
    for (final budget in _budgets) {
      final spent = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.categoryId == budget.categoryId &&
              t.date.month == budget.month &&
              t.date.year == budget.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      budget.spent = spent;
    }
    notifyListeners();
  }

  /// Charge les budgets du mois courant
  Future<void> loadBudgets() async {
    final now = DateTime.now();
    final results = await _db.getBudgetsByMonth(now.month, now.year);
    _budgets = results;
    notifyListeners();
  }

  /// Ajoute un budget mensuel
  Future<void> addBudget({
    required String categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    final budget = BudgetModel(
      id: const Uuid().v4(),
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
    );
    await _db.insertBudget(budget);
    _budgets.add(budget);
    notifyListeners();
  }

  /// Supprime un budget
  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
