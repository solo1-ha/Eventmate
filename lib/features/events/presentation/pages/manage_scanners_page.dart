import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/authorized_scanners_service.dart';
import '../../../../data/models/authorized_scanner_model.dart';
import '../../../../widgets/loading_widget.dart';

/// Page de gestion des scanners autorisés pour un événement
class ManageScannersPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;

  const ManageScannersPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  ConsumerState<ManageScannersPage> createState() => _ManageScannersPageState();
}

class _ManageScannersPageState extends ConsumerState<ManageScannersPage> {
  final _emailController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanners Autorisés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddScannerDialog(context),
            tooltip: 'Ajouter un scanner',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec informations
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez les personnes autorisées à scanner les tickets',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Liste des scanners autorisés
          Expanded(
            child: StreamBuilder<List<AuthorizedScannerModel>>(
              stream: AuthorizedScannersService.getAuthorizedScanners(widget.eventId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Chargement...');
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur lors du chargement',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                final scanners = snapshot.data ?? [];

                if (scanners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun scanner autorisé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez des personnes pour qu\'elles puissent\nscanner les tickets à votre place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddScannerDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un scanner'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scanners.length,
                  itemBuilder: (context, index) {
                    final scanner = scanners[index];
                    return _buildScannerCard(context, theme, scanner);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'un scanner autorisé
  Widget _buildScannerCard(
    BuildContext context,
    ThemeData theme,
    AuthorizedScannerModel scanner,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.qr_code_scanner,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          scanner.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(scanner.userEmail),
            const SizedBox(height: 4),
            Text(
              'Ajouté le ${DateFormat('dd/MM/yyyy à HH:mm').format(scanner.addedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmRemoveScanner(context, scanner),
          tooltip: 'Retirer l\'autorisation',
        ),
      ),
    );
  }

  /// Dialog pour ajouter un scanner
  Future<void> _showAddScannerDialog(BuildContext context) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez l\'adresse email de la personne que vous souhaitez autoriser à scanner les tickets.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _emailController.clear();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isSearching
                ? null
                : () async {
                    await _searchAndAddScanner(context);
                  },
            child: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  /// Rechercher et ajouter un scanner
  Future<void> _searchAndAddScanner(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Rechercher l'utilisateur
      final user = await AuthorizedScannersService.searchUserByEmail(email);

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun utilisateur trouvé avec cet email'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Ajouter le scanner
      await AuthorizedScannersService.addAuthorizedScanner(
        eventId: widget.eventId,
        userId: user['id'],
        userName: user['name'],
        userEmail: user['email'],
      );

      if (mounted) {
        _emailController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name']} a été ajouté comme scanner'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Confirmer la suppression d'un scanner
  Future<void> _confirmRemoveScanner(
    BuildContext context,
    AuthorizedScannerModel scanner,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer l\'autorisation'),
        content: Text(
          'Êtes-vous sûr de vouloir retirer l\'autorisation de scanner à ${scanner.userName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AuthorizedScannersService.removeAuthorizedScanner(
          eventId: widget.eventId,
          userId: scanner.userId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${scanner.userName} a été retiré'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
