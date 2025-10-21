import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/events_provider.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../../utils/create_test_event.dart';
import 'event_participants_page.dart';
import 'edit_event_page.dart';
import 'qr_scanner_page.dart';
import '../../../events/presentation/pages/manage_scanners_page.dart';

/// Page du tableau de bord organisateur
class OrganizerDashboardPage extends ConsumerWidget {
  const OrganizerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    final myEventsAsync = ref.watch(organizerEventsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        centerTitle: true,
        actions: [
          // Bouton pour créer des événements de test
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Créer des événements de test',
            onPressed: () => _createTestEvents(context, ref, user),
          ),
        ],
      ),
      body: myEventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(organizerEventsProvider(user.id));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistiques globales
                  _buildStatsOverview(context, events),
                  const SizedBox(height: 24),

                  // Graphique des participants
                  _buildParticipantsChart(context, events),
                  const SizedBox(height: 24),

                  // Graphique des revenus (si événements payants)
                  if (events.any((e) => e.isPaid))
                    ...[
                      _buildRevenueChart(context, events),
                      const SizedBox(height: 24),
                    ],

                  // Liste des événements
                  _buildEventsList(context, events),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun événement créé',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier événement pour voir vos statistiques',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, List<EventModel> events) {
    final theme = Theme.of(context);

    final totalEvents = events.length;
    final totalParticipants = events.fold<int>(
      0,
      (sum, event) => sum + event.currentParticipants,
    );
    final totalRevenue = events.fold<double>(
      0,
      (sum, event) => sum + event.totalRevenue,
    );
    final activeEvents = events.where((e) => e.isActive && !e.isPast).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.event_rounded,
                label: 'Événements',
                value: totalEvents.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.people_rounded,
                label: 'Participants',
                value: totalParticipants.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.check_circle_rounded,
                label: 'Actifs',
                value: activeEvents.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.attach_money_rounded,
                label: 'Revenus',
                value: '${totalRevenue.toStringAsFixed(0)} GNF',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsChart(BuildContext context, List<EventModel> events) {
    final theme = Theme.of(context);

    // Prendre les 5 derniers événements
    final recentEvents = events.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants par événement',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: recentEvents.isEmpty
                  ? 100
                  : recentEvents
                      .map((e) => e.currentParticipants.toDouble())
                      .reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= recentEvents.length) {
                        return const SizedBox();
                      }
                      final event = recentEvents[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          event.title.length > 10
                              ? '${event.title.substring(0, 10)}...'
                              : event.title,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: recentEvents.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.currentParticipants.toDouble(),
                      color: theme.colorScheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context, List<EventModel> events) {
    final theme = Theme.of(context);

    final paidEvents = events.where((e) => e.isPaid).toList();
    final totalRevenue = paidEvents.fold<double>(
      0,
      (sum, event) => sum + event.totalRevenue,
    );

    if (totalRevenue == 0) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition des revenus',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: paidEvents.take(5).map((event) {
                      final percentage = (event.totalRevenue / totalRevenue) * 100;
                      return PieChartSectionData(
                        value: event.totalRevenue,
                        title: '${percentage.toStringAsFixed(0)}%',
                        color: _getColorForIndex(paidEvents.indexOf(event)),
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paidEvents.take(5).map((event) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getColorForIndex(paidEvents.indexOf(event)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.title,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEventsList(BuildContext context, List<EventModel> events) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes événements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...events.map((event) => _buildEventListItem(context, event)),
      ],
    );
  }

  Widget _buildEventListItem(BuildContext context, EventModel event) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: event.isPast
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
              child: Icon(
                event.isPast ? Icons.event_busy : Icons.event,
                color: Colors.white,
              ),
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${event.currentParticipants}/${event.maxCapacity} participants',
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} à ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            trailing: event.isPaid
                ? Chip(
                    label: Text(event.formattedPrice),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  )
                : const Chip(label: Text('Gratuit')),
          ),
          const Divider(height: 1),
          // Boutons d'action (ligne 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Voir les participants
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _viewParticipants(context, event),
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('Participants'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                // Gérer les scanners
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _manageScanners(context, event),
                    icon: const Icon(Icons.admin_panel_settings, size: 18),
                    label: const Text('Scanners'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                // Scanner QR
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _scanTickets(context, event),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scanner'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Boutons d'action (ligne 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Modifier
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _editEvent(context, event),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                // Supprimer
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteEvent(context, event),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Supprimer'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewParticipants(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventParticipantsPage(event: event),
      ),
    );
  }

  void _manageScanners(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageScannersPage(
          eventId: event.id,
          eventTitle: event.title,
        ),
      ),
    );
  }

  void _scanTickets(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(event: event),
      ),
    );
  }

  void _editEvent(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(event: event),
      ),
    );
  }

  void _deleteEvent(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'événement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir supprimer cet événement ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.currentParticipants} participant(s) inscrit(s)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ Cette action est irréversible.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteEvent(context, event);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteEvent(BuildContext context, EventModel event) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Supprimer l'événement
      await FirebaseService.deleteEvent(event.id);

      if (context.mounted) {
        Navigator.pop(context); // Fermer le loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour créer des événements de test
  static Future<void> _createTestEvents(BuildContext context, WidgetRef ref, user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧪 Créer des événements de test'),
        content: const Text(
          'Voulez-vous créer 3 événements de test avec des tickets multiples ?\n\n'
          '• Concert Rock (3 types de tickets)\n'
          '• Conférence Tech (2 types)\n'
          '• Match de Football (4 types)\n\n'
          'Ces événements vous permettront de tester le système de tickets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Afficher un loader
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await createMultipleTestEvents(user.id, user.fullName);
                
                if (context.mounted) {
                  Navigator.pop(context); // Fermer le loader
                  
                  // Rafraîchir la liste
                  ref.invalidate(organizerEventsProvider(user.id));
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 3 événements de test créés avec succès !'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Fermer le loader
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
