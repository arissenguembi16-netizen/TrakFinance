/// Fichier : add_transaction_screen.dart
/// Description : Formulaire d'ajout / modification d'une transaction

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  TransactionModel? _editingTransaction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TransactionModel && !_isEditing) {
      _isEditing = true;
      _editingTransaction = args;
      _titleCtrl.text = args.title;
      _amountCtrl.text = args.amount.toStringAsFixed(0);
      _noteCtrl.text = args.note ?? '';
      _type = args.type;
      _selectedCategoryId = args.categoryId;
      _selectedDate = args.date;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }

    final amount = double.parse(
        _amountCtrl.text.trim().replaceAll(' ', '').replaceAll(',', '.'));
    final txProvider = context.read<TransactionProvider>();

    if (_isEditing && _editingTransaction != null) {
      await txProvider.updateTransaction(
        _editingTransaction!.copyWith(
          title: _titleCtrl.text.trim(),
          amount: amount,
          type: _type,
          categoryId: _selectedCategoryId,
          date: _selectedDate,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        ),
      );
    } else {
      await txProvider.addTransaction(
        title: _titleCtrl.text.trim(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final typeString = _type == TransactionType.expense ? 'expense' : 'income';
    final filteredCats = catProvider.getByType(typeString);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier' : 'Ajouter'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sélecteur Type (Dépense / Revenu)
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('💸 Dépense'),
                    selected: _type == TransactionType.expense,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _type = TransactionType.expense;
                          _selectedCategoryId = null;
                        });
                      }
                    },
                    selectedColor: AppColors.danger.withOpacity(0.2),
                    labelStyle: TextStyle(color: _type == TransactionType.expense ? AppColors.danger : Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('💰 Revenu'),
                    selected: _type == TransactionType.income,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _type = TransactionType.income;
                          _selectedCategoryId = null;
                        });
                      }
                    },
                    selectedColor: AppColors.secondary.withOpacity(0.2),
                    labelStyle: TextStyle(color: _type == TransactionType.income ? AppColors.secondary : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Montant',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre de la transaction',
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: Validators.transactionTitle,
            ),
            const SizedBox(height: 24),

            const Text('Choisir une catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (filteredCats.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Aucune catégorie disponible.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredCats.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: isSelected ? cat.color : Colors.transparent, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                          const SizedBox(width: 8),
                          Text(cat.name, style: TextStyle(
                            color: isSelected ? Colors.white : cat.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 24),
            ListTile(
              onTap: _pickDate,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              trailing: Text(DateFormatter.formatShort(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _type == TransactionType.expense ? AppColors.danger : AppColors.secondary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEditing ? 'MODIFIER' : 'ENREGISTRER', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
