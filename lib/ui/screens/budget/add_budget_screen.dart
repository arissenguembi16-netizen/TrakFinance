/// Fichier : add_budget_screen.dart
/// Description : Formulaire de création d'un budget mensuel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String? _selectedCategoryId;
  final now = DateTime.now();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une catégorie')),
      );
      return;
    }

    await context.read<BudgetProvider>().addBudget(
          categoryId: _selectedCategoryId!,
          amount: double.parse(_amountCtrl.text.trim()),
          month: now.month,
          year: now.year,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final expenseCategories = catProvider.getByType('expense');
    final currency = context.read<AuthProvider>().currentUser?.currency ?? 'XAF';

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Limite de budget',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: currency,
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 24),
            const Text('Catégorie de dépense',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expenseCategories.map((cat) {
                final selected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? cat.color : cat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 16,
                            color: selected ? Colors.white : cat.color),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                              color: selected ? Colors.white : cat.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Créer le budget',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}