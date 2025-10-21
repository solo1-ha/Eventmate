import 'package:flutter/material.dart';

/// Modèle de données pour une option de filtre
class FilterOption {
  final String id;
  final String label;
  final int count;
  bool isSelected;

  FilterOption({
    required this.id,
    required this.label,
    required this.count,
    this.isSelected = false,
  });

  FilterOption copyWith({
    String? id,
    String? label,
    int? count,
    bool? isSelected,
  }) {
    return FilterOption(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Modèle de données pour une section de filtre
class FilterSection {
  final String id;
  final String title;
  final List<FilterOption> options;
  final bool allowMultiple; // true = checkbox, false = radio
  bool isExpanded;

  FilterSection({
    required this.id,
    required this.title,
    required this.options,
    this.allowMultiple = true,
    this.isExpanded = false,
  });

  FilterSection copyWith({
    String? id,
    String? title,
    List<FilterOption>? options,
    bool? allowMultiple,
    bool? isExpanded,
  }) {
    return FilterSection(
      id: id ?? this.id,
      title: title ?? this.title,
      options: options ?? this.options,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Résultat du filtre à retourner
class FilterResult {
  final Map<String, List<String>> selectedFilters;
  final bool hasChanges;

  FilterResult({
    required this.selectedFilters,
    required this.hasChanges,
  });
}

/// Modal de filtres principal
class FilterModal extends StatefulWidget {
  final List<FilterSection> sections;
  final Map<String, List<String>>? initialFilters;
  final String title;
  final String applyButtonText;
  final String resetButtonText;

  const FilterModal({
    super.key,
    required this.sections,
    this.initialFilters,
    this.title = 'Filtres',
    this.applyButtonText = 'APPLIQUER',
    this.resetButtonText = 'Réinitialiser',
  });

  @override
  State<FilterModal> createState() => _FilterModalState();

  /// Méthode statique pour afficher le modal
  static Future<FilterResult?> show({
    required BuildContext context,
    required List<FilterSection> sections,
    Map<String, List<String>>? initialFilters,
    String? title,
    String? applyButtonText,
    String? resetButtonText,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        sections: sections,
        initialFilters: initialFilters,
        title: title ?? 'Filtres',
        applyButtonText: applyButtonText ?? 'APPLIQUER',
        resetButtonText: resetButtonText ?? 'Réinitialiser',
      ),
    );
  }
}

class _FilterModalState extends State<FilterModal> {
  late List<FilterSection> _sections;
  late Map<String, List<String>> _initialFilters;
  late Map<String, List<String>> _currentFilters;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _sections = widget.sections.map((s) => s.copyWith(
      options: s.options.map((o) => o.copyWith()).toList(),
    )).toList();
    
    _initialFilters = Map.from(widget.initialFilters ?? {});
    _currentFilters = Map.from(_initialFilters);
    
    // Appliquer les filtres initiaux
    _applyInitialFilters();
  }

  void _applyInitialFilters() {
    for (var section in _sections) {
      final selectedIds = _currentFilters[section.id] ?? [];
      for (var option in section.options) {
        option.isSelected = selectedIds.contains(option.id);
      }
    }
  }

  void _checkForChanges() {
    bool hasChanges = false;
    
    for (var section in _sections) {
      final currentSelected = section.options
          .where((o) => o.isSelected)
          .map((o) => o.id)
          .toList();
      final initialSelected = _initialFilters[section.id] ?? [];
      
      if (currentSelected.length != initialSelected.length ||
          !currentSelected.every((id) => initialSelected.contains(id))) {
        hasChanges = true;
        break;
      }
    }
    
    setState(() {
      _hasChanges = hasChanges;
    });
  }

  void _toggleSection(int index) {
    setState(() {
      _sections[index].isExpanded = !_sections[index].isExpanded;
    });
  }

  void _toggleOption(FilterSection section, FilterOption option) {
    setState(() {
      if (section.allowMultiple) {
        // Mode checkbox
        option.isSelected = !option.isSelected;
      } else {
        // Mode radio - désélectionner les autres
        for (var opt in section.options) {
          opt.isSelected = opt.id == option.id;
        }
      }
      
      // Mettre à jour les filtres actuels
      _updateCurrentFilters(section);
      _checkForChanges();
    });
  }

  void _updateCurrentFilters(FilterSection section) {
    final selectedIds = section.options
        .where((o) => o.isSelected)
        .map((o) => o.id)
        .toList();
    
    if (selectedIds.isEmpty) {
      _currentFilters.remove(section.id);
    } else {
      _currentFilters[section.id] = selectedIds;
    }
  }

  void _resetFilters() {
    setState(() {
      for (var section in _sections) {
        for (var option in section.options) {
          option.isSelected = false;
        }
      }
      _currentFilters.clear();
      _hasChanges = true;
    });
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      FilterResult(
        selectedFilters: Map.from(_currentFilters),
        hasChanges: _hasChanges,
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
          // Header
          FilterHeader(
            title: widget.title,
            onClose: () => Navigator.pop(context),
            onReset: _hasChanges ? _resetFilters : null,
            resetButtonText: widget.resetButtonText,
          ),
          
          // Sections de filtres
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                return FilterSectionWidget(
                  section: _sections[index],
                  onToggleSection: () => _toggleSection(index),
                  onToggleOption: (option) => _toggleOption(_sections[index], option),
                );
              },
            ),
          ),
          
          // Bouton Apply
          ApplyButton(
            text: widget.applyButtonText,
            isEnabled: _hasChanges,
            onPressed: _applyFilters,
          ),
        ],
      ),
    );
  }
}

