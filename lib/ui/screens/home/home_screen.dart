// Fichier : home_screen.dart
// Description : Écran principal avec solde, statistiques rapides et transactions récentes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../app/routes.dart';
import '../transactions/transaction_screen.dart';
import '../statistics/statistics_screen.dart';
import '../budget/budget_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const TransactionsScreen(),
    const StatisticsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

/// Contenu de l'onglet Accueil
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final catProvider = context.watch<CategoryProvider>();
    
    final isLoggedIn = auth.isLoggedIn;
    final currency = auth.currentUser?.currency ?? 'XAF';
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar dégradé
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.balanceGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoggedIn 
                                    ? 'Bonjour, ${auth.currentUser?.name.split(' ').first ?? ''} 👋'
                                    : 'Bienvenue sur TrackFinance 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatMonthYear(now),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (isLoggedIn)
                              CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  auth.currentUser!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.login, color: Colors.white),
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                              ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Solde du mois',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          CurrencyFormatter.format(txProvider.balance, currency: currency),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Si pas connecté, bouton pour créer un compte
                  if (!isLoggedIn) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gérez mieux votre argent',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                Text(
                                  'Créez un compte pour sauvegarder vos données.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('S\'inscrire', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Cartes revenus / dépenses
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Revenus',
                          amount: txProvider.totalIncome,
                          currency: currency,
                          icon: Icons.arrow_downward,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Dépenses',
                          amount: txProvider.totalExpense,
                          currency: currency,
                          icon: Icons.arrow_upward,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Budgets
                  if (isLoggedIn && budgetProvider.currentMonthBudgets.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Mes budgets',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    ...budgetProvider.currentMonthBudgets.take(3).map(
                      (budget) {
                        final cat = catProvider.getById(budget.categoryId);
                        return _BudgetProgressTile(
                          budget: budget,
                          categoryName: cat?.name ?? 'Catégorie',
                          categoryIcon: cat?.icon ?? Icons.category,
                          currency: currency,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Transactions récentes
                  _SectionHeader(
                    title: 'Transactions récentes',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  if (txProvider.recentTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Aucune transaction ce mois',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...txProvider.recentTransactions.map(
                      (t) => _TransactionTile(
                        transaction: t,
                        category: catProvider.getById(t.categoryId),
                        currency: currency,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}

// ─── Widgets internes ──────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    CurrencyFormatter.format(amount, currency: currency),
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        TextButton(
          onPressed: onTap,
          child: const Text('Voir tout'),
        ),
      ],
    );
  }
}

class _BudgetProgressTile extends StatelessWidget {
  final dynamic budget;
  final String categoryName;
  final IconData categoryIcon;
  final String currency;

  const _BudgetProgressTile({
    required this.budget,
    required this.categoryName,
    required this.categoryIcon,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final color = budget.isExceeded
        ? AppColors.danger
        : budget.isNearLimit
            ? AppColors.warning
            : AppColors.secondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(categoryIcon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                Text(
                  '${CurrencyFormatter.format(budget.spent, currency: currency)} / '
                  '${CurrencyFormatter.format(budget.amount, currency: currency)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.progressPercentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final dynamic category;
  final String currency;

  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.secondary : AppColors.danger;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (category?.color ?? color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category?.icon ?? Icons.category,
            color: category?.color ?? color,
            size: 22,
          ),
        ),
        title: Text(transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
          DateFormatter.formatRelative(transaction.date),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currency: currency)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
