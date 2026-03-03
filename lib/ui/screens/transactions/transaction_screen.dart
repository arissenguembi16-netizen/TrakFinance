/// Fichier : transactions_screen.dart
/// Description : Liste filtrée de toutes les transactions avec recherche et swipe-to-delete

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all'; // 'all', 'income', 'expense'
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _filtered(List<TransactionModel> all) {
    return all.where((t) {
      final matchType = _filter == 'all' ||
          (_filter == 'income' && t.type == TransactionType.income) ||
          (_filter == 'expense' && t.type == TransactionType.expense);
      final matchSearch = _search.isEmpty ||
          t.title.toLowerCase().contains(_search.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  /// Regroupe les transactions par date
  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txs) {
    final Map<String, List<TransactionModel>> groups = {};
    for (final t in txs) {
      final key = DateFormatter.formatRelative(t.date);
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Confirmer la suppression de cette transaction ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<TransactionProvider>().deleteTransaction(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final currency = context.read<AuthProvider>().currentUser?.currency ?? 'XAF';
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final m = txProvider.selectedMonth;
              final y = txProvider.selectedYear;
              txProvider.setSelectedMonth(m == 1 ? 12 : m - 1,
                  m == 1 ? y - 1 : y);
            },
          ),
          Text(
            DateFormatter.formatMonthYear(
                DateTime(txProvider.selectedYear, txProvider.selectedMonth)),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final m = txProvider.selectedMonth;
              final y = txProvider.selectedYear;
              txProvider.setSelectedMonth(m == 12 ? 1 : m + 1,
                  m == 12 ? y + 1 : y);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Filtres type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _FilterChip(label: 'Tous', value: 'all',
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Revenus', value: 'income',
                    selected: _filter == 'income',
                    color: AppColors.secondary,
                    onTap: () => setState(() => _filter = 'income')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Dépenses', value: 'expense',
                    selected: _filter == 'expense',
                    color: AppColors.danger,
                    onTap: () => setState(() => _filter = 'expense')),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Liste groupée par date
          Expanded(
            child: Builder(
              builder: (_) {
                final filtered = _filtered(txProvider.monthlyTransactions);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Aucune transaction trouvée',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                final groups = _groupByDate(filtered);
                final keys = groups.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: keys.length,
                  itemBuilder: (_, i) {
                    final key = keys[i];
                    final items = groups[key]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ...items.map((t) {
                          final cat = catProvider.getById(t.categoryId);
                          final isIncome = t.type == TransactionType.income;
                          final color = isIncome ? AppColors.secondary : AppColors.danger;

                          return Slidable(
                            key: ValueKey(t.id),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) => Navigator.pushNamed(
                                    context,
                                    AppRoutes.addTransaction,
                                    arguments: t,
                                  ),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Modifier',
                                ),
                                SlidableAction(
                                  onPressed: (_) => _confirmDelete(context, t.id),
                                  backgroundColor: AppColors.danger,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Supprimer',
                                ),
                              ],
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (cat?.color ?? color).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(cat?.icon ?? Icons.category,
                                      color: cat?.color ?? color, size: 22),
                                ),
                                title: Text(t.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500, fontSize: 14)),
                                subtitle: Text(cat?.name ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount, currency: currency)}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    this.color = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}