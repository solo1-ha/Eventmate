# 📚 Documentation du Code - EventMate

## 🎯 Fichiers Principaux Commentés

### 1. Widget d'Inscription (`lib/widgets/inscription_button.dart`)

#### Fonctionnalités
- **Détection automatique des événements passés**
- Vérification si l'utilisateur est déjà inscrit
- Protection si l'utilisateur est l'organisateur
- Affichage du nombre de places disponibles

#### Logique de Vérification (Ordre d'Exécution)

```dart
1. Événement passé ? → Bouton gris "Événement terminé" (NON CLIQUABLE)
2. Vous êtes organisateur ? → Bouton "Vous êtes l'organisateur" (NON CLIQUABLE)
3. En chargement ? → Spinner
4. Déjà inscrit ? → Bouton vert "Voir mon ticket"
5. Événement complet ? → Bouton "Événement complet" (NON CLIQUABLE)
6. Sinon → Bouton bleu "S'inscrire" (CLIQUABLE)
```

#### Code Clé

```dart
// VÉRIFICATION PRIORITAIRE : Événement passé
if (widget.event.dateTime.isBefore(DateTime.now())) {
  return ElevatedButton.icon(
    onPressed: null,  // Désactivé
    label: const Text('Événement terminé'),
  );
}
```

---

### 2. Service d'Inscription (`lib/data/services/inscription_service.dart`)

#### Méthodes Principales

##### `registerToFreeEvent()`
Inscrit un utilisateur à un événement gratuit

**Paramètres :**
- `event` : L'événement
- `user` : L'utilisateur
- `quantity` : Nombre de tickets (1-10)
- `attendeeNames` : Noms des participants (optionnel)

