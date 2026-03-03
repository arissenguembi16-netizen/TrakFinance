/// Fichier : statistics_screen.dart
/// Description : Visualisation des statistiques financières avec fl_chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mensuel'),
            Tab(text: 'Annuel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MonthlyStats(),
          _AnnualStats(),
        ],
      ),
    );
  }
}

class _MonthlyStats extends StatelessWidget {
  const _MonthlyStats();

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final currency = context.read<AuthProvider>().currentUser?.currency ?? 'XAF';

    final expenses = txProvider.monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final expByCategory = txProvider.expensesByCategory;
    final totalExpense = txProvider.totalExpense;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Résumé chiffres clés
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Revenus',
              value: CurrencyFormatter.format(txProvider.totalIncome, currency: currency),
              color: AppColors.secondary,
              icon: Icons.trending_up,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'Dépenses',
              value: CurrencyFormatter.format(txProvider.totalExpense, currency: currency),
              color: AppColors.danger,
              icon: Icons.trending_down,
            )),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Taux d\'épargne',
          value: txProvider.totalIncome > 0
              ? '${((1 - txProvider.totalExpense / txProvider.totalIncome) * 100).clamp(0, 100).toStringAsFixed(1)}%'
              : '—',
          color: AppColors.primary,
          icon: Icons.savings_outlined,
          fullWidth: true,
        ),
        const SizedBox(height: 24),

        // PieChart dépenses par catégorie
        if (expByCategory.isNotEmpty) ...[
          const Text('Répartition des dépenses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: expByCategory.entries.map((entry) {
                  final cat = catProvider.getById(entry.key);
                  final pct = totalExpense > 0
                      ? (entry.value / totalExpense * 100)
                      : 0.0;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${pct.toStringAsFixed(0)}%',
                    color: cat?.color ?? AppColors.primary,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
            ),
          ),
          const SizedBox(height: 12),
          // Légende
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: expByCategory.entries.map((entry) {
              final cat = catProvider.getById(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: cat?.color ?? AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${cat?.name ?? entry.key}: ${CurrencyFormatter.format(entry.value, currency: currency)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Aucune dépense ce mois'),
            ),
          ),
      ],
    );
  }
}

class _AnnualStats extends StatelessWidget {
  const _AnnualStats();

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final currency = context.read<AuthProvider>().currentUser?.currency ?? 'XAF';
    final data = txProvider.getLast6MonthsData();

    final maxVal = data.fold<double>(
        0, (m, d) => [m, d['income'] as double, d['expense'] as double].reduce(
            (a, b) => a > b ? a : b));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Revenus vs Dépenses (6 mois)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),

        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              maxY: maxVal * 1.2,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < data.length) {
                        return Text(
                          DateFormatter.formatMonthShort(DateTime(
                              data[i]['year'] as int, data[i]['month'] as int)),
                          style: const TextStyle(fontSize: 11),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: (e.value['income'] as double),
                      color: AppColors.secondary,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: (e.value['expense'] as double),
                      color: AppColors.danger,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 600),
          ),
        ),
        const SizedBox(height: 12),

        // Légende
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.secondary, label: 'Revenus'),
            const SizedBox(width: 24),
            _LegendDot(color: AppColors.danger, label: 'Dépenses'),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}