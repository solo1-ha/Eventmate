# 🚀 Démarrage Rapide - Firebase

## ✅ Firebase est Intégré!

Le code Firebase est déjà en place. Il ne reste plus qu'à configurer vos clés.

## 📋 Étapes Rapides

### 1️⃣ Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2️⃣ Se Connecter à Firebase

```bash
firebase login
```

Si vous n'avez pas Firebase CLI installé:
```bash
npm install -g firebase-tools
```

### 3️⃣ Configurer le Projet

```bash
flutterfire configure
```

Cette commande va:
- ✅ Créer ou sélectionner un projet Firebase
- ✅ Générer automatiquement `lib/firebase_options.dart` avec vos vraies clés
- ✅ Configurer Web, Android et iOS

### 4️⃣ Activer les Services Firebase

Allez sur [Firebase Console](https://console.firebase.google.com/):

1. **Authentication**
   - Cliquez sur "Authentication" dans le menu
   - Onglet "Sign-in method"
   - Activez "Email/Password"

2. **Cloud Firestore**
   - Cliquez sur "Firestore Database"
   - Créez une base de données
   - Mode: **Test** (pour commencer)
   - Région: Choisissez la plus proche

3. **Storage** (Optionnel)
   - Cliquez sur "Storage"
   - Commencer

### 5️⃣ Configurer les Règles Firestore

Dans Firebase Console → Firestore → Rules, copiez-collez:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Utilisateurs
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Événements
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.organizerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Inscriptions
    match /registrations/{registrationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

Cliquez sur **Publier**.

### 6️⃣ Lancer l'Application

```bash
flutter run
```

## 🎯 Créer un Compte Test

1. Lancez l'application
2. Cliquez sur "S'inscrire"
3. Remplissez le formulaire:
   - Email: `test@eventmate.com`
   - Mot de passe: `test123456`
   - Prénom: `Test`
   - Nom: `User`
4. Cliquez sur "S'inscrire"

Votre premier utilisateur sera créé dans Firebase! 🎉

## 🔍 Vérifier dans Firebase Console

1. **Authentication** → Users
   - Vous devriez voir votre utilisateur test

2. **Firestore Database** → Data
   - Collection `users` avec votre document utilisateur

## ⚠️ Problèmes Courants

### Erreur: "Firebase options cannot be null"
➡️ Vous n'avez pas exécuté `flutterfire configure`

### Erreur: "Permission denied"
➡️ Vérifiez les règles Firestore (étape 5)

### Erreur: "Email already in use"
➡️ Utilisez un autre email ou supprimez l'utilisateur dans Firebase Console

## 📱 Tester sur Web

```bash
flutter run -d chrome
```

Firebase fonctionne parfaitement sur le web! 🌐

## 🎨 Fonctionnalités Disponibles

Avec Firebase activé, vous pouvez maintenant:

- ✅ **S'inscrire** avec email/mot de passe
- ✅ **Se connecter** 
- ✅ **Mettre à jour le profil**
- ✅ **Se déconnecter**
- ✅ **Réinitialiser le mot de passe**
- ⏳ **Créer des événements** (à implémenter)
- ⏳ **S'inscrire aux événements** (à implémenter)

## 📚 Prochaines Étapes

1. Créer le service pour les événements
2. Créer le service pour les inscriptions
3. Ajouter le upload d'images avec Storage
4. Implémenter les notifications

## 🆘 Besoin d'Aide?

- [Documentation Firebase](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- Consultez `FIREBASE_SETUP.md` pour plus de détails

---

**Bon développement! 🚀**
