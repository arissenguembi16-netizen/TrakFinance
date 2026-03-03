/// Fichier : budget_screen.dart
/// Description : Liste et gestion des budgets mensuels par catégorie

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final currency = context.read<AuthProvider>().currentUser?.currency ?? 'XAF';
    final budgets = budgetProvider.currentMonthBudgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets du mois')),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Aucun budget défini'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.addBudget),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un budget'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (_, i) {
                final budget = budgets[i];
                final cat = catProvider.getById(budget.categoryId);
                final color = budget.isExceeded
                    ? AppColors.danger
                    : budget.isNearLimit
                        ? AppColors.warning
                        : AppColors.secondary;

                return Slidable(
                  key: ValueKey(budget.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) =>
                            budgetProvider.deleteBudget(budget.id),
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Supprimer',
                      ),
                    ],
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: (cat?.color ?? color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(cat?.icon ?? Icons.category,
                                    color: cat?.color ?? color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat?.name ?? 'Catégorie',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(
                                      budget.isExceeded
                                          ? '⚠️ Budget dépassé de ${CurrencyFormatter.format(budget.spent - budget.amount, currency: currency)}'
                                          : '${CurrencyFormatter.format(budget.remaining, currency: currency)} restant',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: budget.isExceeded
                                            ? AppColors.danger
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(budget.spent, currency: currency),
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '/ ${CurrencyFormatter.format(budget.amount, currency: currency)}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: budget.progressPercentage,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${(budget.progressPercentage * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addBudget),
        child: const Icon(Icons.add),
      ),
    );
  }
}