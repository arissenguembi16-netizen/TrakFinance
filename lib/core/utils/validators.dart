/// Fichier : validators.dart
/// Description : Fonctions de validation des formulaires

class Validators {
  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'L\'email est requis';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  /// Valide un mot de passe
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  /// Valide un nom
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom est requis';
    if (value.trim().length < 2) return 'Nom trop court';
    return null;
  }

  /// Valide un montant
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Le montant est requis';
    final cleaned = value.replaceAll(' ', '').replaceAll(',', '.');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Montant invalide';
    if (amount <= 0) return 'Le montant doit être positif';
    return null;
  }

  /// Valide un libellé de transaction
  static String? transactionTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le libellé est requis';
    if (value.trim().length < 2) return 'Libellé trop court';
    return null;
  }
}