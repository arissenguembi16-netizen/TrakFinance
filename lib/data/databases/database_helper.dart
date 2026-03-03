// Fichier : database_helper.dart
// Description : Singleton de gestion de la base de données SQLite
//               Gère toutes les opérations CRUD sur les tables

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Retourne (ou crée) la base de données
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données SQLite
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trackfinance.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Crée les tables au premier lancement
  Future<void> _onCreate(Database db, int version) async {
    // Table des transactions
    await db.execute('''
      CREATE TABLE transactions (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        amount      REAL NOT NULL,
        type        TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date        TEXT NOT NULL,
        note        TEXT,
        created_at  TEXT NOT NULL
      )
    ''');

    // Table des catégories
    await db.execute('''
      CREATE TABLE categories (
        id         TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        icon       INTEGER NOT NULL,
        color      INTEGER NOT NULL,
        type       TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // Table des budgets
    await db.execute('''
      CREATE TABLE budgets (
        id          TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        amount      REAL NOT NULL,
        spent       REAL DEFAULT 0,
        month       INTEGER NOT NULL,
        year        INTEGER NOT NULL
      )
    ''');

    // Pré-charger les catégories par défaut
    await _insertDefaultCategories(db);
  }

  /// Insère les catégories par défaut
  Future<void> _insertDefaultCategories(Database db) async {
    final batch = db.batch();
    for (final cat in CategoryModel.defaults) {
      batch.insert('categories', cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // ─── TRANSACTIONS ────────────────────────────────────────────────────────

  /// Insère une transaction
  Future<void> insertTransaction(TransactionModel t) async {
    final db = await database;
    await db.insert('transactions', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Met à jour une transaction existante
  Future<void> updateTransaction(TransactionModel t) async {
    final db = await database;
    await db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
  }

  /// Supprime une transaction par son id
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Retourne toutes les transactions triées par date décroissante
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map(TransactionModel.fromMap).toList();
  }

  /// Retourne les transactions dans une plage de dates
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  /// Retourne les transactions d'un mois/année spécifique
  Future<List<TransactionModel>> getTransactionsByMonth(
      int month, int year) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(start, end);
  }

  /// Calcule le total par type et par mois
  Future<double> getTotalByTypeAndMonth(
      String type, int month, int year) async {
    final transactions = await getTransactionsByMonth(month, year);
    double total = 0.0;
    
    final targetType = type == 'income' ? TransactionType.income : TransactionType.expense;
    
    for (var t in transactions) {
      if (t.type == targetType) {
        total += t.amount;
      }
    }
    return total;
  }

  // ─── CATÉGORIES ──────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map(CategoryModel.fromMap).toList();
  }

  Future<void> insertCategory(CategoryModel cat) async {
    final db = await database;
    await db.insert('categories', cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ? AND is_default = 0',
        whereArgs: [id]);
  }

  // ─── BUDGETS ─────────────────────────────────────────────────────────────

  Future<List<BudgetModel>> getBudgetsByMonth(int month, int year) async {
    final db = await database;
    final maps = await db.query('budgets',
        where: 'month = ? AND year = ?', whereArgs: [month, year]);
    return maps.map(BudgetModel.fromMap).toList();
  }

  Future<void> insertBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBudgetSpent(
      String categoryId, int month, int year, double spent) async {
    final db = await database;
    await db.update(
      'budgets',
      {'spent': spent},
      where: 'category_id = ? AND month = ? AND year = ?',
      whereArgs: [categoryId, month, year],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
