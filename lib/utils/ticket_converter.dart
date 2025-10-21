import 'package:intl/intl.dart';
import '../data/models/event_model.dart';
import '../data/models/registration_model.dart';
import '../widgets/event_ticket_screen.dart';

/// Utilitaire pour convertir les modèles EventMate en EventTicket
class TicketConverter {
  /// Convertit un EventModel et RegistrationModel en EventTicket
  /// pour l'affichage dans EventTicketScreen
  static EventTicket fromEventAndRegistration(
    EventModel event,
    RegistrationModel registration,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return EventTicket(
      id: event.id,
      title: event.title,
      imageUrl: event.imageUrl ?? '',
      location: event.location,
      date: dateFormat.format(event.dateTime),
      time: timeFormat.format(event.dateTime),
      category: event.category ?? 'Événement',
      code: _generateTicketCode(registration.id),
      qrData: registration.qrCode,
      ticketType: registration.ticketType,
      price: registration.ticketPrice != null
          ? '${registration.ticketPrice!.toStringAsFixed(0)} ${event.currency}'
          : null,
    );
  }

  /// Génère un code de ticket lisible à partir de l'ID d'inscription
  /// Prend les 8 premiers caractères et les formate
  static String _generateTicketCode(String registrationId) {
    // Prend les 8 premiers caractères
    String code = registrationId.substring(0, 8).toUpperCase();
    
    // Remplace les lettres par des chiffres pour avoir un code numérique
    // (optionnel, selon vos préférences)
    final regex = RegExp(r'[A-Z]');
    code = code.replaceAllMapped(regex, (match) {
      return (match.group(0)!.codeUnitAt(0) % 10).toString();
    });
    
    return code;
  }

  /// Convertit uniquement un EventModel en EventTicket
  /// Utile quand on n'a pas encore de registration
  static EventTicket fromEvent(EventModel event) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    return EventTicket(
      id: event.id,
      title: event.title,
      imageUrl: event.imageUrl ?? '',
      location: event.location,
      date: dateFormat.format(event.dateTime),
      time: timeFormat.format(event.dateTime),
      category: event.category ?? 'Événement',
      code: _generateTicketCode(event.id),
      qrData: event.id, // Utilise l'ID de l'événement comme QR data
      ticketType: null,
      price: (event.price ?? 0) > 0 ? '${event.price!.toStringAsFixed(0)} ${event.currency}' : null,
    );
  }
}
