import 'package:flutter/material.dart';
import 'openstreetmap_page.dart';

/// Page de carte - Redirige vers OpenStreetMap
class MapPage extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? title;

  const MapPage({
    super.key,
    this.latitude,
    this.longitude,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Rediriger simplement vers OpenStreetMap
    return const OpenStreetMapPage();
  }
}
