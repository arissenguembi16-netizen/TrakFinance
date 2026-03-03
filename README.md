# 💰 TrackFinance

<div align="center">
  <img src="assets/images/logo.png" alt="TrackFinance Logo" width="120" height="120"/>
  
  ### Gérez vos finances intelligemment
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
</div>

---

## 📖 À propos

**TrackFinance** est une application mobile de gestion des finances personnelles développée avec Flutter.
Elle permet à ses utilisateurs de suivre leurs dépenses et revenus, d'analyser leurs habitudes financières
et d'optimiser leur budget mensuel — le tout en mode **100% hors connexion**.

> 🎓 Projet académique — Épreuve de Développement Mobile  
> 🏫 ESITECH · Libreville, Gabon · Niveau L3 Développement · 2025

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription et connexion locale sécurisée
- Mot de passe haché avec **SHA-256**
- Session persistante via SharedPreferences

### 💸 Gestion des transactions
- Ajout, modification et suppression de transactions
- Classification en **Dépenses** ou **Revenus**
- Attribution à une catégorie
- Sélection de date et note optionnelle
- Swipe-to-delete avec confirmation

### 📂 Catégories
- 13 catégories par défaut (alimentation, transport, salaire...)
- Création de catégories personnalisées
- Icône et couleur personnalisables

### 🎯 Budgets mensuels
- Définition d'un budget limite par catégorie
- Barre de progression colorée en temps réel
- Alertes visuelles à 80% et 100% du budget

### 📊 Statistiques & Graphiques
- **PieChart** : répartition des dépenses par catégorie
- **BarChart** : comparaison Revenus vs Dépenses sur 6 mois
- Taux d'épargne mensuel calculé automatiquement
- Solde, total revenus et total dépenses du mois

### 👤 Profil utilisateur
- Modification du nom
- Choix de la devise (XAF, EUR, USD, MAD, GNF)
- Statistiques globales du compte

### 🌙 Autres
- Mode sombre automatique (selon le système)
- Interface 100% en français
- Fonctionnement entièrement hors connexion

---

## 📱 Aperçu des écrans

| Splash | Login | Accueil |
|--------|-------|---------|
| ![](assets/images/screen_splash.png) | ![](assets/images/screen_login.png) | ![](assets/images/screen_home.png) |

| Transactions | Statistiques | Budgets |
|---|---|---|
| ![](assets/images/screen_transactions.png) | ![](assets/images/screen_stats.png) | ![](assets/images/screen_budget.png) |

---

## 🛠 Technologies utilisées

| Technologie | Version | Usage |
|---|---|---|
| **Flutter** | 3.x | Framework mobile cross-platform |
| **Dart** | 3.x | Langage de programmation |
| **sqflite** | ^2.3.0 | Base de données SQLite locale |
| **provider** | ^6.1.1 | Gestion d'état |
| **fl_chart** | ^0.66.2 | Graphiques interactifs |
| **flutter_slidable** | ^3.0.1 | Swipe actions sur les listes |
| **google_fonts** | ^6.1.0 | Typographie Poppins |
| **shared_preferences** | ^2.2.2 | Persistance de session |
| **crypto** | ^3.0.3 | Hachage SHA-256 |
| **intl** | ^0.19.0 | Formatage dates et devises |
| **uuid** | ^4.3.3 | Génération d'identifiants uniques |
| **flutter_local_notifications** | ^16.3.0 | Notifications locales |

---

