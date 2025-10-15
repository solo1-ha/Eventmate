import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/theme_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../widgets/custom_button.dart';

/// Page des paramètres
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section profil
          _buildSection(
            context,
            'Profil',
            [
              _buildListTile(
                context,
                icon: Icons.person,
                title: 'Informations personnelles',
                subtitle: currentUser?.fullName ?? 'Non connecté',
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section apparence
          _buildSection(
            context,
            'Apparence',
            [
              _buildListTile(
                context,
                icon: Icons.dark_mode,
                title: 'Thème',
                subtitle: _getThemeDisplayName(themeMode),
                onTap: () {
                  _showThemePicker(context, ref);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.palette,
                title: 'Palette de couleurs',
                subtitle: 'Thème guinéen disponible',
                onTap: () {
                  _showColorPalettePicker(context, ref);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section notifications
          _buildSection(
            context,
            'Notifications',
            [
              _buildListTile(
                context,
                icon: Icons.notifications,
                title: 'Notifications push',
                subtitle: 'Recevoir des notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implémenter la gestion des notifications
                  },
                ),
              ),
              _buildListTile(
                context,
                icon: Icons.email,
                title: 'Notifications email',
                subtitle: 'Recevoir des emails',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implémenter la gestion des emails
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section compte
          _buildSection(
            context,
            'Compte',
            [
              _buildListTile(
                context,
                icon: Icons.security,
                title: 'Sécurité',
                subtitle: 'Mot de passe et sécurité',
                onTap: () {
                  _showSecurityDialog(context);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.privacy_tip,
                title: 'Confidentialité',
                subtitle: 'Gérer vos données',
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section à propos
          _buildSection(
            context,
            'À propos',
            [
              _buildListTile(
                context,
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              _buildListTile(
                context,
                icon: Icons.help,
                title: 'Aide et support',
                subtitle: 'Obtenir de l\'aide',
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
              _buildListTile(
                context,
                icon: Icons.description,
                title: 'Conditions d\'utilisation',
                subtitle: 'Lire les conditions',
                onTap: () {
                  _showTermsDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Bouton de déconnexion
          CustomButton(
            text: 'Se déconnecter',
            onPressed: () => _logout(context),
            type: ButtonType.secondary,
            size: ButtonSize.large,
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Clair'),
              subtitle: const Text('Thème clair en permanence'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sombre'),
              subtitle: const Text('Thème sombre en permanence'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Système'),
              subtitle: const Text('Suivre les paramètres du système'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showColorPalettePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Palette de couleurs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: const Text('Indigo (Par défaut)'),
              subtitle: const Text('Thème moderne et professionnel'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thème Indigo activé')),
                );
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFCE1126), // Rouge
                      Color(0xFFFCD116), // Jaune
                      Color(0xFF009460), // Vert
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: const Text('Guinéen 🇬🇳'),
              subtitle: const Text('Couleurs du drapeau guinéen'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thème Guinéen'),
                    content: const Text(
                      'Le thème aux couleurs de la Guinée (Rouge, Jaune, Vert) '
                      'sera disponible dans une prochaine mise à jour!\n\n'
                      'Cette fonctionnalité nécessite une refonte complète du système de thèmes.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sécurité'),
        content: const Text('Fonctionnalité de sécurité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialité'),
        content: const Text('Fonctionnalité de confidentialité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide et support'),
        content: const Text('Pour obtenir de l\'aide, contactez-nous à support@eventmate.gn'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const Text('Conditions d\'utilisation d\'EventMate...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // Mode mock - déconnexion simple (redirection vers login)
      // Le provider authStateProvider gère automatiquement l'état
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

