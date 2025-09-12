import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para manejar Firebase Cloud Messaging (FCM)
class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _requestPermissions();
      await _setupMessageHandlers();
      _initialized = true;
    } catch (e) {
      // Error silencioso
    }
  }

  /// Solicitar permisos de notificación
  static Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Configurar manejadores de mensajes
  static Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Manejar mensajes cuando la app está en primer plano
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _saveNotificationToFirestore(message);
  }

  /// Manejar mensajes cuando la app está en segundo plano
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await _saveNotificationToFirestore(message);
  }

  /// Guardar notificación en Firestore para mostrar en la UI
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final notification = message.notification;
      if (notification == null) return;

      final notificationData = {
        'type': message.data['type'] ?? 'general',
        'message': notification.body ?? '',
        'routeId': message.data['routeId'],
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      await _firestore
          .collection('app_users')
          .doc(user.uid)
          .collection('notifications')
          .add(notificationData);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Manejar actualización automática de token FCM
  static Future<void> _onTokenRefresh(String newToken) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore
          .collection('app_users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    } catch (e) {
      // Error silencioso
    }
  }

  /// Obtener token FCM
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Suscribirse a un tópico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Desuscribirse de un tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Obtener información del último mensaje
  static Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }
}

/// Manejador para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Procesamiento silencioso
}
