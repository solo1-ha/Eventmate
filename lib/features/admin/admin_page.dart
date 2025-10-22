import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/delete_all_events.dart';
import '../../data/providers/auth_provider.dart';

/// Page d'administration pour gérer les événements
/// ATTENTION : Réservé aux administrateurs uniquement !
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  bool _isLoading = false;
  String? _resultMessage;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(authStateProvider);

    return userData.when(
      data: (user) {
        // Vérifier si l'utilisateur est admin
        if (user == null || !user.isAdmin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Accès refusé'),
              backgroundColor: Colors.red.shade700,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Accès Refusé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cette page est réservée aux administrateurs.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si admin, afficher la page d'administration
        return Scaffold(
          appBar: AppBar(
            title: const Text('Administration'),
            backgroundColor: Colors.red.shade700,
          ),
          body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avertissement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, 
                    size: 48, 
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ ZONE DANGEREUSE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les actions ci-dessous sont irréversibles.\nUtilisez avec précaution !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bouton : Supprimer tous les événements
            _buildActionCard(
              title: 'Supprimer TOUS les événements',
              description: 'Supprime tous les événements et inscriptions de la base de données',
              icon: Icons.delete_forever,
              color: Colors.red,
              onPressed: _isLoading ? null : () => _confirmDeleteAll(context),
            ),

            const SizedBox(height: 16),

            // Bouton : Supprimer les événements passés
            _buildActionCard(
              title: 'Supprimer les événements passés',
              description: 'Supprime uniquement les événements dont la date est dépassée',
              icon: Icons.history,
              color: Colors.orange,
              onPressed: _isLoading ? null : () => _confirmDeletePast(context),
            ),

            const SizedBox(height: 32),

            // Résultat
            if (_resultMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: _isSuccess ? Colors.green.shade300 : Colors.red.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Loader
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmation'),
          ],
        ),
        content: const Text(
          'Êtes-vous ABSOLUMENT sûr de vouloir supprimer TOUS les événements et inscriptions ?\n\n'
          'Cette action est IRRÉVERSIBLE !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OUI, SUPPRIMER TOUT'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePast(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmation'),
          ],
        ),
        content: const Text(
          'Voulez-vous supprimer tous les événements passés ?\n\n'
          'Les inscriptions liées seront également supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePastEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllEvents() async {
    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      final result = await DeleteAllEventsUtil.deleteAllEvents(
        deleteRegistrations: true,
      );

      setState(() {
        _isLoading = false;
        _isSuccess = result['success'] ?? false;
        _resultMessage = result['message'];
      });

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${result['eventsDeleted']} événements et ${result['registrationsDeleted']} inscriptions supprimés',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _resultMessage = 'Erreur : $e';
      });
    }
  }

  Future<void> _deletePastEvents() async {
    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      final result = await DeleteAllEventsUtil.deletePastEvents();

      setState(() {
        _isLoading = false;
        _isSuccess = result['success'] ?? false;
        _resultMessage = result['message'];
      });

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['eventsDeleted']} événements passés supprimés'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _resultMessage = 'Erreur : $e';
      });
    }
  }
}
