// Fichier : currency_formatter.dart
// Description : Utilitaires pour formater les montants selon la devise

import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formate un montant avec le symbole de devise
  static String format(double amount, {String currency = 'XAF'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: _getSymbol(currency),
      decimalDigits: currency == 'XAF' ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Formate sans symbole pour les champs de saisie
  static String formatPlain(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(amount);
  }

  static String _getSymbol(String currency) {
    const symbols = {
      'XAF': 'FCFA',
      'EUR': '€',
      'USD': '\$',
      'MAD': 'MAD',
      'GNF': 'GNF',
    };
    return symbols[currency] ?? currency;
  }
}
