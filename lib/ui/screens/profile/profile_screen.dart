/// Fichier : profile_screen.dart
/// Description : Profil utilisateur, paramètres et déconnexion

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<Map<String, String>> _currencies = [
    {'code': 'XAF', 'label': 'Franc CFA (XAF)'},
    {'code': 'EUR', 'label': 'Euro (EUR)'},
    {'code': 'USD', 'label': 'Dollar US (USD)'},
    {'code': 'MAD', 'label': 'Dirham (MAD)'},
    {'code': 'GNF', 'label': 'Franc Guinéen (GNF)'},
  ];

  void _showEditDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nom complet'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              auth.updateProfile(name: nameCtrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Choisir la devise',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ..._currencies.map(
            (c) => ListTile(
              title: Text(c['label']!),
              trailing: context.read<AuthProvider>().currentUser?.currency ==
                      c['code']
                  ? const Icon(Icons.check, color: AppColors.secondary)
                  : null,
              onTap: () {
                context
                    .read<AuthProvider>()
                    .updateProfile(currency: c['code']);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final user = auth.currentUser;
    final currency = user?.currency ?? 'XAF';

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        children: [
          // Header profil
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.balanceGradient,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (user?.name.isNotEmpty ?? false)
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),

          // Stats globales
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatTile(
                    label: 'Transactions',
                    value: '${txProvider.transactions.length}'),
                _StatTile(
                    label: 'Ce mois',
                    value: CurrencyFormatter.format(txProvider.balance,
                        currency: currency)),
              ],
            ),
          ),

          const Divider(),

          // Options
          ListTile(
            leading: const Icon(Icons.person_outlined, color: AppColors.primary),
            title: const Text('Modifier le profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange, color: AppColors.primary),
            title: const Text('Devise'),
            subtitle: Text(currency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: AppColors.primary),
            title: const Text('Catégories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Se déconnecter',
                style: TextStyle(color: AppColors.danger)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger),
                      child: const Text('Déconnecter',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await auth.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text('TrackFinance v1.0.0 — ESITECH L3',
                style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}