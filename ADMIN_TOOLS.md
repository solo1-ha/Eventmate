# 🛠️ Outils d'Administration - EventMate

## ⚠️ ATTENTION

Ces outils permettent de **supprimer tous les événements** de votre application.  
**Ces actions sont IRRÉVERSIBLES !**  
À utiliser uniquement en développement ou pour nettoyer la base de données.

---

## 📱 Méthode 1 : Via l'Application (Recommandé)

### Accès
1. Lancez l'application : `flutter run -d chrome`
2. Connectez-vous à votre compte
3. Allez dans **Profil** (onglet en bas à droite)
4. Cliquez sur le bouton **"Administration"**

### Fonctionnalités Disponibles

#### 🗑️ Supprimer TOUS les événements
- Supprime **tous** les événements de la base de données
- Supprime également **toutes** les inscriptions associées
- Confirmation requise avant suppression

#### 📅 Supprimer les événements passés
- Supprime uniquement les événements dont la date est dépassée
- Supprime également les inscriptions liées
- Utile pour nettoyer les anciens événements

### Utilisation
```
1. Cliquez sur l'action souhaitée
2. Confirmez dans la boîte de dialogue
3. Attendez la fin de l'opération
4. Un message de confirmation s'affiche avec le nombre d'éléments supprimés
```

---

## 💻 Méthode 2 : Script PowerShell

### Prérequis
- Firebase CLI installé : `npm install -g firebase-tools`
- Connecté à Firebase : `firebase login`
- Dans le bon projet Firebase

### Utilisation
```powershell
# Depuis le dossier du projet
cd c:\Users\Miekail\Desktop\mon_projet\eventmate

# Exécuter le script
.\delete_all_events.ps1
```

### Ce que fait le script
1. Affiche un avertissement
2. Demande confirmation (taper "OUI" en majuscules)
3. Supprime tous les événements via Firebase CLI
4. Propose de supprimer aussi les inscriptions

---

## 🔧 Méthode 3 : Code Dart Direct

Si vous voulez intégrer la suppression dans votre propre code :

```dart
import 'package:eventmate/utils/delete_all_events.dart';

// Supprimer tous les événements
final result = await DeleteAllEventsUtil.deleteAllEvents(
  deleteRegistrations: true,
);

print(result['message']);
print('Événements supprimés: ${result['eventsDeleted']}');
print('Inscriptions supprimées: ${result['registrationsDeleted']}');

// Supprimer uniquement les événements passés
final result2 = await DeleteAllEventsUtil.deletePastEvents();

// Supprimer les événements d'un utilisateur
final result3 = await DeleteAllEventsUtil.deleteUserEvents('userId');
```

---

## 📊 Fonctions Disponibles

### `DeleteAllEventsUtil.deleteAllEvents()`
**Paramètres :**
- `deleteRegistrations` (bool) : Supprimer aussi les inscriptions (défaut: true)

**Retour :**
```dart
{
  'success': true/false,
  'eventsDeleted': 42,
  'registrationsDeleted': 128,
  'message': 'Message de résultat'
}
```

### `DeleteAllEventsUtil.deletePastEvents()`
Supprime uniquement les événements dont la date est passée.

### `DeleteAllEventsUtil.deleteUserEvents(String userId)`
Supprime tous les événements créés par un utilisateur spécifique.

---

## 🔒 Sécurité

### Règles Firestore
Assurez-vous que vos règles Firestore permettent la suppression :

```javascript
match /events/{eventId} {
  allow delete: if request.auth != null && 
    resource.data.organizerId == request.auth.uid;
}
```

### Recommandations
- ✅ Utilisez ces outils **uniquement en développement**
- ✅ Faites une **sauvegarde** avant suppression en production
- ✅ Testez d'abord avec `deletePastEvents()` avant `deleteAllEvents()`
- ❌ Ne laissez **pas** le bouton admin accessible en production

---

## 🚀 Pour Désactiver en Production

### Option 1 : Supprimer le bouton
Commentez ou supprimez le bouton dans `profile_page.dart` :

```dart
// CustomButton(
//   text: 'Administration',
//   onPressed: () => Navigator.pushNamed(context, '/admin'),
//   ...
// ),
```

### Option 2 : Ajouter une vérification
Ajoutez une condition pour afficher le bouton uniquement en dev :

```dart
if (kDebugMode) // Importer 'package:flutter/foundation.dart'
  CustomButton(
    text: 'Administration',
    onPressed: () => Navigator.pushNamed(context, '/admin'),
    ...
  ),
```

---

## 📝 Exemples d'Utilisation

### Nettoyer avant une démo
```dart
// Supprimer tous les anciens événements
await DeleteAllEventsUtil.deleteAllEvents();

// Créer de nouveaux événements de test
// ... votre code de création
```

### Maintenance régulière
```dart
// Supprimer les événements de plus de 30 jours
// (à implémenter si nécessaire)
```

---

## ❓ FAQ

**Q : Puis-je récupérer les données après suppression ?**  
R : Non, la suppression est définitive. Faites une sauvegarde avant.

**Q : Combien de temps prend la suppression ?**  
R : Dépend du nombre d'événements. Environ 1-2 secondes pour 100 événements.

**Q : Les images sont-elles supprimées ?**  
R : Non, seuls les documents Firestore sont supprimés. Les images restent dans Firebase Storage.

**Q : Puis-je annuler pendant la suppression ?**  
R : Non, une fois lancée, l'opération va jusqu'au bout.

---

## 🆘 En Cas de Problème

### Erreur : "Utilisateur non connecté"
→ Connectez-vous à l'application avant d'utiliser les outils

### Erreur : "Permission denied"
→ Vérifiez vos règles Firestore

### Script PowerShell ne fonctionne pas
→ Vérifiez que Firebase CLI est installé et que vous êtes connecté

---

## 📞 Support

Pour toute question ou problème, consultez la documentation Firebase :
- [Firestore Delete Data](https://firebase.google.com/docs/firestore/manage-data/delete-data)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

**Créé pour EventMate v1.0.0**  
*Utilisez avec précaution !* ⚠️
