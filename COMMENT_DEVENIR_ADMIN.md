# 🔑 COMMENT DEVENIR ADMIN - EventMate

## Pour Vous et Votre Équipe

---

## 🎯 OBJECTIF

Faire de vous et votre équipe des administrateurs dans l'application EventMate en production (Firebase).

---

## 📋 MÉTHODE 1 : FIREBASE CONSOLE (RECOMMANDÉE)

### Étape 1 : Créer vos comptes
1. Ouvrir l'application EventMate
2. Cliquer sur "S'inscrire"
3. Créer un compte avec votre email réel
4. Répéter pour chaque membre de l'équipe

### Étape 2 : Accéder à Firebase Console
1. Aller sur : https://console.firebase.google.com/
2. Sélectionner votre projet EventMate
3. Cliquer sur **Firestore Database** dans le menu

### Étape 3 : Modifier le rôle en admin
1. Dans Firestore, aller dans la collection **users**
2. Trouver votre document utilisateur (par email)
3. Cliquer sur le document
4. Trouver le champ **role**
5. Changer la valeur de `"user"` à `"admin"`
6. Cliquer sur **Mettre à jour**

### Étape 4 : Vérifier
1. Se déconnecter de l'application
2. Se reconnecter
3. Aller sur Profil
4. Le bouton "Administration" devrait apparaître ✅

---

## 📋 MÉTHODE 2 : SCRIPT AUTOMATIQUE

### Créer un script pour promouvoir en admin

Créez ce fichier : `promote_to_admin.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Liste des emails de votre équipe
const ADMIN_EMAILS = [
  'votre.email@example.com',
  'membre1@example.com',
  'membre2@example.com',
  // Ajoutez tous les membres de votre équipe
];

Future<void> main() async {
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  print('🔄 Promotion des admins en cours...\n');
  
  for (String email in ADMIN_EMAILS) {
    try {
      // Chercher l'utilisateur par email
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        print('❌ Utilisateur non trouvé: $email');
        continue;
      }
      
      // Mettre à jour le rôle
      final userId = querySnapshot.docs.first.id;
      await firestore.collection('users').doc(userId).update({
        'role': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ $email est maintenant admin');
    } catch (e) {
      print('❌ Erreur pour $email: $e');
    }
  }
  
  print('\n✅ Promotion terminée !');
}
```

### Exécuter le script
```bash
dart run promote_to_admin.dart
```

---

## 📋 MÉTHODE 3 : LORS DE L'INSCRIPTION

### Modifier le service d'authentification

Dans `lib/data/services/auth_service.dart`, modifiez la fonction d'inscription :

```dart
// Liste des emails admin (à définir)
static const ADMIN_EMAILS = [
  'votre.email@example.com',
  'membre1@example.com',
  'membre2@example.com',
];

Future<UserModel> createUserWithEmailAndPassword({
  required String email,
  required String password,
  required String displayName,
}) async {
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = userCredential.user!;
  
  // Déterminer le rôle en fonction de l'email
  String role = 'user';
  if (ADMIN_EMAILS.contains(email.toLowerCase())) {
    role = 'admin';
  }

  final userModel = UserModel(
    id: user.uid,
    email: email,
    firstName: displayName.split(' ').first,
    lastName: displayName.split(' ').length > 1 
        ? displayName.split(' ').last 
        : '',
    role: role, // ⭐ Rôle automatique
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await _firestore.collection('users').doc(user.uid).set(
    userModel.toFirestore(),
  );

  return userModel;
}
```

---

## 📋 MÉTHODE 4 : PAGE D'ADMINISTRATION

### Créer une fonction de promotion dans l'admin

Dans `lib/features/admin/admin_page.dart`, ajoutez :

```dart
// Fonction pour promouvoir un utilisateur
Future<void> _promoteUserToAdmin(String email) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      throw Exception('Utilisateur non trouvé');
    }
    
    final userId = querySnapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'role': 'admin',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ $email est maintenant admin');
  } catch (e) {
    print('❌ Erreur: $e');
    rethrow;
  }
}

// Ajouter un bouton dans l'interface
ElevatedButton(
  onPressed: () {
    // Afficher un dialog pour entrer l'email
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Promouvoir en Admin'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Email de l\'utilisateur',
          ),
          onSubmitted: (email) {
            Navigator.pop(context);
            _promoteUserToAdmin(email);
          },
        ),
      ),
    );
  },
  child: Text('Promouvoir un utilisateur'),
)
```

