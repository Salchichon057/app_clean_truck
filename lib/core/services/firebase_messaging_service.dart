import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
      // Solicitar permisos
      await _requestPermissions();
      
      // Configurar listeners
      await _setupMessageHandlers();
      
      _initialized = true;
      if (kDebugMode) print('✅ Firebase Messaging Service initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing Firebase Messaging Service: $e');
    }
  }

  /// Solicitar permisos de notificación
  static Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
      } else {
        print('❌ Notification permissions denied');
      }
    }
  }

  /// Configurar manejadores de mensajes
  static Future<void> _setupMessageHandlers() async {
    // Manejar notificaciones cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar notificaciones cuando la app está en segundo plano pero no terminada
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Manejar notificaciones cuando la app se abre desde una notificación
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // ⚡ NUEVO: Manejar actualización automática de tokens
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Manejar mensajes cuando la app está en primer plano
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Foreground message: ${message.notification?.title}');
    }
    
    // Guardar notificación en Firestore para mostrar en la UI
    await _saveNotificationToFirestore(message);
  }

  /// Manejar mensajes cuando la app está en segundo plano
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('🔔 Background message: ${message.notification?.title}');
    }
    
    // Guardar notificación en Firestore para mostrar en la UI
    await _saveNotificationToFirestore(message);
  }

  /// Guardar notificación en Firestore para mostrar en la UI
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final notification = message.notification;
      if (notification == null) return;

      // Crear el documento de notificación
      final notificationData = {
        'type': message.data['type'] ?? 'general',
        'message': notification.body ?? '',
        'routeId': message.data['routeId'],
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      // Guardar en la subcolección de notificaciones del usuario
      await _firestore
          .collection('app_users')
          .doc(user.uid)
          .collection('notifications')
          .add(notificationData);

      if (kDebugMode) {
        print('✅ Notification saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving notification to Firestore: $e');
      }
    }
  }

  /// ⚡ NUEVO: Manejar actualización automática de token FCM
  static Future<void> _onTokenRefresh(String newToken) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (kDebugMode) {
        print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      }

      // Actualizar token en Firestore
      await _firestore
          .collection('app_users')
          .doc(user.uid)
          .update({'fcmToken': newToken});

      if (kDebugMode) {
        print('✅ FCM Token updated in Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating FCM token: $e');
      }
    }
  }

  /// Obtener token FCM
  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode && token != null) {
        print('🔑 FCM Token: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Suscribirse a un tópico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) print('✅ Subscribed to topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Desuscribirse de un tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Obtener información del último mensaje
  static Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }
}

/// Manejador para notificaciones en segundo plano (debe ser función de nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 Background handler: ${message.notification?.title}');
  }
}
