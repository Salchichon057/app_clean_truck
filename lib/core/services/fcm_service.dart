import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmService {
  FcmService._privateConstructor();
  static final FcmService instance = FcmService._privateConstructor();

  /// Asegura que el usuario tenga todos los campos necesarios para notificaciones
  Future<void> ensureUserHasRequiredFields(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('app_users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final updates = <String, dynamic>{};

      // Asegurar que tenga FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && userData['fcmToken'] != token) {
        updates['fcmToken'] = token;
        print('FCM Token obtained: $token');
      }

      // Asegurar que ciudadanos tengan selectedRouteId (inicialmente null)
      if (userData['role'] == 'citizen' && !userData.containsKey('selectedRouteId')) {
        updates['selectedRouteId'] = null;
      }

      // Aplicar actualizaciones si las hay
      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('app_users')
            .doc(userId)
            .update(updates);
        print('Updated user $userId with: $updates');
      } else {
        print('User $userId already has all required fields');
      }
    } catch (e) {
      print('Error ensuring user fields: $e');
    }
  }
}
