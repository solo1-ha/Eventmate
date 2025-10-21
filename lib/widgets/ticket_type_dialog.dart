import 'package:flutter/material.dart';

/// Dialog pour ajouter/modifier un type de ticket
class TicketTypeDialog extends StatefulWidget {
  final String? initialType;
  final double? initialPrice;
  final Function(String type, double price) onSave;

  const TicketTypeDialog({
    super.key,
    this.initialType,
    this.initialPrice,
    required this.onSave,
  });

  @override
  State<TicketTypeDialog> createState() => _TicketTypeDialogState();
}

class _TicketTypeDialogState extends State<TicketTypeDialog> {
  late final TextEditingController _typeController;
  late final TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.initialType ?? '');
    _priceController = TextEditingController(
      text: widget.initialPrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialType == null ? 'Ajouter un ticket' : 'Modifier le ticket'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type de ticket',
                hintText: 'Ex: Standard, VIP, Super VIP',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix (GNF)',
                hintText: 'Ex: 5000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un prix';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Prix invalide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _typeController.text.trim(),
                double.parse(_priceController.text),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
