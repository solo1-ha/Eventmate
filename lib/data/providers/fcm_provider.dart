import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fcm_service.dart';

/// Provider pour le service FCM
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

/// Provider pour initialiser FCM
final fcmInitializerProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.read(fcmServiceProvider);
  await fcmService.initialize();
});