---

## 🎯 RECOMMANDATION POUR VOTRE ÉQUIPE

### Configuration Initiale (À faire maintenant)

1. **Créez vos comptes** dans l'application
   - Vous
   - Chaque membre de l'équipe

2. **Notez les emails** utilisés

3. **Utilisez la Méthode 1** (Firebase Console)
   - Rapide
   - Sûr
   - Pas de code à modifier

4. **Vérifiez** que ça marche

### Pour la Présentation

Créez un compte spécial pour la démo :
```
Email: demo-admin@eventmate.gn
Password: DemoAdmin123!
Rôle: admin
```

---

## 📝 LISTE DE VOTRE ÉQUIPE

Remplissez cette liste avec les emails de votre équipe :

```
ADMINS EVENTMATE
================

1. Vous:          ________________________@_______
   Rôle: admin    ✅

2. Membre 1:      ________________________@_______
   Rôle: admin    ✅

3. Membre 2:      ________________________@_______
   Rôle: admin    ✅

4. Membre 3:      ________________________@_______
   Rôle: admin    ✅

5. Membre 4:      ________________________@_______
   Rôle: admin    ✅
```

---

## ⚠️ SÉCURITÉ IMPORTANTE

### À FAIRE
- ✅ Utilisez des emails réels de votre équipe
- ✅ Mots de passe forts (min 8 caractères)
- ✅ Notez les identifiants en lieu sûr
- ✅ Ne partagez pas les accès admin

### À NE PAS FAIRE
- ❌ Ne mettez pas d'emails publics en admin
- ❌ Ne hardcodez pas les mots de passe
- ❌ Ne donnez pas l'accès admin à tout le monde
- ❌ Ne publiez pas les emails admin sur GitHub

---

## 🚀 PROCÉDURE RAPIDE (5 MINUTES)

### Pour vous rendre admin MAINTENANT :

1. **Ouvrir Firebase Console**
   ```
   https://console.firebase.google.com/
   ```

2. **Sélectionner votre projet**

3. **Firestore Database → users**

4. **Trouver votre document** (par email)

5. **Modifier le champ `role`**
   ```
   Avant: "user"
   Après: "admin"
   ```

6. **Sauvegarder**

7. **Tester dans l'app**
   - Se déconnecter
   - Se reconnecter
   - Profil → Bouton "Administration" visible ✅

---

## 🎓 POUR LA PRÉSENTATION DEMAIN

### Comptes à préparer :

1. **Votre compte personnel** (admin)
   - Pour montrer que vous êtes le créateur

2. **Compte démo utilisateur**
   - Email: demo@eventmate.gn
   - Rôle: user
   - Pour montrer le parcours utilisateur

3. **Compte démo admin**
   - Email: admin@eventmate.gn
   - Rôle: admin
   - Pour montrer les fonctions admin

---

## 💡 ASTUCE PRO

### Créer un fichier de configuration

Créez : `lib/core/admin_config.dart`

```dart
/// Configuration des administrateurs
class AdminConfig {
  // Liste des emails admin (à ne PAS commiter sur GitHub)
  static const List<String> ADMIN_EMAILS = [
    // Ajoutez vos emails ici
    // 'votre.email@example.com',
  ];
  
  /// Vérifie si un email est admin
  static bool isAdminEmail(String email) {
    return ADMIN_EMAILS.contains(email.toLowerCase());
  }
  
  /// Obtient le rôle en fonction de l'email
  static String getRoleForEmail(String email) {
    if (isAdminEmail(email)) {
      return 'admin';
    }
    return 'user';
  }
}
```

Puis dans `.gitignore`, ajoutez :
```
lib/core/admin_config.dart
```

---

## ✅ CHECKLIST FINALE

- [ ] Comptes créés pour toute l'équipe
- [ ] Rôles modifiés en "admin" dans Firebase
- [ ] Vérification : bouton admin visible
- [ ] Accès à la page admin fonctionne
- [ ] Comptes de démo préparés
- [ ] Emails notés en lieu sûr

---

<div align="center">

**🔑 Vous et votre équipe êtes maintenant admins !**

*N'oubliez pas de sécuriser vos accès*

</div>