/// Widget d'en-tête du modal
class FilterHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback? onReset;
  final String resetButtonText;

  const FilterHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.onReset,
    required this.resetButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton fermer
          Semantics(
            label: 'Fermer les filtres',
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Fermer',
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Titre
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Bouton réinitialiser
          if (onReset != null)
            TextButton(
              onPressed: onReset,
              child: Text(resetButtonText),
            ),
        ],
      ),
    );
  }
}

/// Widget de section de filtre
class FilterSectionWidget extends StatelessWidget {
  final FilterSection section;
  final VoidCallback onToggleSection;
  final Function(FilterOption) onToggleOption;

  const FilterSectionWidget({
    super.key,
    required this.section,
    required this.onToggleSection,
    required this.onToggleOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = section.options.where((o) => o.isSelected).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section (collapsible)
        InkWell(
          onTap: onToggleSection,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Icône expand/collapse
                Semantics(
                  label: section.isExpanded ? 'Réduire' : 'Développer',
                  child: Icon(
                    section.isExpanded 
                      ? Icons.remove_circle_outline 
                      : Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Titre de la section
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Badge de compteur
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Options (affichées si développé)
        if (section.isExpanded)
          ...section.options.map((option) => FilterOptionWidget(
            option: option,
            allowMultiple: section.allowMultiple,
            onToggle: () => onToggleOption(option),
          )),
        
        // Divider
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ],
    );
  }
}

/// Widget d'option de filtre
class FilterOptionWidget extends StatelessWidget {
  final FilterOption option;
  final bool allowMultiple;
  final VoidCallback onToggle;

  const FilterOptionWidget({
    super.key,
    required this.option,
    required this.allowMultiple,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = option.count == 0;
    
    return Semantics(
      label: '${option.label}, ${option.count} résultats',
      selected: option.isSelected,
      enabled: !isDisabled,
      child: InkWell(
        onTap: isDisabled ? null : onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              // Checkbox ou Radio
              if (allowMultiple)
                Semantics(
                  label: option.label,
                  child: Checkbox(
                    value: option.isSelected,
                    onChanged: isDisabled ? null : (_) => onToggle(),
                  ),
                )
              else
                Semantics(
                  label: option.label,
                  child: Radio<bool>(
                    value: true,
                    groupValue: option.isSelected,
                    onChanged: isDisabled ? null : (_) => onToggle(),
                  ),
                ),
              
              const SizedBox(width: 8),
              
              // Label
              Expanded(
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDisabled 
                      ? theme.colorScheme.onSurface.withOpacity(0.4)
                      : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Compteur
              Text(
                '(${option.count})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDisabled 
                    ? theme.colorScheme.onSurface.withOpacity(0.4)
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton d'application des filtres
class ApplyButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback onPressed;

  const ApplyButton({
    super.key,
    required this.text,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceVariant,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isEnabled 
              ? theme.colorScheme.onPrimary 
              : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
