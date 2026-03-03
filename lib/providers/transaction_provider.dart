// Fichier : transaction_provider.dart
// Description : Gestion de l'état des transactions financières

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/databases/database_helper.dart';
import '../data/models/transaction_model.dart';
import '../data/models/category_model.dart';

class TransactionProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<TransactionModel> _transactions = [];
  // ignore: unused_field
  List<CategoryModel> _categories = [];
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // ─── Getters ─────────────────────────────────────────────────────────────

  List<TransactionModel> get transactions => _transactions;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  /// Transactions du mois sélectionné
  List<TransactionModel> get monthlyTransactions => _transactions
      .where((t) => t.date.month == _selectedMonth && t.date.year == _selectedYear)
      .toList();

  /// Total des revenus du mois sélectionné
  double get totalIncome => monthlyTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Total des dépenses du mois sélectionné
  double get totalExpense => monthlyTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Solde du mois sélectionné
  double get balance => totalIncome - totalExpense;

  /// 5 dernières transactions
  List<TransactionModel> get recentTransactions =>
      monthlyTransactions.take(5).toList();

  /// Dépenses regroupées par catégorie (id → montant)
  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final t in monthlyTransactions.where(
        (t) => t.type == TransactionType.expense)) {
      result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
    }
    return result;
  }

  // ─── Méthodes ────────────────────────────────────────────────────────────

  /// Met à jour la liste des catégories (appelé via ProxyProvider)
  void updateCategories(List<CategoryModel> categories) {
    _categories = categories;
  }

  /// Charge toutes les transactions depuis SQLite
  Future<void> loadTransactions() async {
    _transactions = await _db.getAllTransactions();
    notifyListeners();
  }

  /// Ajoute une nouvelle transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final t = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.insertTransaction(t);
    _transactions.insert(0, t);
    notifyListeners();
  }

  /// Met à jour une transaction existante
  Future<void> updateTransaction(TransactionModel t) async {
    await _db.updateTransaction(t);
    final index = _transactions.indexWhere((tr) => tr.id == t.id);
    if (index != -1) _transactions[index] = t;
    notifyListeners();
  }

  /// Supprime une transaction
  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Change le mois affiché
  void setSelectedMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  /// Données mensuelles pour les 6 derniers mois (graphiques)
  List<Map<String, dynamic>> getLast6MonthsData() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthTransactions = _transactions.where(
        (t) => t.date.month == date.month && t.date.year == date.year,
      );
      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      return {'month': date.month, 'year': date.year,
              'income': income, 'expense': expense};
    }).reversed.toList();
  }
}
