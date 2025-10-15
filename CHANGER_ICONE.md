# 🎨 Changer l'Icône de l'Application

## 📱 Configuration Actuelle

L'icône de l'application est configurée pour utiliser:
- **Couleur de fond**: Indigo (#6366F1) - La couleur principale de l'app
- **Image**: `assets/icon/app_icon.png`

## 🖼️ Étape 1: Créer Votre Icône

### Option A: Utiliser un Générateur en Ligne (Recommandé)

1. Allez sur [Icon Kitchen](https://icon.kitchen/) ou [App Icon Generator](https://www.appicon.co/)
2. Créez une icône avec:
   - **Texte**: "EM" ou "EventMate"
   - **Couleur de fond**: #6366F1 (Indigo)
   - **Icône**: 🎉 ou 📅 ou 🎪
   - **Style**: Moderne, arrondi
3. Téléchargez l'icône en **1024x1024 px** (format PNG)
4. Renommez-la en `app_icon.png`
5. Placez-la dans `assets/icon/app_icon.png`

### Option B: Créer Manuellement

Créez une image PNG de **1024x1024 pixels** avec:
- Fond: Indigo (#6366F1)
- Logo: Blanc ou couleur contrastante
- Style: Simple et reconnaissable
- Format: PNG avec transparence si nécessaire

Sauvegardez-la dans: `assets/icon/app_icon.png`

## 🚀 Étape 2: Générer les Icônes

Une fois votre image `app_icon.png` créée:

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Générer les icônes pour toutes les plateformes

```bash
dart run flutter_launcher_icons
```

Cette commande va automatiquement:
- ✅ Créer toutes les tailles d'icônes pour Android (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Créer l'icône adaptative Android avec fond coloré
- ✅ Créer toutes les tailles d'icônes pour iOS
- ✅ Mettre à jour les fichiers de configuration

### 3. Rebuild l'application

```bash
flutter clean
flutter run
```

## 📐 Spécifications de l'Icône

### Android
- **Tailles générées**: 48x48, 72x72, 96x96, 144x144, 192x192
- **Icône adaptative**: Oui (avec fond #6366F1)
- **Format**: PNG

### iOS
- **Tailles générées**: 20x20 à 1024x1024
- **Format**: PNG sans transparence pour l'App Store

## 🎨 Idées de Design

### Style 1: Minimaliste
```
Fond: #6366F1 (Indigo)
Texte: "EM" en blanc, police moderne
```

### Style 2: Icône
```
Fond: #6366F1 (Indigo)
Icône: 🎉 ou 📅 en blanc/jaune
```

### Style 3: Logo
```
Fond: Dégradé Indigo → Rose
Logo: Calendrier stylisé en blanc
```

## 🔧 Personnalisation Avancée

### Changer la Couleur de Fond (Android Adaptative)

Dans `pubspec.yaml`, modifiez:
```yaml
adaptive_icon_background: "#6366F1"  # Changez cette couleur
```

Couleurs suggérées:
- **Indigo**: `#6366F1` (actuel)
- **Rose**: `#EC4899`
- **Vert**: `#10B981`
- **Violet**: `#8B5CF6`

### Utiliser une Image de Fond Différente

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "assets/icon/background.png"  # Image au lieu de couleur
  adaptive_icon_foreground: "assets/icon/foreground.png"
```

## ✅ Vérification

Après génération, vérifiez:

1. **Android**: `android/app/src/main/res/mipmap-*/ic_launcher.png`
2. **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🆘 Problèmes Courants

### Erreur: "Image not found"
➡️ Vérifiez que `assets/icon/app_icon.png` existe et fait 1024x1024 px

### L'icône ne change pas
➡️ Exécutez `flutter clean` puis `flutter run`

### Icône floue sur Android
➡️ Assurez-vous que l'image source fait au moins 1024x1024 px

## 📱 Résultat

Après ces étapes, votre application aura:
- ✅ Une icône personnalisée sur Android
- ✅ Une icône personnalisée sur iOS
- ✅ Une icône adaptative moderne sur Android 8+
- ✅ Une icône cohérente avec le design de l'app

---

## 🎯 Exemple Rapide

Si vous voulez tester rapidement:

1. Téléchargez une icône gratuite sur [Flaticon](https://www.flaticon.com/)
2. Recherchez "calendar" ou "event"
3. Téléchargez en 1024x1024 PNG
4. Renommez en `app_icon.png`
5. Placez dans `assets/icon/`
6. Exécutez `dart run flutter_launcher_icons`

**C'est fait!** 🎉
