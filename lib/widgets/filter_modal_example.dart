import 'package:flutter/material.dart';
import 'filter_modal.dart';

/// Exemple d'utilisation du FilterModal
class FilterModalExample extends StatefulWidget {
  const FilterModalExample({super.key});

  @override
  State<FilterModalExample> createState() => _FilterModalExampleState();
}

class _FilterModalExampleState extends State<FilterModalExample> {
  Map<String, List<String>> _appliedFilters = {};
  int _filteredCount = 0;

  /// Ouvrir le modal de filtres
  Future<void> _openFilterModal() async {
    // Définir les sections de filtres
    final sections = [
      FilterSection(
        id: 'category',
        title: 'Catégorie',
        allowMultiple: true,
        isExpanded: true,
        options: [
          FilterOption(id: 'sport', label: 'Sport', count: 15),
          FilterOption(id: 'culture', label: 'Culture', count: 8),
          FilterOption(id: 'musique', label: 'Musique', count: 12),
          FilterOption(id: 'technologie', label: 'Technologie', count: 5),
          FilterOption(id: 'autre', label: 'Autre', count: 3),
        ],
      ),
      FilterSection(
        id: 'type',
        title: 'Type d\'événement',
        allowMultiple: false, // Radio buttons
        isExpanded: true,
        options: [
          FilterOption(id: 'all', label: 'Tous', count: 43),
          FilterOption(id: 'free', label: 'Gratuit', count: 25),
          FilterOption(id: 'paid', label: 'Payant', count: 18),
        ],
      ),
      FilterSection(
        id: 'price',
        title: 'Prix',
        allowMultiple: true,
        options: [
          FilterOption(id: 'free', label: 'Gratuit', count: 25),
          FilterOption(id: '0-5000', label: '0 - 5 000 GNF', count: 8),
          FilterOption(id: '5000-10000', label: '5 000 - 10 000 GNF', count: 6),
          FilterOption(id: '10000+', label: '10 000+ GNF', count: 4),
        ],
      ),
      FilterSection(
        id: 'date',
        title: 'Période',
        allowMultiple: false,
        options: [
          FilterOption(id: 'all', label: 'Toutes les dates', count: 43),
          FilterOption(id: 'today', label: 'Aujourd\'hui', count: 3),
          FilterOption(id: 'week', label: 'Cette semaine', count: 12),
          FilterOption(id: 'month', label: 'Ce mois', count: 28),
        ],
      ),
      FilterSection(
        id: 'capacity',
        title: 'Taille de l\'événement',
        allowMultiple: true,
        options: [
          FilterOption(id: 'small', label: 'Petit (≤50)', count: 15),
          FilterOption(id: 'medium', label: 'Moyen (51-200)', count: 20),
          FilterOption(id: 'large', label: 'Grand (>200)', count: 8),
        ],
      ),
      FilterSection(
        id: 'region',
        title: 'Région',
        allowMultiple: true,
        options: [
          FilterOption(id: 'conakry', label: 'Conakry', count: 30),
          FilterOption(id: 'kindia', label: 'Kindia', count: 5),
          FilterOption(id: 'boke', label: 'Boké', count: 3),
          FilterOption(id: 'labe', label: 'Labé', count: 2),
          FilterOption(id: 'nzerekore', label: 'Nzérékoré', count: 3),
        ],
      ),
    ];

    // Afficher le modal
    final result = await FilterModal.show(
      context: context,
      sections: sections,
      initialFilters: _appliedFilters,
      title: 'Filtrer les événements',
      applyButtonText: 'APPLIQUER LES FILTRES',
      resetButtonText: 'Tout effacer',
    );

    // Traiter le résultat
    if (result != null && result.hasChanges) {
      setState(() {
        _appliedFilters = result.selectedFilters;
        _filteredCount = _calculateFilteredCount(result.selectedFilters);
      });

      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _appliedFilters.isEmpty
                  ? 'Tous les filtres ont été supprimés'
                  : 'Filtres appliqués : $_filteredCount événements trouvés',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Calculer le nombre d'événements filtrés (exemple)
  int _calculateFilteredCount(Map<String, List<String>> filters) {
    // Logique de calcul basée sur vos données réelles
    if (filters.isEmpty) return 43; // Tous les événements
    
    // Exemple simplifié
    int count = 43;
    if (filters.containsKey('category')) {
      count = count ~/ 2;
    }
    if (filters.containsKey('type')) {
      count = count ~/ 2;
    }
    return count.clamp(1, 43);
  }

  /// Obtenir le nombre total de filtres actifs
  int get _activeFiltersCount {
    return _appliedFilters.values
        .fold(0, (sum, list) => sum + list.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple de Filtres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton pour ouvrir les filtres
            ElevatedButton.icon(
              onPressed: _openFilterModal,
              icon: Badge(
                label: Text('$_activeFiltersCount'),
                isLabelVisible: _activeFiltersCount > 0,
                child: const Icon(Icons.filter_list),
              ),
              label: Text(
                _activeFiltersCount > 0
                    ? 'Filtres ($_activeFiltersCount)'
                    : 'Filtres',
              ),
            ),

            const SizedBox(height: 24),

            // Afficher les filtres actifs
            if (_appliedFilters.isNotEmpty) ...[
              Text(
                'Filtres actifs :',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _appliedFilters.entries.expand((entry) {
                  return entry.value.map((value) => Chip(
                    label: Text('${entry.key}: $value'),
                    onDeleted: () {
                      setState(() {
                        entry.value.remove(value);
                        if (entry.value.isEmpty) {
                          _appliedFilters.remove(entry.key);
                        }
                        _filteredCount = _calculateFilteredCount(_appliedFilters);
                      });
                    },
                  ));
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Résultats
            Text(
              _appliedFilters.isEmpty
                  ? 'Tous les événements (43)'
                  : 'Événements filtrés : $_filteredCount',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
