import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour un scanner autorisé
class AuthorizedScannerModel {
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime addedAt;

  AuthorizedScannerModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.addedAt,
  });

  /// Créer depuis Firestore
  factory AuthorizedScannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AuthorizedScannerModel(
      userId: data['userId'] ?? doc.id,
      userName: data['userName'] ?? 'Utilisateur',
      userEmail: data['userEmail'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Copier avec modifications
  AuthorizedScannerModel copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? addedAt,
  }) {
    return AuthorizedScannerModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
