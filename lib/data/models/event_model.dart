import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d'événement
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;
  final int maxCapacity;
  final int currentParticipants;
  final String? imageUrl;
  final String organizerId;
  final String organizerName;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isPaid;
  final double? price;
  final String currency;
  final int soldTickets;
  final String? category;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.maxCapacity,
    required this.currentParticipants,
    this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.isPaid = false,
    this.price,
    this.currency = 'GNF',
    this.soldTickets = 0,
    this.category,
  });

  /// Vérifie si l'événement est complet
  bool get isFull => currentParticipants >= maxCapacity;

  /// Vérifie si l'événement est passé
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Vérifie si l'événement est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    final eventDate = dateTime;
    return now.year == eventDate.year &&
        now.month == eventDate.month &&
        now.day == eventDate.day;
  }

  /// Vérifie si l'événement est demain
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final eventDate = dateTime;
    return tomorrow.year == eventDate.year &&
        tomorrow.month == eventDate.month &&
        tomorrow.day == eventDate.day;
  }

  /// Pourcentage de remplissage
  double get fillPercentage => currentParticipants / maxCapacity;

  /// Places disponibles
  int get availableSeats => maxCapacity - currentParticipants;

  /// Tickets disponibles (pour événements payants)
  int get availableTickets => maxCapacity - soldTickets;

  /// Revenu total généré
  double get totalRevenue => soldTickets * (price ?? 0);

  /// Prix formaté
  String get formattedPrice {
    if (!isPaid || price == null) return 'Gratuit';
    return '${price!.toStringAsFixed(0)} $currency';
  }

  /// Création d'un EventModel depuis Firestore
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      maxCapacity: data['maxCapacity'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      imageUrl: data['imageUrl'],
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      isPaid: data['isPaid'] ?? false,
      price: data['price']?.toDouble(),
      currency: data['currency'] ?? 'GNF',
      soldTickets: data['soldTickets'] ?? 0,
      category: data['category'],
    );
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'maxCapacity': maxCapacity,
      'currentParticipants': currentParticipants,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'participantIds': participantIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isPaid': isPaid,
      'price': price,
      'currency': currency,
      'soldTickets': soldTickets,
      'category': category,
    };
  }

  /// Création d'une copie avec modifications
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    double? latitude,
    double? longitude,
    int? maxCapacity,
    int? currentParticipants,
    String? imageUrl,
    String? organizerId,
    String? organizerName,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isPaid,
    double? price,
    String? currency,
    int? soldTickets,
    String? category,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      soldTickets: soldTickets ?? this.soldTickets,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, dateTime: $dateTime, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

