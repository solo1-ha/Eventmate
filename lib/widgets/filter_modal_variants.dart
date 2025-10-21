import 'package:flutter/material.dart';
import 'filter_modal.dart';

/// Variantes de design pour le FilterModal
/// 
/// Ce fichier contient différentes variantes de style et de comportement
/// pour le FilterModal, adaptées à différents cas d'usage.

// ============================================================================
// VARIANTE 1 : Modal Compact (pour petits écrans)
// ============================================================================

class CompactFilterModal extends StatelessWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;

  const CompactFilterModal({
    super.key,
    required this.sections,
    this.initialFilters,
  });

  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    Map<String, List<String>>? initialFilters,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompactFilterModal(
        sections: sections,
        initialFilters: initialFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.size.height * 0.6, // Plus compact
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: FilterModal(
        sections: sections,
        initialFilters: initialFilters,
        title: 'Filtres',
        applyButtonText: 'OK',
        resetButtonText: 'Effacer',
      ),
    );
  }
}

// ============================================================================
// VARIANTE 2 : Modal Plein Écran (pour beaucoup de filtres)
// ============================================================================

class FullScreenFilterModal extends StatelessWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;

  const FullScreenFilterModal({
    super.key,
    required this.sections,
    this.initialFilters,
  });

  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    Map<String, List<String>>? initialFilters,
  }) {
    return Navigator.push<FilterResult>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenFilterModal(
          sections: sections,
          initialFilters: initialFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtres'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FilterModal(
        sections: sections,
        initialFilters: initialFilters,
        title: 'Sélectionnez vos filtres',
      ),
    );
  }
}

// ============================================================================
// VARIANTE 3 : Modal avec Recherche Intégrée
// ============================================================================

class SearchableFilterModal extends StatefulWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;

  const SearchableFilterModal({
    super.key,
    required this.sections,
    this.initialFilters,
  });

  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    Map<String, List<String>>? initialFilters,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableFilterModal(
        sections: sections,
        initialFilters: initialFilters,
      ),
    );
  }

  @override
  State<SearchableFilterModal> createState() => _SearchableFilterModalState();
}

class _SearchableFilterModalState extends State<SearchableFilterModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late List<FilterSection> _filteredSections;

  @override
  void initState() {
    super.initState();
    _filteredSections = widget.sections;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSections(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredSections = widget.sections;
      } else {
        _filteredSections = widget.sections.map((section) {
          final filteredOptions = section.options
              .where((option) => option.label.toLowerCase().contains(_searchQuery))
              .toList();
          
          return section.copyWith(
            options: filteredOptions,
            isExpanded: filteredOptions.isNotEmpty,
          );
        }).where((section) => section.options.isNotEmpty).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header avec recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un filtre...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterSections('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterSections,
                ),
              ],
            ),
          ),
          // Sections filtrées
          Expanded(
            child: FilterModal(
              sections: _filteredSections,
              initialFilters: widget.initialFilters,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VARIANTE 4 : Modal avec Aperçu des Résultats
// ============================================================================

class PreviewFilterModal extends StatefulWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;
  final int totalResults;
  final Function(Map<String, List<String>>) onPreview;

  const PreviewFilterModal({
    super.key,
    required this.sections,
    required this.totalResults,
    required this.onPreview,
    this.initialFilters,
  });

  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    required int totalResults,
    required Function(Map<String, List<String>>) onPreview,
    Map<String, List<String>>? initialFilters,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreviewFilterModal(
        sections: sections,
        totalResults: totalResults,
        onPreview: onPreview,
        initialFilters: initialFilters,
      ),
    );
  }

  @override
  State<PreviewFilterModal> createState() => _PreviewFilterModalState();
}

class _PreviewFilterModalState extends State<PreviewFilterModal> {
  late Map<String, List<String>> _currentFilters;
  int _previewCount = 0;

  @override
  void initState() {
    super.initState();
    _currentFilters = Map.from(widget.initialFilters ?? {});
    _previewCount = widget.totalResults;
  }

  void _updatePreview(Map<String, List<String>> filters) {
    setState(() {
      _currentFilters = filters;
      // Appeler la fonction de prévisualisation
      widget.onPreview(filters);
      // Ici vous devriez calculer le nombre réel de résultats
      _previewCount = widget.totalResults; // À remplacer par le calcul réel
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Preview banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.preview,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_previewCount résultats trouvés',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Modal de filtres
          Expanded(
            child: FilterModal(
              sections: widget.sections,
              initialFilters: widget.initialFilters,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VARIANTE 5 : Modal avec Filtres Rapides (Quick Filters)
// ============================================================================

class QuickFilterModal extends StatelessWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;
  final List<QuickFilter> quickFilters;

  const QuickFilterModal({
    super.key,
    required this.sections,
    required this.quickFilters,
    this.initialFilters,
  });

  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    required List<QuickFilter> quickFilters,
    Map<String, List<String>>? initialFilters,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickFilterModal(
        sections: sections,
        quickFilters: quickFilters,
        initialFilters: initialFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Quick filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtres rapides',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: quickFilters.map((qf) => ActionChip(
                    label: Text(qf.label),
                    avatar: Icon(qf.icon, size: 18),
                    onPressed: () {
                      // Appliquer le filtre rapide
                      Navigator.pop(
                        context,
                        FilterResult(
                          selectedFilters: qf.filters,
                          hasChanges: true,
                        ),
                      );
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          // Modal de filtres standard
          Expanded(
            child: FilterModal(
              sections: sections,
              initialFilters: initialFilters,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modèle pour un filtre rapide
class QuickFilter {
  final String label;
  final IconData icon;
  final Map<String, List<String>> filters;

  const QuickFilter({
    required this.label,
    required this.icon,
    required this.filters,
  });
}

// Exemples de filtres rapides
final quickFiltersExamples = [
  QuickFilter(
    label: 'Gratuit',
    icon: Icons.money_off,
    filters: {'type': ['free']},
  ),
  QuickFilter(
    label: 'Cette semaine',
    icon: Icons.calendar_today,
    filters: {'date': ['week']},
  ),
  QuickFilter(
    label: 'Sport',
    icon: Icons.sports_soccer,
    filters: {'category': ['sport']},
  ),
  QuickFilter(
    label: 'Populaires',
    icon: Icons.trending_up,
    filters: {'capacity': ['large']},
  ),
];