## 📁 Architecture du projet
```
trackfinance/
├── lib/
│   ├── main.dart                        # Point d'entrée
│   ├── app/
│   │   ├── app.dart                     # MaterialApp + thème
│   │   └── routes.dart                  # Routes nommées
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Palette de couleurs
│   │   │   └── app_strings.dart         # Textes statiques
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Thèmes clair / sombre
│   │   └── utils/
│   │       ├── currency_formatter.dart  # Formatage devises
│   │       ├── date_formatter.dart      # Formatage dates
│   │       └── validators.dart          # Validation formulaires
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart     # Singleton SQLite + CRUD
│   │   └── models/
│   │       ├── transaction_model.dart
│   │       ├── category_model.dart
│   │       ├── budget_model.dart
│   │       └── user_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart           # Authentification locale
│   │   ├── category_provider.dart       # État des catégories
│   │   ├── transaction_provider.dart    # État des transactions
│   │   └── budget_provider.dart        # État des budgets
│   └── ui/
│       └── screens/
│           ├── splash/                  # Écran de démarrage
│           ├── auth/                    # Login + Register
│           ├── home/                    # Tableau de bord
│           ├── transactions/            # Liste + Formulaire
│           ├── statistics/              # Graphiques
│           ├── budget/                  # Budgets + Formulaire
│           ├── categories/              # Gestion catégories
│           └── profile/                 # Profil utilisateur
├── assets/
│   └── images/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Installation et lancement

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0.0
- [Android Studio](https://developer.android.com/studio) ou VS Code
- Un émulateur Android ou un appareil physique

> ⚠️ Cette application utilise **SQLite** et ne fonctionne **pas sur Chrome/Web**.
> Utilisez obligatoirement un appareil Android ou iOS.

### Étapes
```bash
# 1. Cloner le dépôt
git clone https://github.com/VOTRE_USERNAME/trackfinance.git

# 2. Se déplacer dans le répertoire
cd trackfinance

# 3. Installer les dépendances
flutter pub get

# 4. Vérifier les appareils disponibles
flutter devices

# 5. Lancer l'application sur Android
flutter run -d android
```

### Build APK de production
```bash
flutter build apk --release
# APK généré dans : build/app/outputs/flutter-apk/app-release.apk
```

---

## 🗄️ Base de données

L'application utilise **SQLite** via `sqflite` avec 3 tables :
```sql
-- Transactions financières
CREATE TABLE transactions (
  id          TEXT PRIMARY KEY,
  title       TEXT NOT NULL,
  amount      REAL NOT NULL,
  type        TEXT NOT NULL,      -- 'income' | 'expense'
  category_id TEXT NOT NULL,
  date        TEXT NOT NULL,
  note        TEXT,
  created_at  TEXT NOT NULL
);

-- Catégories de transactions
CREATE TABLE categories (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  icon       INTEGER NOT NULL,    -- codePoint Material Icon
  color      INTEGER NOT NULL,    -- valeur ARGB
  type       TEXT NOT NULL,
  is_default INTEGER DEFAULT 0
);

-- Budgets mensuels
CREATE TABLE budgets (
  id          TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  amount      REAL NOT NULL,
  spent       REAL DEFAULT 0,
  month       INTEGER NOT NULL,
  year        INTEGER NOT NULL
);
```

---

## 🔐 Sécurité

- Aucune donnée transmise sur un serveur externe
- Mot de passe haché en **SHA-256** avant stockage
- Session stockée localement via SharedPreferences
- Données SQLite stockées dans le sandbox privé de l'application

---

## 👥 Utilisateurs cibles

| Profil | Cas d'usage |
|--------|-------------|
| 🎓 Étudiants | Suivi du budget mensuel et des dépenses courantes |
| 💼 Salariés | Gestion des revenus et contrôle des dépenses |
| 🧑‍💻 Freelances | Suivi des revenus irréguliers et planification |
| 👨‍👩‍👧 Particuliers | Optimisation du budget familial |

---

## 🤝 Contribution

Les contributions sont les bienvenues !
```bash
# Créer une branche feature
git checkout -b feature/ma-fonctionnalite

# Commiter les changements
git commit -m "feat: description de la fonctionnalité"

# Pousser la branche
git push origin feature/ma-fonctionnalite

# Ouvrir une Pull Request sur GitHub
```

---

## 📄 Licence

Ce projet est sous licence **MIT**.  
Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">
  <p>Développé avec ❤️ à Libreville, Gabon</p>
  <p>
    <strong>TrackFinance</strong> · ESITECH · L3 Développement · 2025
  </p>
</div>
