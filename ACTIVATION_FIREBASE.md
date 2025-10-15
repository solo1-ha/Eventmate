# ✅ Activation des Services Firebase

## 🎉 Configuration Terminée!

Vos clés Firebase sont maintenant configurées dans `lib/firebase_options.dart`.

## 🔥 Prochaines Étapes - Activer les Services

### 1️⃣ Activer Authentication (Email/Password)

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet **"eventmate-61924"**
3. Dans le menu de gauche, cliquez sur **"Authentication"**
4. Cliquez sur **"Get started"** (si c'est la première fois)
5. Onglet **"Sign-in method"**
6. Cliquez sur **"Email/Password"**
7. **Activez** le premier interrupteur (Email/Password)
8. Cliquez sur **"Save"**

✅ **Authentication activé!**

---

### 2️⃣ Créer Cloud Firestore

1. Dans le menu de gauche, cliquez sur **"Firestore Database"**
2. Cliquez sur **"Create database"**
3. Sélectionnez le mode:
   - **"Start in test mode"** (pour le développement)
   - ⚠️ Les données seront accessibles pendant 30 jours
4. Choisissez la région:
   - **"europe-west1"** (Belgique) - Recommandé pour l'Europe
   - Ou la région la plus proche de vous
5. Cliquez sur **"Enable"**

✅ **Firestore créé!**

---

### 3️⃣ Configurer les Règles de Sécurité Firestore

1. Dans Firestore Database, cliquez sur l'onglet **"Rules"**
2. Remplacez le contenu par:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Collection des utilisateurs
    match /users/{userId} {
      // Tout le monde peut lire les profils publics
      allow read: if request.auth != null;
      // Seul le propriétaire peut modifier son profil
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Collection des événements
    match /events/{eventId} {
      // Tout le monde peut lire les événements
      allow read: if request.auth != null;
      // Tout utilisateur connecté peut créer un événement
      allow create: if request.auth != null;
      // Seul l'organisateur ou un admin peut modifier/supprimer
      allow update, delete: if request.auth != null && 
        (resource.data.organizerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Collection des inscriptions aux événements
    match /registrations/{registrationId} {
      // Tout le monde peut lire les inscriptions
      allow read: if request.auth != null;
      // Tout utilisateur peut s'inscrire
      allow create: if request.auth != null;
      // Seul l'utilisateur inscrit peut se désinscrire
      allow delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Cliquez sur **"Publish"**

✅ **Règles de sécurité configurées!**

---

### 4️⃣ (Optionnel) Activer Storage

Pour les images d'événements et photos de profil:

1. Dans le menu de gauche, cliquez sur **"Storage"**
2. Cliquez sur **"Get started"**
3. Sélectionnez **"Start in test mode"**
4. Choisissez la même région que Firestore
5. Cliquez sur **"Done"**

✅ **Storage activé!**

---

## 🚀 Tester l'Application

Maintenant que Firebase est configuré, lancez l'application:

```bash
flutter run -d chrome
```

### Créer un Compte Test

1. L'application va démarrer sur la page de connexion
2. Cliquez sur **"S'inscrire"**
3. Remplissez le formulaire:
   - **Email**: `test@eventmate.com`
   - **Mot de passe**: `test123456`
   - **Prénom**: `Test`
   - **Nom**: `User`
4. Cliquez sur **"S'inscrire"**

### Vérifier dans Firebase Console

1. **Authentication** → **Users**
   - Vous devriez voir votre utilisateur test

2. **Firestore Database** → **Data**
   - Collection `users` avec un document contenant vos infos

---

## 🎯 Résumé

✅ Clés Firebase configurées
✅ Authentication Email/Password activé
✅ Cloud Firestore créé
✅ Règles de sécurité configurées
✅ Application prête à être testée

---

## 📝 Liens Utiles

- **Votre projet**: https://console.firebase.google.com/project/eventmate-61924
- **Authentication**: https://console.firebase.google.com/project/eventmate-61924/authentication/users
- **Firestore**: https://console.firebase.google.com/project/eventmate-61924/firestore

---

## 🆘 Problèmes?

### Erreur "Permission denied"
➡️ Vérifiez que les règles Firestore sont bien publiées (étape 3)

### Erreur "User not found"
➡️ Vérifiez que Authentication Email/Password est activé (étape 1)

### Erreur "Network error"
➡️ Vérifiez votre connexion internet et que Firebase est bien accessible

---

**Bon développement! 🎉**
