/// Fichier : date_formatter.dart
/// Description : Utilitaires de formatage des dates en français

import 'package:intl/intl.dart';

class DateFormatter {
  static final _dayFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
  static final _shortFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final _monthYear = DateFormat('MMMM yyyy', 'fr_FR');
  static final _monthShort = DateFormat('MMM', 'fr_FR');

  static String formatFull(DateTime date) => _dayFormat.format(date);
  static String formatShort(DateTime date) => _shortFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);
  static String formatMonthShort(DateTime date) => _monthShort.format(date);

  /// Retourne "Aujourd'hui", "Hier" ou la date formatée
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return "Aujourd'hui";
    if (d == today.subtract(const Duration(days: 1))) return "Hier";
    return formatShort(date);
  }
}