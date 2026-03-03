/// Fichier : app_colors.dart
/// Description : Palette de couleurs officielle de TrackFinance

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Couleurs principales
  static const Color primary = Color(0xFF1E3A5F);      // Bleu marine
  static const Color secondary = Color(0xFF00B894);    // Vert émeraude (revenus)
  static const Color danger = Color(0xFFE17055);       // Orange-rouge (dépenses)
  static const Color warning = Color(0xFFFDCB6E);      // Jaune (alertes)

  // Fonds
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Textes
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Dégradé carte solde
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleurs des catégories
  static const List<Color> categoryColors = [
    Color(0xFFE74C3C), Color(0xFF3498DB), Color(0xFF2ECC71),
    Color(0xFFF39C12), Color(0xFF9B59B6), Color(0xFF1ABC9C),
    Color(0xFFE67E22), Color(0xFF34495E), Color(0xFF00B894),
    Color(0xFFE17055), Color(0xFF6C5CE7), Color(0xFFFD79A8),
  ];
}