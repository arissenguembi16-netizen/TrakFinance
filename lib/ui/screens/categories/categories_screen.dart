/// Fichier : categories_screen.dart
/// Description : Gestion des catégories personnalisées

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    String type = 'expense';
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final icons = [
      Icons.fastfood, Icons.directions_car, Icons.home, Icons.local_hospital,
      Icons.sports_esports, Icons.school, Icons.work, Icons.laptop,
      Icons.shopping_bag, Icons.music_note, Icons.flight, Icons.fitness_center,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nouvelle catégorie',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Type : '),
                  ChoiceChip(
                    label: const Text('Dépense'),
                    selected: type == 'expense',
                    onSelected: (_) => setModalState(() => type = 'expense'),
                    selectedColor: AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Revenu'),
                    selected: type == 'income',
                    onSelected: (_) => setModalState(() => type = 'income'),
                    selectedColor: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Icône :'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: icons.asMap().entries.map((e) => GestureDetector(
                  onTap: () => setModalState(() => selectedIconIndex = e.key),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedIconIndex == e.key
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(e.value,
                        color: selectedIconIndex == e.key
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 22),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Couleur :'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppColors.categoryColors.asMap().entries.map(
                  (e) => GestureDetector(
                    onTap: () => setModalState(() => selectedColorIndex = e.key),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                        border: selectedColorIndex == e.key
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await context.read<CategoryProvider>().addCategory(
                      name: nameCtrl.text.trim(),
                      iconCodePoint: icons[selectedIconIndex].codePoint,
                      colorValue: AppColors.categoryColors[selectedColorIndex].value,
                      type: type,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Dépenses'), Tab(text: 'Revenus')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CategoryList(
              categories: catProvider.getByType('expense'),
              onDelete: (id) => catProvider.deleteCategory(id)),
          _CategoryList(
              categories: catProvider.getByType('income'),
              onDelete: (id) => catProvider.deleteCategory(id)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List categories;
  final Function(String) onDelete;

  const _CategoryList({required this.categories, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('Aucune catégorie'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat.icon, color: cat.color),
            ),
            title: Text(cat.name),
            subtitle: cat.isDefault
                ? const Text('Catégorie par défaut',
                    style: TextStyle(fontSize: 11))
                : null,
            trailing: !cat.isDefault
                ? IconButton(
                    icon: const Icon(Icons.delete_outlined,
                        color: AppColors.danger),
                    onPressed: () => onDelete(cat.id),
                  )
                : const Icon(Icons.lock_outlined,
                    size: 16, color: AppColors.textLight),
          ),
        );
      },
    );
  }
}