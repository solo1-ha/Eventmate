# Mode Frontend Uniquement 🎨

## Configuration Actuelle

L'application **EventMate** est maintenant configurée en **mode frontend uniquement** avec des données mockées.

## ✅ Ce qui fonctionne

### Données Mockées Disponibles

1. **Utilisateur connecté automatiquement**
   - Email: `demo@eventmate.gn`
   - Nom: Utilisateur Demo
   - Rôle: Owner (peut créer des événements)

2. **6 Événements pré-chargés**
   - Festival de Musique Conakry 2025
   - Conférence Tech Guinée
   - Marathon de Conakry
   - Exposition d'Art Contemporain
   - Atelier Entrepreneuriat
   - Concert de Jazz (événement passé)

3. **Fonctionnalités UI Complètes**
   - ✅ Navigation entre les pages
   - ✅ Liste des événements
   - ✅ Détails des événements
   - ✅ Formulaire de création d'événement
   - ✅ Profil utilisateur
   - ✅ Paramètres (thème clair/sombre)
   - ✅ Carte Google Maps (si configurée)
   - ✅ Scanner QR Code

## 🚀 Lancer l'Application

```bash
flutter run
```

Choisissez Chrome (web) ou Windows (desktop) pour tester l'interface.

## 📁 Fichiers Créés

### Services Mockés
- `lib/data/mock/mock_data.dart` - Données mockées (événements, utilisateurs)
- `lib/data/mock/mock_auth_service.dart` - Service d'authentification mocké
- `lib/data/mock/mock_event_service.dart` - Service d'événements mocké

### Providers Modifiés
- `lib/data/providers/auth_provider.dart` - Utilise MockAuthService
- `lib/data/providers/events_provider.dart` - Utilise MockEventService

### Configuration
- `lib/main.dart` - Firebase désactivé

## 🎯 Fonctionnalités Simulées

### Authentification
- Connexion automatique au démarrage
- Accepte n'importe quel email/mot de passe pour la démo
- Déconnexion fonctionnelle

### Événements
- Affichage de la liste complète
- Filtrage par catégorie
- Recherche par titre/description
- Création de nouveaux événements (ajoutés en mémoire)
- Modification et suppression

### Interactions
- Inscription/désinscription aux événements
- Mise à jour du compteur de participants
- Simulation de délais réseau (pour un rendu réaliste)

## 🔄 Passer en Mode Production

Quand vous serez prêt à connecter Firebase :

1. **Configurer Firebase**
   ```bash
   flutterfire configure
   ```

2. **Restaurer les services Firebase**
   - Modifier `lib/data/providers/auth_provider.dart`
   - Modifier `lib/data/providers/events_provider.dart`
   - Décommenter l'initialisation Firebase dans `lib/main.dart`

3. **Supprimer les fichiers mock** (optionnel)
   ```bash
   rm -rf lib/data/mock/
   ```

## 📝 Notes Importantes

- **Aucune donnée n'est persistée** - Tout est en mémoire
- **Rechargement = reset** - Les données reviennent à l'état initial
- **Pas de backend** - Toutes les opérations sont simulées
- **Images** - Utilise Picsum pour les images d'événements

## 🎨 Développement Frontend

Vous pouvez maintenant :
- ✅ Tester toutes les interfaces utilisateur
- ✅ Ajuster les styles et thèmes
- ✅ Perfectionner l'UX
- ✅ Ajouter de nouvelles fonctionnalités UI
- ✅ Faire des captures d'écran pour la documentation

## 🐛 Dépannage

### L'application ne démarre pas
```bash
flutter clean
flutter pub get
flutter run
```

### Erreurs de compilation
Vérifiez que tous les imports sont corrects dans les fichiers modifiés.

### Données mockées ne s'affichent pas
Vérifiez que les providers utilisent bien les services mockés dans :
- `lib/data/providers/auth_provider.dart`
- `lib/data/providers/events_provider.dart`

---

**Mode Frontend Activé** ✨ - Développez l'interface sans vous soucier du backend !
