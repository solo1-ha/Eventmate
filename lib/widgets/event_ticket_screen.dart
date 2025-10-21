import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Modèle de données pour un ticket d'événement
class EventTicket {
  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final String date;
  final String time;
  final String category;
  final String code; // code du ticket
  final String qrData; // données du QR code
  final String? ticketType; // Type de ticket (VIP, Standard, etc.)
  final String? price; // Prix du ticket

  const EventTicket({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.code,
    required this.qrData,
    this.ticketType,
    this.price,
  });
}

/// Widget d'affichage du ticket d'événement avec design moderne
class EventTicketScreen extends StatelessWidget {
  final EventTicket ticket;

  const EventTicketScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2A44), // Fond bleu foncé
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2A44),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails du ticket',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareTicket(context),
            tooltip: 'Partager',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Carte principale du ticket
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Image de couverture de l'événement
                    _buildEventImage(),
                    
                    // Informations de l'événement
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre de l'événement
                          _buildEventTitle(),
                          
                          const SizedBox(height: 20),
                          
                          // Catégorie et type de ticket
                          _buildTicketBadges(),
                          
                          const SizedBox(height: 24),
                          
                          // Date et heure
                          _buildInfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: ticket.date,
                            iconColor: const Color(0xFF4A90E2),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Heure
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Heure',
                            value: ticket.time,
                            iconColor: const Color(0xFF4A90E2),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Lieu
                          _buildInfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Lieu',
                            value: ticket.location,
                            iconColor: const Color(0xFFE74C3C),
                          ),
                          
                          // Prix (si disponible)
                          if (ticket.price != null) ...[
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.payments_rounded,
                              label: 'Prix',
                              value: ticket.price!,
                              iconColor: const Color(0xFF27AE60),
                            ),
                          ],
                          
                          const SizedBox(height: 32),
                          
                          // Séparateur
                          _buildDashedDivider(),
                          
                          const SizedBox(height: 32),
                          
                          // QR Code
                          _buildQRCodeSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Code du ticket
                          _buildTicketCode(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            _buildInstructions(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Image de couverture de l'événement
  Widget _buildEventImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: ticket.imageUrl.isNotEmpty
          ? Image.network(
              ticket.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  /// Image placeholder si l'image ne charge pas
  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2),
            const Color(0xFF357ABD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Titre de l'événement
  Widget _buildEventTitle() {
    return Text(
      ticket.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2A44),
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Badges pour catégorie et type de ticket
  Widget _buildTicketBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Badge catégorie
        _buildBadge(
          label: ticket.category,
          color: const Color(0xFF4A90E2),
        ),
        
        if (ticket.ticketType != null) ...[
          const SizedBox(width: 12),
          // Badge type de ticket
          _buildBadge(
            label: ticket.ticketType!,
            color: const Color(0xFF9B59B6),
          ),
        ],
      ],
    );
  }

  /// Badge individuel
  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Ligne d'information avec icône
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icône
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: iconColor,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Label et valeur
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2A44),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Séparateur en pointillés
  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        150 ~/ 5,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
            height: 2,
          ),
        ),
      ),
    );
  }

  /// Section QR Code
  Widget _buildQRCodeSection() {
    return Center(
      child: Column(
        children: [
          // Label
          Text(
            'Scannez ce code à l\'entrée',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: QrImageView(
              data: ticket.qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1F2A44),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1F2A44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Code du ticket
  Widget _buildTicketCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_rounded,
            size: 20,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            'Code : ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _formatTicketCode(ticket.code),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2A44),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Instructions d'utilisation
  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('Présentez ce QR code à l\'entrée de l\'événement'),
            _buildInstructionItem('Augmentez la luminosité de votre écran'),
            _buildInstructionItem('Conservez ce ticket jusqu\'à la fin de l\'événement'),
          ],
        ),
      ),
    );
  }

  /// Item d'instruction
  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formate le code du ticket (ex: 24536675 -> 245 366 75)
  String _formatTicketCode(String code) {
    if (code.length <= 3) return code;
    
    // Ajoute des espaces tous les 3 chiffres
    String formatted = '';
    for (int i = 0; i < code.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += ' ';
      }
      formatted += code[i];
    }
    return formatted;
  }

  /// Partage le ticket
  void _shareTicket(BuildContext context) {
    Share.share(
      'Mon ticket pour "${ticket.title}"\n'
      'Date: ${ticket.date} à ${ticket.time}\n'
      'Lieu: ${ticket.location}\n'
      'Code: ${ticket.code}\n\n'
      'Voir plus de détails dans l\'application EventMate',
      subject: 'Ticket - ${ticket.title}',
    );
  }
}
