import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

/// Service de gestion du cache local
class CacheService {
  static const String _eventsKey = 'cached_events';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _registeredEventsKey = 'cached_registered_events';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Factory pour créer une instance
  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  // ==================== ÉVÉNEMENTS ====================

  /// Sauvegarder les événements en cache
  Future<bool> cacheEvents(List<EventModel> events) async {
    try {
      final jsonList = events.map((e) => e.toFirestore()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_eventsKey, jsonString);
      await _updateLastSync();
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde des événements: $e');
      return false;
    }
  }

  /// Récupérer les événements en cache
  Future<List<EventModel>> getCachedEvents() async {
    try {
      final jsonString = _prefs.getString(_eventsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) {
        // Convertir les timestamps
        if (json['dateTime'] is Map) {
          json['dateTime'] = DateTime.fromMillisecondsSinceEpoch(
            json['dateTime']['_seconds'] * 1000,
          );
        }
        if (json['createdAt'] is Map) {
          json['createdAt'] = DateTime.fromMillisecondsSinceEpoch(
            json['createdAt']['_seconds'] * 1000,
          );
        }
        if (json['updatedAt'] is Map) {
          json['updatedAt'] = DateTime.fromMillisecondsSinceEpoch(
            json['updatedAt']['_seconds'] * 1000,
          );
        }

        return EventModel(
          id: json['id'] ?? '',
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          dateTime: json['dateTime'] is DateTime
              ? json['dateTime']
              : DateTime.now(),
          location: json['location'] ?? '',
          latitude: (json['latitude'] ?? 0.0).toDouble(),
          longitude: (json['longitude'] ?? 0.0).toDouble(),
          maxCapacity: json['maxCapacity'] ?? 0,
          currentParticipants: json['currentParticipants'] ?? 0,
          imageUrl: json['imageUrl'],
          organizerId: json['organizerId'] ?? '',
          organizerName: json['organizerName'] ?? '',
          participantIds: List<String>.from(json['participantIds'] ?? []),
          createdAt: json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.now(),
          updatedAt: json['updatedAt'] is DateTime
              ? json['updatedAt']
              : DateTime.now(),
          isActive: json['isActive'] ?? true,
          isPaid: json['isPaid'] ?? false,
          price: json['price']?.toDouble(),
          currency: json['currency'] ?? 'GNF',
          soldTickets: json['soldTickets'] ?? 0,
          category: json['category'],
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des événements: $e');
      return [];
    }
  }

  /// Sauvegarder les événements auxquels l'utilisateur est inscrit
  Future<bool> cacheRegisteredEvents(List<String> eventIds) async {
    try {
      final jsonString = jsonEncode(eventIds);
      await _prefs.setString(_registeredEventsKey, jsonString);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde des inscriptions: $e');
      return false;
    }
  }

  /// Récupérer les IDs des événements inscrits
  Future<List<String>> getCachedRegisteredEventIds() async {
    try {
      final jsonString = _prefs.getString(_registeredEventsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((e) => e.toString()).toList();
    } catch (e) {
      print('Erreur lors de la récupération des inscriptions: $e');
      return [];
    }
  }

  // ==================== PROFIL UTILISATEUR ====================

  /// Sauvegarder le profil utilisateur
  Future<bool> cacheUserProfile(Map<String, dynamic> profile) async {
    try {
      final jsonString = jsonEncode(profile);
      await _prefs.setString(_userProfileKey, jsonString);
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde du profil: $e');
      return false;
    }
  }

  /// Récupérer le profil utilisateur
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    try {
      final jsonString = _prefs.getString(_userProfileKey);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  // ==================== SYNCHRONISATION ====================

  /// Mettre à jour le timestamp de dernière synchronisation
  Future<void> _updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Récupérer le timestamp de dernière synchronisation
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Vérifier si le cache est obsolète (plus de 24h)
  Future<bool> isCacheStale() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference.inHours > 24;
  }

  // ==================== NETTOYAGE ====================

  /// Vider tout le cache
  Future<bool> clearCache() async {
    try {
      await _prefs.remove(_eventsKey);
      await _prefs.remove(_userProfileKey);
      await _prefs.remove(_registeredEventsKey);
      await _prefs.remove(_lastSyncKey);
      return true;
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
      return false;
    }
  }

  /// Vider uniquement le cache des événements
  Future<bool> clearEventsCache() async {
    try {
      await _prefs.remove(_eventsKey);
      return true;
    } catch (e) {
      print('Erreur lors du nettoyage du cache des événements: $e');
      return false;
    }
  }

  /// Vider uniquement le cache du profil
  Future<bool> clearProfileCache() async {
    try {
      await _prefs.remove(_userProfileKey);
      return true;
    } catch (e) {
      print('Erreur lors du nettoyage du cache du profil: $e');
      return false;
    }
  }

  // ==================== STATISTIQUES ====================

  /// Obtenir la taille du cache (approximative)
  Future<Map<String, int>> getCacheSize() async {
    int eventsSize = _prefs.getString(_eventsKey)?.length ?? 0;
    int profileSize = _prefs.getString(_userProfileKey)?.length ?? 0;
    int registeredSize = _prefs.getString(_registeredEventsKey)?.length ?? 0;

    return {
      'events': eventsSize,
      'profile': profileSize,
      'registered': registeredSize,
      'total': eventsSize + profileSize + registeredSize,
    };
  }

  /// Vérifier si des données sont en cache
  Future<bool> hasCache() async {
    return _prefs.containsKey(_eventsKey) ||
        _prefs.containsKey(_userProfileKey) ||
        _prefs.containsKey(_registeredEventsKey);
  }
}
