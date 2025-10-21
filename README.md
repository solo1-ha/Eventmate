# 🎉 EventMate - Plateforme de Gestion d'Événements

> Application web complète de gestion d'événements avec système de tickets, QR codes et paiements intégrés

## 📊 Informations du Projet

**Version**: 1.0.0  
**Statut**: ✅ Production Ready  
**Date**: Octobre 2025  
**Contexte**: Projet de Fin de Formation

## ✨ Fonctionnalités Principales

### 🎫 Système de Tickets Avancé
- **Achat de plusieurs tickets** (1 à 10 personnes)
- **Ajout des noms des participants**
- **Génération automatique de QR codes** uniques
- **Design professionnel** des tickets
- **Affichage immédiat** après inscription
- **Partage de tickets**
- **Accès depuis le profil** utilisateur

### 🔐 Authentification & Sécurité
- Connexion/Inscription sécurisée (Firebase Auth)
- Gestion des profils utilisateur
- Rôles : Utilisateur, Organisateur, Administrateur
- **Protection contre les inscriptions invalides** :
  - ✅ Fermeture automatique pour événements passés
  - ✅ Interdiction pour l'organisateur de s'inscrire
  - ✅ Vérification de la capacité disponible
  - ✅ Protection contre les inscriptions multiples

### 📅 Gestion Complète des Événements
- Création, modification et suppression
- Upload d'images
- **Types de tickets multiples** (VIP, Standard, etc.)
- **Événements gratuits ou payants**
- Gestion de la capacité
- Dashboard organisateur avec statistiques
- **Détection automatique des événements passés**

### 💳 Système de Paiement
- **Paiement Orange Money** (simulation)
- **Calcul automatique** du prix total
- Support de plusieurs tickets en un paiement
- Historique des transactions

### 📱 Scanner QR Code
- Scan des tickets pour check-in
- Validation en temps réel
- Gestion des scanners autorisés
- Historique des présences

### 🗺️ Géolocalisation
- Carte interactive des événements
- Sélection de lieu sur carte
- Affichage des événements à proximité

### 🎨 Interface Moderne
- Design Material Design 3
- Navigation à 5 onglets
- Animations fluides
- Responsive (mobile & desktop)

## 🛠️ Stack Technique

### Frontend
- **Flutter Web** - Framework de développement
- **Dart** - Langage de programmation
- **Material Design 3** - Design system
- **Riverpod** - Gestion d'état

### Backend & Services
- **Firebase Authentication** - Gestion des utilisateurs
- **Cloud Firestore** - Base de données NoSQL temps réel
- **Firebase Storage** - Stockage des images
- **Firebase Cloud Messaging** - Notifications

### Fonctionnalités Techniques
- **QR Code** : qr_flutter, mobile_scanner
- **Géolocalisation** : geolocator, geocoding
- **Paiement** : Intégration Orange Money (simulation)
- **Images** : image_picker, cached_network_image
- **Utils** : intl, uuid, share_plus

## 📁 Architecture

```
lib/
├─ core/                    # Configuration, constantes, thèmes
├─ data/
│  ├─ models/               # EventModel, UserModel, RegistrationModel, etc.
│  ├─ services/             # Auth, Events, Inscriptions, Payment
│  └─ providers/            # Riverpod state management
├─ features/
│  ├─ auth/                 # Authentification
│  ├─ events/               # Gestion des événements
│  ├─ organizer/            # Dashboard organisateur
│  └─ maps/                 # Carte et géolocalisation
├─ widgets/                 # Composants réutilisables
│  ├─ inscription_button.dart
│  ├─ event_ticket_screen.dart
│  ├─ ticket_quantity_dialog.dart
│  └─ ...
└─ main.dart
```

## 🚀 Installation & Lancement

### Prérequis
- Flutter SDK 3.9.2+
- Compte Firebase
- Navigateur Chrome (pour la version web)

### Installation

```bash
# 1. Cloner le projet
git clone <repository-url>
cd eventmate

# 2. Installer les dépendances
flutter pub get

# 3. Lancer sur Chrome
flutter run -d chrome
```

### Configuration Firebase

1. Créer un projet sur [Firebase Console](https://console.firebase.google.com/)
2. Activer les services :
   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
3. Déployer les règles Firestore :
   ```bash
   firebase deploy --only firestore:rules
   ```

## 🎯 Cas d'Usage

### Pour les Utilisateurs
1. **Découvrir des événements** - Parcourir, rechercher, filtrer
2. **S'inscrire** - Acheter des tickets (1 à 10 personnes)
3. **Payer** - Orange Money (simulation)
4. **Recevoir son ticket** - QR code automatique
5. **Participer** - Présenter le QR code à l'entrée

### Pour les Organisateurs
1. **Créer un événement** - Gratuit ou payant
2. **Gérer les inscriptions** - Voir les participants
3. **Scanner les tickets** - Check-in avec QR code
4. **Suivre les statistiques** - Dashboard complet

## 🎨 Innovations & Points Forts

### 1. Achat Multiple de Tickets
Possibilité d'acheter pour plusieurs personnes en une seule transaction avec ajout des noms des participants.

### 2. Gestion Intelligente des Événements Passés
- Détection automatique des événements terminés
- Bouton désactivé avec message "Événement terminé"
- Protection côté serveur contre les inscriptions invalides

### 3. Système de Tickets Professionnel
- Design moderne avec QR code haute résolution
- Affichage immédiat après inscription
- Partage facile
- Accessible depuis le profil

### 4. Sécurité Robuste
- Règles Firestore strictes
- Validation côté client et serveur
- Protection contre les abus

## 📱 Navigation

### 5 Onglets Principaux

1. **📅 Événements** - Découverte et recherche
2. **🗺️ Carte** - Géolocalisation des événements
3. **🎪 Mes Événements** - Événements créés (organisateurs)
4. **📱 Scanner** - Check-in des participants
5. **👤 Profil** - Compte utilisateur et tickets

## 📊 Statistiques

- **Lignes de code** : ~5000+
- **Fichiers Dart** : 50+
- **Widgets personnalisés** : 25+
- **Modèles de données** : 6
- **Services** : 5
- **Pages** : 15+

## 🎓 Compétences Démontrées

### Techniques
- ✅ Développement Flutter/Dart
- ✅ Architecture MVC/MVVM
- ✅ Gestion d'état (Riverpod)
- ✅ Base de données NoSQL (Firestore)
- ✅ Authentification et sécurité
- ✅ Intégration de services cloud
- ✅ Génération de QR codes
- ✅ Géolocalisation

### Fonctionnelles
- ✅ Analyse des besoins
- ✅ Conception d'architecture
- ✅ Développement full-stack
- ✅ Tests et débogage
- ✅ Documentation

## 📈 Évolutions Futures

### Court Terme
- Notifications push réelles
- Système de favoris
- Recherche avancée
- Filtres multiples

### Moyen Terme
- Application mobile native
- Paiement Orange Money réel
- Chat entre participants
- Recommandations personnalisées

### Long Terme
- IA pour suggestions d'événements
- Analytics avancés
- Programme de fidélité
- API publique

## 👨‍💻 Auteur

**Projet de Fin de Formation**  
Octobre 2025

## 📄 Licence

Projet académique - Tous droits réservés

---

<div align="center">

### 🎉 EventMate - Gérez vos événements en toute simplicité

**Version 1.0.0** | **Production Ready** ✅

*Développé avec ❤️ en Flutter*

</div>
