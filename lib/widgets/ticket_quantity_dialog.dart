import 'package:flutter/material.dart';

/// Dialog pour sélectionner la quantité de tickets et les noms des participants
class TicketQuantityDialog extends StatefulWidget {
  final int maxQuantity;
  final double ticketPrice;
  final String currency;

  const TicketQuantityDialog({
    super.key,
    this.maxQuantity = 10,
    required this.ticketPrice,
    required this.currency,
  });

  @override
  State<TicketQuantityDialog> createState() => _TicketQuantityDialogState();
}

class _TicketQuantityDialogState extends State<TicketQuantityDialog> {
  int _quantity = 1;
  final List<TextEditingController> _nameControllers = [];
  bool _showNames = false;

  @override
  void initState() {
    super.initState();
    _nameControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
      
      // Ajuster le nombre de contrôleurs
      while (_nameControllers.length < _quantity) {
        _nameControllers.add(TextEditingController());
      }
      while (_nameControllers.length > _quantity) {
        _nameControllers.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = _quantity * widget.ticketPrice;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              Text(
                'Nombre de tickets',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Sélecteur de quantité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantité',
                      style: theme.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => _updateQuantity(_quantity - 1)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: theme.colorScheme.primary,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantity < widget.maxQuantity
                              ? () => _updateQuantity(_quantity + 1)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Prix total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} ${widget.currency}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Option pour ajouter les noms
              if (_quantity > 1) ...[
                CheckboxListTile(
                  value: _showNames,
                  onChanged: (value) {
                    setState(() {
                      _showNames = value ?? false;
                    });
                  },
                  title: Text(
                    'Ajouter les noms des participants',
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: const Text('(Optionnel)'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
              ],

              // Champs pour les noms
              if (_showNames && _quantity > 1) ...[
                Text(
                  'Noms des participants',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_quantity, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _nameControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Participant ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final names = _showNames
                            ? _nameControllers
                                .map((c) => c.text.trim())
                                .where((name) => name.isNotEmpty)
                                .toList()
                            : null;
                        
                        Navigator.pop(context, {
                          'quantity': _quantity,
                          'names': names,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continuer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
