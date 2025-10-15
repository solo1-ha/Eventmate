# 🖼️ Guide de Dépannage Upload d'Images

## 🎯 Problème

L'image ne se télécharge pas lors de la création d'un événement.

---

## ✅ Vérifications à Faire

### **1. Firebase Storage Configuré?**

#### **A. Vérifier dans Firebase Console**

1. Aller sur https://console.firebase.google.com
2. Sélectionner le projet **eventmate-61924**
3. Menu **Storage** (à gauche)
4. Vérifier que Storage est **activé**

#### **B. Règles de Sécurité**

Les règles doivent permettre l'upload:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Permettre lecture à tous
      allow read: if true;
      
      // Permettre écriture aux utilisateurs authentifiés
      allow write: if request.auth != null;
    }
  }
}
```

**Comment vérifier:**
1. Firebase Console → Storage
2. Onglet **Rules**
3. Copier les règles ci-dessus
4. Cliquer **Publish**

---

### **2. Logs de Débogage**

#### **Ouvrir la Console du Navigateur**

**Chrome:**
1. Appuyer sur `F12`
2. Onglet **Console**
3. Cliquer sur le bouton d'image
4. Observer les messages:

```
🖼️ Début sélection image...
📁 Ouverture galerie...
✅ Image sélectionnée: image.jpg
📤 Upload vers Firebase Storage...
✅ Upload terminé: https://...
```

**Si erreur:**
```
❌ Erreur upload image: [message d'erreur]
```

---

### **3. Tester l'Upload**

#### **Étapes de Test**

1. **Ouvrir l'application** sur Chrome
2. **Se connecter** en tant qu'organisateur
3. **Créer un événement**
4. **Cliquer sur "Ajouter une image"**
5. **Sélectionner une image** depuis votre PC
6. **Observer**:
   - Message "Upload en cours..." (10 secondes max)
   - Message "Image ajoutée avec succès!" (vert)
   - Image affichée dans le formulaire

---

## 🔧 Solutions aux Problèmes Courants

### **Problème 1: Aucune fenêtre de sélection**

**Cause**: `image_picker` ne fonctionne pas sur web

**Solution**: Vérifier `pubspec.yaml`
```yaml
dependencies:
  image_picker: ^1.0.4
```

**Commande**:
```bash
flutter pub get
flutter run -d chrome
```

---

### **Problème 2: Image sélectionnée mais pas d'upload**

**Cause**: Firebase Storage non configuré

**Solution**:
1. Firebase Console → Storage
2. Cliquer **Get Started**
3. Choisir **Test Mode** (temporaire)
4. Sélectionner une région (ex: europe-west1)
5. Cliquer **Done**

---

### **Problème 3: Erreur "Permission Denied"**

**Cause**: Règles de sécurité trop strictes

**Solution**: Modifier les règles Storage
```javascript
allow write: if request.auth != null;
```

---

### **Problème 4: Upload très lent**

**Cause**: Image trop grande

**Solution**: L'image est automatiquement redimensionnée
```dart
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,    // ✅ Limite largeur
  maxHeight: 1080,   // ✅ Limite hauteur
  imageQuality: 85,  // ✅ Compression
);
```

---

## 📊 Flux d'Upload

```
1. Utilisateur clique "Ajouter une image"
   ↓
2. Ouverture sélecteur de fichiers (navigateur)
   ↓
3. Utilisateur sélectionne une image
   ↓
4. Image convertie en bytes
   ↓
5. Upload vers Firebase Storage
   ↓
6. Récupération de l'URL
   ↓
7. Affichage de l'image
```

---

## 🧪 Test Manuel

### **Code de Test**

Ajoutez ce bouton temporaire pour tester:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final storage = ref.read(storageService);
      print('Test: Ouverture galerie...');
      
      final imageFile = await storage.pickImageFromGallery();
      
      if (imageFile != null) {
        print('Test: Image sélectionnée - ${imageFile.name}');
        print('Test: Taille - ${await imageFile.length()} bytes');
        
        final url = await storage.uploadEventImage(imageFile, 'test-123');
        print('Test: URL - $url');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Succès! URL: $url')),
        );
      } else {
        print('Test: Aucune image');
      }
    } catch (e) {
      print('Test: Erreur - $e');
    }
  },
  child: Text('TEST UPLOAD'),
)
```

---

## 🔍 Vérification Firebase Storage

### **Dans Firebase Console**

1. Storage → Files
2. Vérifier le dossier `events/`
3. Les images uploadées doivent apparaître:
   ```
   events/
     ├── event_abc123_1234567890.jpg
     ├── event_def456_1234567891.jpg
     └── ...
   ```

---

## ⚙️ Configuration Actuelle

### **StorageService** (`lib/data/services/storage_service.dart`)

```dart
Future<String> uploadEventImage(XFile imageFile, String eventId) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('Utilisateur non connecté');

  try {
    final String fileName = 'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('events/$fileName');

    // Upload compatible web et mobile
    final bytes = await imageFile.readAsBytes();
    final UploadTask uploadTask = ref.putData(bytes);

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    throw Exception('Erreur lors de l\'upload: $e');
  }
}
```

**Points clés**:
- ✅ Compatible web (utilise `putData` au lieu de `putFile`)
- ✅ Génère un nom unique
- ✅ Stocke dans `events/`
- ✅ Retourne l'URL publique

---

## 📝 Checklist de Dépannage

- [ ] Firebase Storage activé dans Console
- [ ] Règles Storage permettent l'écriture
- [ ] Utilisateur authentifié (connecté)
- [ ] Package `image_picker` installé
- [ ] Console navigateur ouverte (F12)
- [ ] Logs visibles dans console
- [ ] Tester avec une petite image (<5MB)
- [ ] Vérifier connexion Internet

---

## 🎯 Messages Attendus

### **Succès**
```
🖼️ Début sélection image...
📁 Ouverture galerie...
✅ Image sélectionnée: mon_image.jpg
📤 Upload vers Firebase Storage...
✅ Upload terminé: https://firebasestorage.googleapis.com/...
```

### **Échec**
```
❌ Erreur upload image: [détails de l'erreur]
```

**Erreurs Communes**:
- `User not authenticated` → Se reconnecter
- `Permission denied` → Vérifier règles Storage
- `Network error` → Vérifier connexion Internet
- `File too large` → Réduire taille image

---

## 🚀 Prochaines Étapes

1. **Ouvrir Chrome DevTools** (F12)
2. **Tester l'upload** d'une image
3. **Copier les logs** de la console
4. **Partager les erreurs** si problème persiste

---

## 💡 Astuce

Pour tester rapidement, utilisez une **petite image** (100-500 KB) au lieu d'une grande photo (5-10 MB).

---

**Si le problème persiste, partagez les logs de la console!** 🔍
