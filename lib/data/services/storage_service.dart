import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service de gestion du stockage Firebase (images)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  /// Sélectionner une image depuis la galerie
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Prendre une photo avec la caméra
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la prise de photo: $e');
    }
  }

  /// Upload une image de profil utilisateur
  Future<String> uploadProfileImage(XFile imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profiles/$fileName');

      // Upload le fichier (compatible web et mobile)
      final UploadTask uploadTask;
      if (kIsWeb) {
        // Sur web, utiliser les bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        // Sur mobile, utiliser le fichier
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      }

      // Attendre la fin de l'upload
      final TaskSnapshot snapshot = await uploadTask;

      // Récupérer l'URL de téléchargement
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload une image d'événement
  Future<String> uploadEventImage(XFile imageFile, String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    try {
      final String fileName = 'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('events/$fileName');

      // Upload le fichier (compatible web et mobile)
      final bytes = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(bytes);

      // Attendre la fin de l'upload
      final TaskSnapshot snapshot = await uploadTask;

      // Récupérer l'URL de téléchargement
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload une image avec suivi de progression
  Stream<double> uploadImageWithProgress(XFile imageFile, String path) async* {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('$path/$fileName');

      // Upload compatible web et mobile
      final bytes = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(bytes);

      await for (final TaskSnapshot snapshot in uploadTask.snapshotEvents) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        yield progress;
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Supprimer l'ancienne image de profil
  Future<void> deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl == null || oldImageUrl.isEmpty) return;
    
    try {
      // Vérifier que c'est bien une URL Firebase Storage
      if (oldImageUrl.contains('firebasestorage.googleapis.com')) {
        await deleteImage(oldImageUrl);
      }
    } catch (e) {
      // Ignorer les erreurs de suppression (l'image n'existe peut-être plus)
      print('Impossible de supprimer l\'ancienne image: $e');
    }
  }

  /// Obtenir la taille d'un fichier
  Future<int> getFileSize(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Vérifier si une image existe
  Future<bool> imageExists(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
