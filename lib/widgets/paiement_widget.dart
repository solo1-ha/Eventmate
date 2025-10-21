import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget pour simuler un paiement Orange Money
class PaiementWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final Function(String phoneNumber) onPaymentSuccess;

  const PaiementWidget({
    super.key,
    required this.amount,
    required this.currency,
    required this.onPaymentSuccess,
  });

  @override
  State<PaiementWidget> createState() => _PaiementWidgetState();
}

class _PaiementWidgetState extends State<PaiementWidget> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Simule le processus de paiement
  Future<void> _processPayment() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une vérification du numéro
      await Future.delayed(const Duration(milliseconds: 500));

      // Simuler la confirmation du paiement
      await Future.delayed(const Duration(seconds: 1));

      // Paiement réussi
      if (mounted) {
        widget.onPaymentSuccess(_phoneController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de paiement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo Orange Money
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Orange Money',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Montant à payer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Montant à payer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.amount.toStringAsFixed(0)} ${widget.currency}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Numéro de téléphone
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Numéro Orange Money',
            hintText: '622 XX XX XX',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          enabled: !_isProcessing,
        ),

        const SizedBox(height: 16),

        // Accepter les conditions
        CheckboxListTile(
          value: _acceptTerms,
          onChanged: _isProcessing
              ? null
              : (value) {
                  setState(() => _acceptTerms = value ?? false);
                },
          title: Text(
            'J\'accepte les conditions de paiement',
            style: theme.textTheme.bodyMedium,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 24),

        // Bouton de paiement
        if (_isProcessing)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Traitement du paiement...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Veuillez patienter',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _processPayment,
            icon: const Icon(Icons.payment),
            label: const Text('Payer maintenant'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),

        const SizedBox(height: 16),

        // Informations de sécurité
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Paiement sécurisé. Vos données sont protégées.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Note de simulation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mode simulation : Aucun paiement réel ne sera effectué',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
