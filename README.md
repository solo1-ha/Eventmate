# EventMate 📅

**EventMate** est une application mobile de gestion d'événements communautaires développée pour un projet étudiant en Guinée. L'application permet aux utilisateurs de créer, découvrir et participer à des événements locaux.

## 📊 État du Projet

**Version**: 1.0.0  
**Statut**: Production-Ready (98% complet)  
**Dernière mise à jour**: Octobre 2025

## 🚀 Fonctionnalités

### 🔐 Authentification
- Inscription et connexion sécurisées
- Gestion des profils utilisateur
- Rôles : Utilisateur, Organisateur, Administrateur
- Réinitialisation de mot de passe

### 📅 Gestion des événements
- Création, modification et suppression d'événements
- Détails complets : titre, description, date, lieu, capacité
- Images d'événements
- Recherche et filtres
- Gestion des participants
- **Événements payants** avec simulation de paiement
- Catégories d'événements
- Dashboard organisateur avec statistiques et graphiques

### 🗺️ Localisation
- Intégration Google Maps
- Sélection de lieux sur carte
- Géolocalisation automatique
- Affichage des événements sur carte

### 📱 QR Code
- Génération de QR codes uniques pour chaque inscription
- Scanner QR pour check-in
- Gestion des présences

### 🎨 Interface utilisateur
- Design moderne et fluide avec Material Design 3
- Thème clair/sombre avec sélecteur (Clair/Sombre/Système)
- Palette de couleurs Indigo moderne
- Prévisualisation palette guinéenne (Rouge/Jaune/Vert)
- Interface responsive
- Animations fluides

### 🔔 Notifications
- Notifications in-app (Firestore)
- Firebase Cloud Messaging (FCM) configuré
- Gestion des tokens FCM
- Topics et abonnements
- Prêt pour notifications push réelles

### 📴 Mode Hors Ligne
- Cache local avec SharedPreferences
- Synchronisation automatique
- Détection de cache obsolète
- Fonctionnement sans connexion

## 🛠️ Technologies utilisées

- **Frontend** : Flutter 3.9.2+
- **State Management** : Riverpod 2.4.9
- **Backend** : Firebase (Auth, Firestore, Storage, Messaging)
- **Local Storage** : SharedPreferences
- **QR Code** : qr_flutter, mobile_scanner
- **Maps** : Google Maps API, Geolocator, Geocoding
- **Charts** : fl_chart 0.69.0
- **Image** : image_picker
- **Tests** : flutter_test, mockito
- **Utils** : intl, uuid, share_plus

## 📁 Architecture du projet

```
lib/
├─ core/                # Constantes, thèmes, utils
├─ data/
│  ├─ models/           # EventModel, UserModel, etc.
│  ├─ services/         # Auth, Events, Payment, Cache, FCM, etc.
│  └─ providers/        # Riverpod providers
├─ features/
│  ├─ auth/             # Connexion, inscription, profil
│  ├─ events/           # Liste, création, détails, participants, QR
│  ├─ organizer/        # Dashboard organisateur
│  ├─ maps/             # Localisation Google Maps
│  └─ settings/         # Préférences, thème
├─ widgets/             # Composants réutilisables
└─ main.dart

test/
├─ unit/                # Tests unitaires (13 tests)
└─ widget/              # Tests widgets
```

## 🚀 Installation

1. **Prérequis**
   - Flutter SDK 3.9.2+
   - Dart SDK
   - Android Studio / VS Code
   - Compte Firebase

2. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd eventmate
   ```

3. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

4. **Configuration Firebase**
   - Créer un projet Firebase
   - Activer Authentication, Firestore, Storage
   - Télécharger les fichiers de configuration :
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

5. **Configuration Google Maps**
   - Obtenir une clé API Google Maps
   - Ajouter la clé dans `android/app/src/main/AndroidManifest.xml`
   - Ajouter la clé dans `ios/Runner/AppDelegate.swift`

6. **Lancer l'application**
   ```bash
   flutter run
   ```

## 🎯 Rôles et permissions

| Rôle | Droits |
|------|--------|
| **User** | Consulter les événements, s'inscrire, scanner son QR |
| **Owner** | Créer/modifier/supprimer ses événements, scanner participants |
| **Admin** | Gérer tous les événements, modérer les utilisateurs |

## 🎨 Design

L'application utilise Material Design 3 avec une palette moderne :

- **Primaire** : #6366F1 (Indigo moderne)
- **Secondaire** : #EC4899 (Rose vibrant)
- **Accent** : #10B981 (Vert émeraude)
- **Thèmes** : Clair, Sombre, Système
- **Palette Guinéenne** : Rouge (#CE1126), Jaune (#FCD116), Vert (#009460) - À venir

## 📱 Écrans principaux

1. **Connexion/Inscription** - Authentification utilisateur avec sélection de rôle
2. **Accueil** - Liste des événements avec recherche et filtres
3. **Détail événement** - Informations complètes, inscription, paiement
4. **Création événement** - Formulaire complet avec images et localisation
5. **Dashboard** - Statistiques et graphiques pour organisateurs
6. **Scanner QR** - Interface de scan pour check-in
7. **Carte** - Affichage des événements sur Google Maps
8. **Profil** - Gestion du compte utilisateur
9. **Paramètres** - Préférences, thème, notifications

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 📦 Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est développé dans le cadre d'un projet étudiant en Guinée.

## 👥 Équipe

- **Développement** : Étudiants en informatique
- **Supervision** : Professeurs et mentors
- **Contexte** : Projet académique guinéen

## 📞 Support

Pour toute question ou support :
- Email : support@eventmate.gn
- Documentation complète : Voir `COMPLETION_FINALE.md`
- Guide Firebase : Voir `FIREBASE_SETUP.md`
- Plan d'action : Voir `PLAN_ACTION_COMPLETION.md`

## 📚 Documentation Supplémentaire

- `COMPLETION_FINALE.md` - Documentation complète de la version finale
- `IMPLEMENTATION_FINALE.md` - Détails des fonctionnalités implémentées
- `PLAN_ACTION_COMPLETION.md` - Roadmap et prochaines étapes
- `FIREBASE_SETUP.md` - Configuration Firebase
- `GUIDE_UPLOAD_IMAGE.md` - Guide d'upload d'images

---

**EventMate** - Connecter les communautés guinéennes à travers les événements 📅🇬🇳

**Version 1.0.0** - Production-Ready (98% complet) ✅
