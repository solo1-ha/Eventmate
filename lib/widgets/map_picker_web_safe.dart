import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Widget pour sélectionner un lieu - Version compatible Web
class MapPickerWebSafe extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const MapPickerWebSafe({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<MapPickerWebSafe> createState() => _MapPickerWebSafeState();
}

class _MapPickerWebSafeState extends State<MapPickerWebSafe> {
  double _latitude = 9.5092;
  double _longitude = -13.7122;
  String _address = '';
  bool _isLoading = false;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latitude = widget.initialLatitude!;
      _longitude = widget.initialLongitude!;
      _address = widget.initialAddress ?? '';
      _addressController.text = _address;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Version Web simplifiée (sans Google Maps)
      return _buildWebVersion();
    } else {
      // Version mobile avec Google Maps
      return _buildMobileVersion();
    }
  }

  /// Version Web - Formulaire simple
  Widget _buildWebVersion() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un lieu'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _latitude,
                'longitude': _longitude,
                'address': _address,
              });
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message d'information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Version Web : Entrez manuellement les coordonnées ou l\'adresse',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Adresse
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                hintText: 'Ex: Conakry, Guinée',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _address = value);
              },
            ),
            const SizedBox(height: 16),

            // Latitude
            TextField(
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Ex: 9.5092',
                prefixIcon: Icon(Icons.map),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(text: _latitude.toString()),
              onChanged: (value) {
                setState(() {
                  _latitude = double.tryParse(value) ?? _latitude;
                });
              },
            ),
            const SizedBox(height: 16),

            // Longitude
            TextField(
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Ex: -13.7122',
                prefixIcon: Icon(Icons.map),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(text: _longitude.toString()),
              onChanged: (value) {
                setState(() {
                  _longitude = double.tryParse(value) ?? _longitude;
                });
              },
            ),
            const SizedBox(height: 24),

            // Lieux prédéfinis à Conakry
            const Text(
              'Lieux populaires à Conakry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildLocationCard(
              'Stade du 28 Septembre',
              9.5092,
              -13.7122,
              Icons.stadium,
            ),
            _buildLocationCard(
              'Centre-ville de Conakry',
              9.5370,
              -13.6785,
              Icons.location_city,
            ),
            _buildLocationCard(
              'Port de Conakry',
              9.5100,
              -13.7172,
              Icons.directions_boat,
            ),
            _buildLocationCard(
              'Aéroport International',
              9.5769,
              -13.6120,
              Icons.flight,
            ),
          ],
        ),
      ),
    );
  }

  /// Carte de lieu prédéfini
  Widget _buildLocationCard(String name, double lat, double lng, IconData icon) {
    final isSelected = _latitude == lat && _longitude == lng;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : null),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : null,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        subtitle: Text('$lat, $lng'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            _latitude = lat;
            _longitude = lng;
            _address = name;
            _addressController.text = name;
          });
        },
      ),
    );
  }

  /// Version Mobile avec Google Maps (à implémenter si nécessaire)
  Widget _buildMobileVersion() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un lieu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Google Maps non configuré',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Utilisez la version web ou configurez Google Maps',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': _latitude,
                  'longitude': _longitude,
                  'address': _address,
                });
              },
              child: const Text('Utiliser Conakry par défaut'),
            ),
          ],
        ),
      ),
    );
  }
}
