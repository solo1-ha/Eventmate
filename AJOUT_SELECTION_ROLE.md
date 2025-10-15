# ✅ Ajout de la Sélection de Rôle à l'Inscription

## 🎯 Problème Résolu

**Avant**: Pas de choix entre utilisateur et organisateur lors de l'inscription  
**Maintenant**: Sélection claire du rôle avec interface visuelle

---

## 🎨 Fonctionnalité Ajoutée

### Interface de Sélection de Rôle

**Fichier modifié**: `lib/features/auth/presentation/pages/register_page.dart`

#### Nouveaux Éléments:

1. **Variable d'état**:
```dart
String _selectedRole = 'user'; // 'user' ou 'organizer'
```

2. **Widget de sélection**:
- Deux cartes interactives côte à côte
- Design moderne avec icônes
- Feedback visuel (couleur, bordure)
- Descriptions claires

3. **Rôles disponibles**:

| Rôle | Icône | Description |
|------|-------|-------------|
| **Utilisateur** | 👤 | Je veux participer à des événements |
| **Organisateur** | 📅 | Je veux créer et gérer des événements |

---

## 📱 Interface Utilisateur

### Apparence

```
┌─────────────────────────────────────────┐
│         Je suis un(e)                   │
├─────────────────┬───────────────────────┤
│   👤            │      📅               │
│ Utilisateur     │   Organisateur        │
│ Je veux         │   Je veux créer       │
│ participer à    │   et gérer des        │
│ des événements  │   événements          │
└─────────────────┴───────────────────────┘
```

### États Visuels

**Non sélectionné**:
- Fond: Gris clair
- Bordure: Fine et grise
- Icône: Gris

**Sélectionné**:
- Fond: Bleu clair (primaryContainer)
- Bordure: Épaisse et bleue (primary)
- Icône: Bleue (primary)
- Texte: Bleu (primary)

---

## 🔧 Implémentation Technique

### Méthode `_buildRoleSelector`

Crée la section de sélection avec:
- Titre "Je suis un(e)"
- Deux cartes de rôle côte à côte

### Méthode `_buildRoleCard`

Crée chaque carte de rôle avec:
- Interaction tactile (InkWell)
- Changement d'état au clic
- Design responsive
- Animations de transition

### Méthode `_register` (modifiée)

```dart
final newUser = UserModel(
  // ...
  role: _selectedRole, // ← Utilise le rôle sélectionné
  // ...
);
```

---

## 💾 Données Sauvegardées

Le rôle sélectionné est sauvegardé dans Firestore:

```javascript
users/{userId} {
  id: string,
  email: string,
  firstName: string,
  lastName: string,
  role: "user" | "organizer", // ← Rôle choisi
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## 🎯 Utilisation

### Flux d'Inscription

1. L'utilisateur remplit le formulaire
2. **Sélectionne son rôle** (Utilisateur ou Organisateur)
3. Clique sur "S'inscrire"
4. Le compte est créé avec le rôle choisi

### Permissions par Rôle

**Utilisateur** (`role: 'user'`):
- ✅ Voir les événements
- ✅ S'inscrire aux événements
- ✅ Scanner QR codes
- ❌ Créer des événements

**Organisateur** (`role: 'organizer'`):
- ✅ Toutes les permissions utilisateur
- ✅ Créer des événements
- ✅ Modifier/Supprimer ses événements
- ✅ Voir le dashboard organisateur
- ✅ Gérer les participants
- ✅ Valider les QR codes

---

## 🔐 Vérification du Rôle

### Dans l'Application

Utilisez les providers existants:

```dart
// Vérifier si organisateur
final isOrganizer = ref.watch(isOwnerProvider);

// Récupérer le rôle
final user = ref.watch(currentUserProvider);
final role = user?.role; // 'user' ou 'organizer'
```

### Affichage Conditionnel

```dart
// Afficher bouton "Créer événement" seulement pour organisateurs
if (isOrganizer) {
  FloatingActionButton(
    onPressed: () => Navigator.push(...),
    child: Icon(Icons.add),
  ),
}
```

---

## 📊 Statistiques

### Avant
- ❌ Tous les utilisateurs avaient le rôle 'user' par défaut
- ❌ Pas de distinction entre utilisateurs et organisateurs
- ❌ Permissions non différenciées

### Maintenant
- ✅ Choix explicite du rôle à l'inscription
- ✅ Interface claire et intuitive
- ✅ Permissions basées sur le rôle
- ✅ Expérience personnalisée

---

## 🎨 Design

### Responsive
- Adapté aux petits et grands écrans
- Cartes côte à côte sur écrans larges
- Layout flexible

### Accessibilité
- Zones de clic généreuses
- Contraste de couleurs respecté
- Feedback visuel clair
- Textes descriptifs

### Cohérence
- Utilise le thème de l'application
- Suit les conventions Material Design
- Animations fluides

---

## 🧪 Tests

### Test Manuel

1. Ouvrir la page d'inscription
2. Vérifier que "Utilisateur" est sélectionné par défaut
3. Cliquer sur "Organisateur"
4. Vérifier le changement visuel
5. S'inscrire
6. Vérifier dans Firestore que le rôle est correct

### Vérification Firestore

```javascript
// Firebase Console > Firestore > users > {userId}
{
  "role": "organizer" // ou "user"
}
```

---

## 🚀 Améliorations Futures (Optionnel)

1. **Rôle Admin**:
   - Ajouter un troisième rôle "admin"
   - Permissions étendues

2. **Changement de Rôle**:
   - Permettre de passer de user à organizer
   - Validation par admin

3. **Badges**:
   - Badge "Organisateur vérifié"
   - Système de certification

4. **Statistiques**:
   - Nombre d'événements créés
   - Note moyenne

---

## ✅ Checklist de Validation

- [x] Variable `_selectedRole` ajoutée
- [x] Widget `_buildRoleSelector` créé
- [x] Widget `_buildRoleCard` créé
- [x] Méthode `_register` mise à jour
- [x] Design responsive
- [x] Feedback visuel
- [x] Rôle sauvegardé dans Firestore
- [x] Compilation sans erreurs
- [x] Interface intuitive

---

## 📝 Résumé

**Modification**: Page d'inscription (`register_page.dart`)

**Ajouts**:
- Sélecteur de rôle visuel
- 2 cartes interactives (Utilisateur/Organisateur)
- Sauvegarde du rôle choisi

**Impact**:
- Meilleure expérience utilisateur
- Permissions différenciées
- Base pour fonctionnalités avancées

**Résultat**: ✅ Les utilisateurs peuvent maintenant choisir leur rôle lors de l'inscription!

---

**L'inscription est maintenant complète avec sélection de rôle!** 🎉
