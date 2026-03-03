/// Fichier : main.dart
/// Description : Point d'entrée de l'application TrackFinance

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/auth_provider.dart';
import 'core/utils/notification_helper.dart'; // Import ajouté

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des notifications
  await NotificationHelper.init();

  // Initialisation des données de localisation
  await initializeDateFormatting('fr_FR', null);

  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProxyProvider<CategoryProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, categoryProvider, transactionProvider) {
            transactionProvider!.updateCategories(categoryProvider.categories);
            return transactionProvider;
          },
        ),
        ChangeNotifierProxyProvider<TransactionProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, transactionProvider, budgetProvider) {
            budgetProvider!.syncWithTransactions(transactionProvider.transactions);
            return budgetProvider;
          },
        ),
      ],
      child: const TrackFinanceApp(),
    ),
  );
}
