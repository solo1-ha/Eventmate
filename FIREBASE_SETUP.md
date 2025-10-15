# Configuration Firebase pour EventMate

## ✅ Firebase Intégré!

L'application utilise maintenant **Firebase** pour l'authentification et le stockage des données.

## ⚠️ Configuration Requise

L'application nécessite une configuration Firebase pour fonctionner. Suivez les étapes ci-dessous :

## Option 1 : Utiliser FlutterFire CLI (Recommandé)

### 1. Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Se connecter à Firebase

```bash
firebase login
```

### 3. Configurer Firebase pour le projet

```bash
flutterfire configure
```

Cette commande va :
- Vous demander de sélectionner ou créer un projet Firebase
- Générer automatiquement le fichier `lib/firebase_options.dart` avec vos vraies clés
- Configurer Firebase pour toutes les plateformes (Web, Android, iOS)

### 4. Relancer l'application

```bash
flutter run
```

---

## Option 2 : Configuration Manuelle

Si vous ne pouvez pas utiliser FlutterFire CLI, suivez ces étapes :

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez les services suivants :
   - **Authentication** (Email/Password)
   - **Cloud Firestore**
   - **Storage**

### 2. Ajouter une application Web

1. Dans Firebase Console, cliquez sur l'icône Web `</>`
2. Enregistrez votre application (nom : EventMate)
3. Copiez la configuration Firebase qui ressemble à :

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

### 3. Mettre à jour `lib/firebase_options.dart`

Ouvrez le fichier `lib/firebase_options.dart` et remplacez les valeurs dans la section `web` :

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'VOTRE_API_KEY',              // Remplacer
  appId: 'VOTRE_APP_ID',                // Remplacer
  messagingSenderId: 'VOTRE_SENDER_ID', // Remplacer
  projectId: 'VOTRE_PROJECT_ID',        // Remplacer
  authDomain: 'VOTRE_PROJECT_ID.firebaseapp.com',
  storageBucket: 'VOTRE_PROJECT_ID.appspot.com',
);
```

### 4. Configuration Android (Optionnel)

1. Dans Firebase Console, ajoutez une application Android
2. Téléchargez `google-services.json`
3. Placez-le dans `android/app/google-services.json`
4. Mettez à jour la section `android` dans `firebase_options.dart`

### 5. Configuration iOS (Optionnel)

1. Dans Firebase Console, ajoutez une application iOS
2. Téléchargez `GoogleService-Info.plist`
3. Placez-le dans `ios/Runner/GoogleService-Info.plist`
4. Mettez à jour la section `ios` dans `firebase_options.dart`

---

## Vérification

Après la configuration, relancez l'application :

```bash
flutter run
```

L'erreur `FirebaseOptions cannot be null` devrait disparaître.

---

## Configuration Firestore

Une fois Firebase configuré, créez les règles de sécurité Firestore :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour les événements
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.ownerId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Règles pour les utilisateurs
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Règles pour les inscriptions
    match /registrations/{registrationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Support

Pour plus d'informations :
- [Documentation Firebase](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
