/// Fichier : user_model.dart
/// Description : Modèle de données utilisateur (stockage local)

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String currency;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.currency = 'XAF',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'passwordHash': passwordHash,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    passwordHash: map['passwordHash'],
    currency: map['currency'] ?? 'XAF',
    createdAt: DateTime.parse(map['createdAt']),
  );

  UserModel copyWith({String? name, String? currency}) => UserModel(
    id: id,
    name: name ?? this.name,
    email: email,
    passwordHash: passwordHash,
    currency: currency ?? this.currency,
    createdAt: createdAt,
  );
}