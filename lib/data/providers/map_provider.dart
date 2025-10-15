import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Modèle pour la position
class PositionModel {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;

  const PositionModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
  });

  @override
  String toString() {
    return 'PositionModel(lat: $latitude, lng: $longitude, address: $address)';
  }
}

/// Provider pour la position actuelle
final currentPositionProvider = FutureProvider<PositionModel?>((ref) async {
  try {
    // Vérification des permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissions de localisation refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissions de localisation définitivement refusées');
    }

    // Récupération de la position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Géocodage inverse pour obtenir l'adresse
    String? address;
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address = '${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      // Ignorer l'erreur de géocodage
    }

    return PositionModel(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      accuracy: position.accuracy,
    );
  } catch (e) {
    throw Exception('Impossible d\'obtenir la position: $e');
  }
});

/// Provider pour la recherche d'adresse
final addressSearchProvider = FutureProvider.family<String?, String>((ref, query) async {
  if (query.isEmpty) return null;

  try {
    final locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      final location = locations.first;
      return '${location.latitude}, ${location.longitude}';
    }
  } catch (e) {
    // Ignorer l'erreur de recherche
  }
  return null;
});

/// Provider pour la géolocalisation d'une adresse
final geocodeAddressProvider = FutureProvider.family<PositionModel?, String>((ref, address) async {
  if (address.isEmpty) return null;

  try {
    final locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final location = locations.first;
      return PositionModel(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
      );
    }
  } catch (e) {
    // Ignorer l'erreur de géocodage
  }
  return null;
});

/// Provider pour la géolocalisation inverse
final reverseGeocodeProvider = FutureProvider.family<String?, Map<String, double>>((ref, coordinates) async {
  try {
    final placemarks = await placemarkFromCoordinates(
      coordinates['latitude']!,
      coordinates['longitude']!,
    );
    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
    }
  } catch (e) {
    // Ignorer l'erreur de géocodage inverse
  }
  return null;
});

/// Provider pour les permissions de localisation
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.checkPermission();
});

/// Provider pour vérifier si la localisation est activée
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  return await Geolocator.isLocationServiceEnabled();
});

