# 🔒 SÉCURITÉ ADMIN - EventMate

## Système de Rôles Implémenté

---

## 📋 RÔLES DISPONIBLES

### 1. **User** (Utilisateur)
- Rôle par défaut
- Peut découvrir des événements
- Peut s'inscrire aux événements
- Peut acheter des tickets
- Peut voir ses tickets dans son profil
- **NE PEUT PAS** accéder à l'administration

### 2. **Organizer** (Organisateur)
- Toutes les permissions de User
- Peut créer des événements
- Peut gérer ses événements
- Peut voir le dashboard organisateur
- Peut scanner les QR codes
- **NE PEUT PAS** accéder à l'administration

### 3. **Admin** (Administrateur)
- Toutes les permissions d'Organizer
- **PEUT** accéder à l'administration
- Peut supprimer tous les événements
- Peut supprimer les événements passés
- Accès complet à toutes les fonctionnalités

---

## 🛡️ PROTECTIONS MISES EN PLACE

### 1. Modèle Utilisateur
```dart
class UserModel {
  final String role; // 'user', 'organizer', 'admin'
  
  // Getters de vérification
  bool get isAdmin => role == 'admin';
  bool get isOrganizer => role == 'organizer' || role == 'admin';
}
```

### 2. Interface Utilisateur
- **Bouton Admin caché** pour les non-admins
- Visible uniquement dans le profil des admins
- Condition : `if (user.isAdmin)`

### 3. Page d'Administration
- **Vérification au chargement** de la page
- Écran "Accès Refusé" pour les non-admins
- Message clair : "Cette page est réservée aux administrateurs"
- Bouton de retour pour sortir

### 4. Base de Données (Firebase)
```javascript
// Règles Firestore recommandées
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Vérifier le rôle admin
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Actions admin uniquement
    match /admin/{document=**} {
      allow read, write: if isAdmin();
    }
  }
}
```

---

## 👥 COMPTES DE TEST

### Utilisateur Normal
```
Email: demo@eventmate.gn
Password: Demo123!
Rôle: user
Accès Admin: ❌ NON
```

### Organisateur
```
Email: tech@eventmate.gn
Password: Tech123!
Rôle: organizer
Accès Admin: ❌ NON
```

### Administrateur
```
Email: admin@eventmate.gn
Password: Admin123!
Rôle: admin
Accès Admin: ✅ OUI
```

---

## 🔐 COMMENT ÇA MARCHE

### Scénario 1 : Utilisateur Normal
1. Se connecte avec demo@eventmate.gn
2. Va sur son profil
3. **NE VOIT PAS** le bouton "Administration"
4. Ne peut pas accéder à /admin

### Scénario 2 : Tentative d'Accès Direct
1. Utilisateur normal tape l'URL /admin
2. La page vérifie son rôle
3. Affiche "Accès Refusé"
4. Propose de retourner en arrière

### Scénario 3 : Administrateur
1. Se connecte avec admin@eventmate.gn
2. Va sur son profil
3. **VOIT** le bouton "Administration"
4. Clique et accède à la page admin
5. Peut effectuer des actions dangereuses

---

## 🎯 POUR LA DÉMONSTRATION

### Montrer la Sécurité

#### Étape 1 : Utilisateur Normal
```
1. Se connecter avec demo@eventmate.gn
2. Aller sur Profil
3. Montrer : "Pas de bouton Admin"
4. Dire : "Seuls les admins peuvent accéder à l'administration"
```

#### Étape 2 : Administrateur
```
1. Se déconnecter
2. Se connecter avec admin@eventmate.gn
3. Aller sur Profil
4. Montrer : "Bouton Administration visible"
5. Cliquer et accéder à la page admin
6. Dire : "Accès sécurisé par vérification du rôle"
```

---

## 🚀 ÉVOLUTIONS FUTURES

### Court Terme
- [ ] Gestion des rôles dans l'interface admin
- [ ] Promotion user → organizer
- [ ] Promotion organizer → admin
- [ ] Révocation de permissions

### Moyen Terme
- [ ] Permissions granulaires
- [ ] Rôles personnalisés
- [ ] Audit log des actions admin
- [ ] Notifications des actions sensibles

### Long Terme
- [ ] Système de permissions avancé
- [ ] Multi-tenancy
- [ ] Délégation de permissions
- [ ] Approbation à deux facteurs pour actions critiques

---

## 📝 NOTES IMPORTANTES

### Pour la Production
1. **Changer les mots de passe** par défaut
2. **Limiter le nombre d'admins** (1-2 maximum)
3. **Logger toutes les actions admin**
4. **Activer l'authentification à deux facteurs**
5. **Réviser les règles Firestore** régulièrement

### Bonnes Pratiques
- ✅ Ne jamais hardcoder les rôles dans le code
- ✅ Toujours vérifier côté serveur (Firestore Rules)
- ✅ Logger les tentatives d'accès non autorisées
- ✅ Avoir un processus de révocation rapide
- ✅ Former les admins aux bonnes pratiques

---

## 🔍 VÉRIFICATION DE SÉCURITÉ

### Checklist
- [x] Rôle ajouté au modèle utilisateur
- [x] Bouton admin caché pour non-admins
- [x] Page admin protégée avec vérification
- [x] Écran d'accès refusé implémenté
- [x] Comptes de test créés
- [x] Documentation complète

### Tests à Effectuer
1. ✅ Connexion avec utilisateur normal
2. ✅ Vérifier absence du bouton admin
3. ✅ Tentative d'accès direct à /admin
4. ✅ Vérifier message "Accès Refusé"
5. ✅ Connexion avec admin
6. ✅ Vérifier présence du bouton admin
7. ✅ Accès à la page admin réussi

---

## 💡 POINTS À MENTIONNER EN PRÉSENTATION

### Sécurité Robuste
> "L'accès à l'administration est strictement contrôlé. Seuls les utilisateurs avec le rôle 'admin' peuvent y accéder. Une double vérification est effectuée : dans l'interface (bouton caché) et dans la page elle-même."

### Architecture Sécurisée
> "Le système de rôles est intégré au modèle utilisateur et vérifié à plusieurs niveaux : interface, navigation, et idéalement aussi dans les règles Firestore pour une sécurité maximale."

### Évolutivité
> "Ce système de rôles peut facilement être étendu pour ajouter d'autres permissions ou rôles personnalisés selon les besoins futurs."

---

## 🎓 COMPÉTENCES DÉMONTRÉES

- ✅ Gestion des permissions et rôles
- ✅ Sécurité applicative
- ✅ Protection des routes sensibles
- ✅ Expérience utilisateur (messages clairs)
- ✅ Architecture évolutive
- ✅ Bonnes pratiques de sécurité

---

<div align="center">

**🔒 Sécurité Implémentée avec Succès**

*Seuls les administrateurs peuvent accéder aux fonctions sensibles*

</div>
