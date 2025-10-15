# Corrections - Carte et Page d'Accueil

## Problèmes Identifiés et Corrigés

### 1. Page d'Accueil (EventsListPage)
**Problème:** Type `dynamic` causait l'erreur `.when()` non trouvée

**Solution:**
- Supprimé la méthode `_getEventsProvider()`
- Utilisé un `switch` direct avec typage explicite `AsyncValue<List<dynamic>>`
- Appel direct de `ref.watch()` pour chaque provider

### 2. Page Carte (MapPage)
**Problème:** Utilisation incorrecte de `.value` et `.hasValue` sur `AsyncValue`

**Corrections appliquées:**
```dart
// AVANT
if (events.hasValue && events.value!.isNotEmpty)
  _buildEventsList(theme, events.value!),

// APRÈS
events.when(
  data: (eventsList) => Stack(
    children: [
      _buildGoogleMap(),
      _buildControlButtons(theme),
      if (eventsList.isNotEmpty)
        _buildEventsList(theme, eventsList),
    ],
  ),
  loading: () => const Center(child: LoadingWidget(...)),
  error: (error, stack) => Center(child: Text('Erreur: ...')),
)
```

**Méthode `_loadEventsOnMap()` corrigée:**
```dart
// AVANT
final events = ref.read(eventsProvider).value;

// APRÈS  
final eventsAsync = ref.read(eventsProvider);
eventsAsync.whenData((events) {
  for (final event in events) {
    _addEventMarker(event);
  }
});
```

## Résultat Attendu

✅ **Page d'accueil:** Affiche la liste des 6 événements mockés
✅ **Onglet Carte:** Affiche Google Maps avec les marqueurs d'événements
✅ **Navigation:** Fonctionne entre tous les onglets

## Note sur Google Maps

⚠️ **Important:** Pour que la carte s'affiche correctement, vous devez:
1. Avoir une clé API Google Maps valide
2. L'avoir configurée dans:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`
   - `web/index.html`

En mode web (Chrome), la carte peut ne pas s'afficher sans clé API configurée, mais l'interface devrait quand même se charger sans erreur.

## Test

```bash
flutter run -d chrome
```

L'application devrait maintenant:
- Démarrer sans erreurs
- Afficher les événements sur la page d'accueil
- Permettre la navigation vers la carte
- Afficher l'interface de la carte (avec ou sans Google Maps selon la config)
