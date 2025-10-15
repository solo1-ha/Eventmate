# 🚀 EventMate - Guide de Démarrage Rapide

## ⚡ Installation en 5 Minutes

### 1. Installer les Dépendances
```bash
cd eventmate
flutter pub get
```

### 2. Lancer l'Application
```bash
flutter run
```

C'est tout! L'application fonctionne en mode production avec Firebase.

---

## 📱 Utilisation Rapide

### Créer un Compte
1. Ouvrir l'app
2. Cliquer sur "S'inscrire"
3. Remplir le formulaire
4. Choisir un rôle (Utilisateur ou Organisateur)
5. Se connecter

### Créer un Événement (Organisateur)
1. Se connecter en tant qu'Organisateur
2. Aller dans "Dashboard" (icône tableau de bord)
3. Cliquer sur "+" ou "Créer un événement"
4. Remplir les informations
5. Choisir gratuit ou payant
6. Ajouter une image (optionnel)
7. Sélectionner le lieu sur la carte
8. Publier

### S'inscrire à un Événement (Utilisateur)
1. Parcourir les événements dans "Événements"
2. Cliquer sur un événement
3. Voir les détails
4. Cliquer sur "S'inscrire"
5. Si payant, effectuer le paiement (simulation)
6. Recevoir le QR code

### Scanner un QR Code (Organisateur)
1. Aller dans "Scanner"
2. Autoriser la caméra
3. Scanner le QR code du participant
4. Valider la présence

---

## 🎨 Personnalisation

### Changer le Thème
1. Aller dans "Profil" → "Paramètres"
2. Section "Apparence"
3. Cliquer sur "Thème"
4. Choisir : Clair, Sombre, ou Système

### Palette de Couleurs
1. Dans "Paramètres" → "Apparence"
2. Cliquer sur "Palette de couleurs"
3. Voir les options disponibles

---

## 📊 Dashboard Organisateur

### Accéder au Dashboard
1. Se connecter en tant qu'Organisateur
2. Cliquer sur l'onglet "Dashboard" en bas

### Fonctionnalités
- **Statistiques globales** : Nombre d'événements, participants, revenus
- **Graphique participants** : Visualisation par événement
- **Graphique revenus** : Répartition des revenus (si événements payants)
- **Liste des événements** : Tous vos événements créés

---

## 🔔 Notifications

### Activer les Notifications
Les notifications sont automatiquement activées lors de la connexion.

### Types de Notifications
- Inscription confirmée
- Nouvelle inscription (pour organisateurs)
- Événement à venir (rappel)
- Modification d'événement
- Annulation d'événement

---

## 🗺️ Carte Interactive

### Voir les Événements sur la Carte
1. Aller dans l'onglet "Carte"
2. Voir tous les événements avec des marqueurs
3. Cliquer sur un marqueur pour voir les détails
4. Utiliser la géolocalisation pour voir les événements proches

---

## 💰 Événements Payants

### Créer un Événement Payant
1. Lors de la création, cocher "Événement payant"
2. Entrer le prix
3. Choisir la devise (GNF, USD, EUR)
4. Publier

### Acheter un Ticket
1. S'inscrire à un événement payant
2. Choisir le mode de paiement :
   - Mobile Money
   - Carte bancaire
   - Cash (à payer sur place)
3. Confirmer le paiement (simulation)
4. Recevoir le ticket avec QR code

---

## 📴 Mode Hors Ligne

### Fonctionnement
- Les événements sont automatiquement mis en cache
- Vous pouvez consulter les événements sans connexion
- Les données se synchronisent automatiquement à la reconnexion

### Vider le Cache
1. Aller dans "Paramètres"
2. Section "Stockage" (à venir)
3. Cliquer sur "Vider le cache"

---

## 🧪 Tests

### Lancer les Tests
```bash
# Tests unitaires
flutter test test/unit/

# Tous les tests
flutter test

# Avec couverture
flutter test --coverage
```

---

## 🔧 Dépannage

### L'app ne démarre pas
```bash
flutter clean
flutter pub get
flutter run
```

### Erreur Firebase
1. Vérifier que `google-services.json` est présent dans `android/app/`
2. Vérifier que `GoogleService-Info.plist` est présent dans `ios/Runner/`
3. Relancer : `flutter run`

### Erreur Google Maps
1. Vérifier la clé API dans `AndroidManifest.xml`
2. Activer Google Maps API dans Google Cloud Console
3. Relancer l'app

### Erreur de Build
```bash
# Android
cd android
./gradlew clean
cd ..
flutter run

# iOS
cd ios
pod install
cd ..
flutter run
```

---

## 📦 Build Production

### Android APK
```bash
flutter build apk --release
# Fichier: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Fichier: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Ouvrir avec Xcode pour soumettre à l'App Store
```

---

## 🔑 Comptes de Test

### Utilisateur Standard
- Email: user@test.com
- Mot de passe: test123
- Rôle: Utilisateur

### Organisateur
- Email: organizer@test.com
- Mot de passe: test123
- Rôle: Organisateur

**Note**: Ces comptes doivent être créés manuellement dans l'app.

---

## 📚 Documentation Complète

Pour plus de détails, consultez :
- `COMPLETION_FINALE.md` - Documentation complète
- `README.md` - Vue d'ensemble du projet
- `FIREBASE_SETUP.md` - Configuration Firebase
- `PLAN_ACTION_COMPLETION.md` - Roadmap

---

## 💡 Astuces

### Raccourcis Utiles
- **Hot Reload** : `r` dans le terminal
- **Hot Restart** : `R` dans le terminal
- **Ouvrir DevTools** : `v` dans le terminal
- **Quitter** : `q` dans le terminal

### Développement Efficace
1. Utiliser le hot reload pour les changements UI
2. Utiliser le hot restart pour les changements de logique
3. Tester sur plusieurs appareils (Android/iOS)
4. Vérifier les logs pour les erreurs

### Bonnes Pratiques
- Toujours tester avant de commit
- Utiliser des noms de variables descriptifs
- Commenter le code complexe
- Suivre l'architecture existante

---

## 🆘 Besoin d'Aide?

- **Email** : support@eventmate.gn
- **Documentation** : Voir les fichiers `.md` dans le projet
- **Issues** : Créer une issue sur le repository

---

**EventMate** - Gestion d'événements simplifiée 📅✨
