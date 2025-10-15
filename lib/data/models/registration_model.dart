import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d'inscription à un événement
class RegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime registeredAt;
  final DateTime? checkedInAt;
  final String qrCode;
  final bool isActive;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.registeredAt,
    this.checkedInAt,
    required this.qrCode,
    required this.isActive,
  });

  /// Vérifie si l'utilisateur a effectué le check-in
  bool get hasCheckedIn => checkedInAt != null;

  /// Création d'un RegistrationModel depuis Firestore
  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistrationModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      checkedInAt: data['checkedInAt'] != null 
          ? (data['checkedInAt'] as Timestamp).toDate() 
          : null,
      qrCode: data['qrCode'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'checkedInAt': checkedInAt != null 
          ? Timestamp.fromDate(checkedInAt!) 
          : null,
      'qrCode': qrCode,
      'isActive': isActive,
    };
  }

  /// Création d'une copie avec modifications
  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? registeredAt,
    DateTime? checkedInAt,
    String? qrCode,
    bool? isActive,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      registeredAt: registeredAt ?? this.registeredAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      qrCode: qrCode ?? this.qrCode,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'RegistrationModel(id: $id, eventId: $eventId, userId: $userId, hasCheckedIn: $hasCheckedIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

