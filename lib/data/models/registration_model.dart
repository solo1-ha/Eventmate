import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d'inscription à un événement
class RegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final DateTime registeredAt;
  final DateTime? checkedInAt;
  final String qrCode;
  final bool isActive;
  final String? ticketType; // Type de ticket (Standard, VIP, etc.)
  final double? ticketPrice; // Prix du ticket
  final int ticketQuantity; // Nombre de tickets achetés
  final List<String>? attendeeNames; // Noms des participants (optionnel)

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.registeredAt,
    this.checkedInAt,
    required this.qrCode,
    required this.isActive,
    this.ticketType,
    this.ticketPrice,
    this.ticketQuantity = 1,
    this.attendeeNames,
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
      userPhone: data['userPhone'],
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      checkedInAt: data['checkedInAt'] != null 
          ? (data['checkedInAt'] as Timestamp).toDate() 
          : null,
      qrCode: data['qrCode'] ?? '',
      isActive: data['isActive'] ?? true,
      ticketType: data['ticketType'],
      ticketPrice: data['ticketPrice']?.toDouble(),
      ticketQuantity: data['ticketQuantity'] ?? 1,
      attendeeNames: data['attendeeNames'] != null 
          ? List<String>.from(data['attendeeNames'])
          : null,
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'checkedInAt': checkedInAt != null 
          ? Timestamp.fromDate(checkedInAt!) 
          : null,
      'qrCode': qrCode,
      'isActive': isActive,
      'ticketType': ticketType,
      'ticketPrice': ticketPrice,
      'ticketQuantity': ticketQuantity,
      'attendeeNames': attendeeNames,
    };
  }

  /// Création d'une copie avec modifications
  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    DateTime? registeredAt,
    DateTime? checkedInAt,
    String? qrCode,
    bool? isActive,
    String? ticketType,
    double? ticketPrice,
    int? ticketQuantity,
    List<String>? attendeeNames,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      registeredAt: registeredAt ?? this.registeredAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      qrCode: qrCode ?? this.qrCode,
      isActive: isActive ?? this.isActive,
      ticketType: ticketType ?? this.ticketType,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      ticketQuantity: ticketQuantity ?? this.ticketQuantity,
      attendeeNames: attendeeNames ?? this.attendeeNames,
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

