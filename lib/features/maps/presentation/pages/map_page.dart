import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/providers/map_provider.dart';
import '../../../../data/providers/events_provider.dart';
// import '../../../../widgets/custom_button.dart'; // Non utilisé
import '../../../../widgets/loading_widget.dart';

/// Page de carte avec Google Maps
class MapPage extends ConsumerStatefulWidget {
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
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.latitude != null && widget.longitude != null) {
      _selectedLocation = LatLng(widget.latitude!, widget.longitude!);
      _addMarker(_selectedLocation!, widget.title ?? 'Lieu sélectionné');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = ref.watch(eventsProvider);

    // Sur le web, afficher un message temporaire car Google Maps nécessite une API key
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carte des événements'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Carte non disponible sur le web',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'La fonctionnalité de carte nécessite une clé API Google Maps.\n\n'
                  'Utilisez l\'application mobile pour accéder à la carte interactive.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchLocation,
          ),
        ],
      ),
      body: events.when(
        data: (eventsList) => Stack(
          children: [
            // Carte Google Maps
            _buildGoogleMap(),
            // Boutons de contrôle
            _buildControlButtons(theme),
            // Liste des événements
            if (eventsList.isNotEmpty)
              _buildEventsList(theme, eventsList),
          ],
        ),
        loading: () => const Center(child: LoadingWidget(message: 'Chargement...')),
        error: (error, stack) => Center(
          child: Text('Erreur: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Chargement de la carte...'),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _loadEventsOnMap();
      },
      initialCameraPosition: CameraPosition(
        target: _selectedLocation ?? const LatLng(9.6412, -13.5784), // Conakry
        zoom: 12.0,
      ),
      markers: _markers,
      onTap: (LatLng position) {
        _onMapTapped(position);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  Widget _buildControlButtons(ThemeData theme) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: _zoomIn,
            mini: true,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: _zoomOut,
            mini: true,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ThemeData theme, List events) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Événements à proximité',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Liste des événements
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(theme, event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(ThemeData theme, event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.event,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          event.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.location),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${event.currentParticipants}/${event.maxCapacity}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.directions),
          onPressed: () => _goToEvent(event),
        ),
        onTap: () => _goToEvent(event),
      ),
    );
  }

  void _loadEventsOnMap() {
    final eventsAsync = ref.read(eventsProvider);
    eventsAsync.whenData((events) {
      for (final event in events) {
        _addEventMarker(event);
      }
    });
  }

  void _addEventMarker(event) {
    final marker = Marker(
      markerId: MarkerId(event.id),
      position: LatLng(event.latitude, event.longitude),
      infoWindow: InfoWindow(
        title: event.title,
        snippet: event.location,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        event.isFull ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
      ),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  void _addMarker(LatLng position, String title) {
    final marker = Marker(
      markerId: MarkerId('selected_location'),
      position: position,
      infoWindow: InfoWindow(
        title: title,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _addMarker(position, 'Lieu sélectionné');
    });
  }

  void _goToEvent(event) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(event.latitude ?? 0.0, event.longitude ?? 0.0),
          15.0,
        ),
      );
    }
  }

  void _goToCurrentLocation() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      if (_mapController != null && mounted && position != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de localisation: $e'),
          ),
        );
      }
    }
  }

  void _searchLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un lieu'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Entrez une adresse...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la recherche de lieu
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de recherche à implémenter'),
                ),
              );
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }
}