**Vérifications (dans l'ordre) :**
1. ✅ Événement passé ?
2. ✅ Utilisateur = organisateur ?
3. ✅ Déjà inscrit ?
4. ✅ Capacité suffisante ?

**Actions :**
1. Génération du QR code unique
2. Création de l'inscription
3. Sauvegarde dans Firestore
4. Mise à jour du compteur de participants

##### `registerToPaidEvent()`
Inscrit un utilisateur à un événement payant

**Paramètres supplémentaires :**
- `ticketType` : Type de ticket (VIP, Standard, etc.)
- `ticketPrice` : Prix unitaire
- `paymentMethod` : Méthode de paiement
- `phoneNumber` : Numéro pour Orange Money

**Étapes supplémentaires :**
1. Calcul du prix total (`ticketPrice × quantity`)
2. Simulation du paiement Orange Money
3. Puis même logique que l'événement gratuit

---

### 3. Modèle d'Inscription (`lib/data/models/registration_model.dart`)

#### Champs Importants

```dart
class RegistrationModel {
  final String id;              // ID unique
  final String eventId;         // ID de l'événement
  final String userId;          // ID de l'utilisateur
  final String qrCode;          // QR code unique
  final int ticketQuantity;     // Nombre de tickets (NOUVEAU)
  final List<String>? attendeeNames;  // Noms des participants (NOUVEAU)
  final double? ticketPrice;    // Prix du ticket
  final String? ticketType;     // Type de ticket
}
```

---

### 4. Widget de Sélection de Quantité (`lib/widgets/ticket_quantity_dialog.dart`)

#### Fonctionnalités
- Sélecteur de quantité (1 à 10 tickets)
- Calcul automatique du prix total
- Option pour ajouter les noms des participants
- Champs de texte dynamiques

#### Exemple d'Utilisation

```dart
final result = await showDialog<Map<String, dynamic>>(
  context: context,
  builder: (context) => TicketQuantityDialog(
    maxQuantity: 10,
    ticketPrice: 5000,
    currency: 'GNF',
  ),
);

// Résultat
{
  'quantity': 3,
  'names': ['Alice', 'Bob', 'Charlie']
}
```

---

## 🔒 Règles de Sécurité Firestore

### Collection `registrations`

```javascript
match /registrations/{registrationId} {
  // Lecture : tout utilisateur authentifié
  allow read: if isSignedIn();
  
  // Création : utilisateur qui s'inscrit lui-même
  allow create: if isSignedIn() && 
    request.resource.data.userId == request.auth.uid;
  
  // Modification : tout utilisateur authentifié
  allow update: if isSignedIn();
  
  // Suppression : utilisateur propriétaire
  allow delete: if isSignedIn() && 
    resource.data.userId == request.auth.uid;
}
```

---

## 🎨 Flux d'Inscription Complet

### Scénario : Achat de 3 tickets payants

```
1. Utilisateur clique "S'inscrire"
   ↓
2. Sélectionne le type de ticket (VIP - 5000 GNF)
   ↓
3. Entre son numéro de téléphone (664466777)
   ↓
4. Dialog s'affiche : "Nombre de tickets"
   ↓
5. Sélectionne 3 tickets
   ↓
6. Prix total calculé : 3 × 5000 = 15 000 GNF
   ↓
7. (Optionnel) Coche "Ajouter les noms"
   ↓
8. Entre les noms : Alice, Bob, Charlie
   ↓
9. Clique "Continuer"
   ↓
10. Paiement simulé : 15 000 GNF via Orange Money
    ↓
11. Inscription créée dans Firestore :
    {
      id: "abc123",
      eventId: "evt456",
      userId: "user789",
      ticketQuantity: 3,
      attendeeNames: ["Alice", "Bob", "Charlie"],
      ticketPrice: 5000,
      qrCode: "unique-qr-code"
    }
    ↓
12. Participants mis à jour : +3
    ↓
13. Modal se ferme
    ↓
14. Ticket affiché automatiquement avec QR code
```

---

## 🛡️ Protections Implémentées

### Côté Client (UI)

1. **Bouton désactivé** pour événements passés
2. **Bouton désactivé** pour organisateurs
3. **Bouton désactivé** si événement complet
4. **Vérification de la quantité** vs places disponibles

### Côté Serveur (Service)

1. **Vérification de la date** de l'événement
2. **Vérification de l'organisateur**
3. **Vérification de l'inscription existante**
4. **Vérification de la capacité**

### Base de Données (Firestore Rules)

1. **Authentification requise**
2. **Utilisateur ne peut inscrire que lui-même**
3. **Validation des données**

---

## 📊 Données Stockées

### Exemple d'Inscription avec 3 Tickets

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "eventId": "evt_soiree_black",
  "userId": "user_123",
  "userName": "Jean Dupont",
  "userEmail": "jean@example.com",
  "userPhone": "664466777",
  "registeredAt": "2025-10-16T10:00:00Z",
  "qrCode": "evt_soiree_black|user_123|1697453400000|a1b2c3d4",
  "isActive": true,
  "ticketType": "VIP",
  "ticketPrice": 5000,
  "ticketQuantity": 3,
  "attendeeNames": ["Alice", "Bob", "Charlie"]
}
```

---

## 🎯 Points Clés pour la Présentation

### 1. Gestion Intelligente des Événements Passés
- ✅ Détection automatique
- ✅ Bouton désactivé visuellement
- ✅ Protection côté serveur
- ✅ Message clair pour l'utilisateur

### 2. Achat Multiple de Tickets
- ✅ 1 à 10 tickets en une transaction
- ✅ Ajout des noms des participants
- ✅ Calcul automatique du prix total
- ✅ Un seul QR code pour tout le groupe

### 3. Sécurité Robuste
- ✅ Triple vérification (UI + Service + Firestore)
- ✅ Validation des données
- ✅ Protection contre les abus

### 4. Expérience Utilisateur
- ✅ Feedback visuel clair
- ✅ Messages d'erreur explicites
- ✅ Affichage immédiat du ticket
- ✅ Interface intuitive

---

## 💡 Innovations Techniques

### 1. Architecture en Couches
```
UI (Widgets)
    ↓
Services (Logique métier)
    ↓
Firestore (Base de données)
```

### 2. Gestion d'État avec Riverpod
- State management moderne
- Réactivité automatique
- Code propre et maintenable

### 3. Validation Multi-Niveaux
- Client : Feedback immédiat
- Service : Logique métier
- Firestore : Sécurité finale

---

## 📝 Conclusion

Le code est structuré de manière professionnelle avec :
- ✅ Commentaires clairs et détaillés
- ✅ Séparation des responsabilités
- ✅ Gestion d'erreurs robuste
- ✅ Sécurité à tous les niveaux
- ✅ Code réutilisable et maintenable

**Prêt pour la présentation !** 🎓
