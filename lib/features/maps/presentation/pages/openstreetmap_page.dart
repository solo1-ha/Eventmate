import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Page de carte interactive avec OpenStreetMap
/// Centrée sur Conakry, Guinée
class OpenStreetMapPage extends StatefulWidget {
  const OpenStreetMapPage({super.key});

  @override
  State<OpenStreetMapPage> createState() => _OpenStreetMapPageState();
}

class _OpenStreetMapPageState extends State<OpenStreetMapPage> {
  // Contrôleur de la carte
  final MapController _mapController = MapController();

  // Coordonnées de Conakry
  static const LatLng conakryCenter = LatLng(9.6412, -13.5784);

  // Coordonnées du Stade du 28 Septembre
  static const LatLng stade28Septembre = LatLng(9.5092, -13.7122);

  // Zoom par défaut
  static const double defaultZoom = 13.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte de Conakry'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Carte OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Centre initial sur Conakry
              initialCenter: conakryCenter,
              // Zoom par défaut
              initialZoom: defaultZoom,
              // Limites de zoom
              minZoom: 5.0,
              maxZoom: 18.0,
              // Permet l'interaction
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Tuiles OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eventmate.app',
                // Configuration pour de meilleures performances
                tileProvider: NetworkTileProvider(),
              ),
              
              // Marqueurs
              MarkerLayer(
                markers: [
                  // Marqueur sur le Stade du 28 Septembre
                  Marker(
                    point: stade28Septembre,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _showMarkerInfo(context),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Stade',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Marqueur sur le centre de Conakry
                  Marker(
                    point: conakryCenter,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
              
              // Attribution (obligatoire pour OpenStreetMap)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          
          // Bouton pour recentrer sur Conakry
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _recenterOnConakry,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              tooltip: 'Recentrer sur Conakry',
              child: const Icon(Icons.my_location),
            ),
          ),
          
          // Bouton de zoom +
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _zoomIn,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              tooltip: 'Zoomer',
              child: const Icon(Icons.add),
            ),
          ),
          
          // Bouton de zoom -
          Positioned(
            bottom: 230,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _zoomOut,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              tooltip: 'Dézoomer',
              child: const Icon(Icons.remove),
            ),
          ),
          
          // Carte d'information en haut
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Carte Interactive de Conakry',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explorez les lieux d\'événements à Conakry',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '📍 Cliquez sur les marqueurs pour plus d\'infos',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recentrer la carte sur Conakry
  void _recenterOnConakry() {
    _mapController.move(conakryCenter, defaultZoom);
  }

  /// Zoomer
  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  /// Dézoomer
  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  /// Afficher les informations du marqueur
  void _showMarkerInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.stadium,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Stade du 28 Septembre'),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lieu d\'événements majeurs à Conakry.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Kaloum, Conakry, Guinée',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Concerts, matchs, cérémonies',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _mapController.move(stade28Septembre, 16.0);
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Aller au lieu'),
          ),
        ],
      ),
    );
  }
}
