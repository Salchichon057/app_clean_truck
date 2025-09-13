import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Servicio para manejar las preferencias de notificaciones
class NotificationPreferencesService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _firstTimeAskedKey = 'first_time_asked_notifications';

  /// Verificar si es la primera vez que se pregunta sobre notificaciones
  static Future<bool> isFirstTimeAskingPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAsked = prefs.getBool(_firstTimeAskedKey) ?? false;
    return !hasAsked;
  }

  /// Marcar que ya se preguntó sobre permisos de notificación
  static Future<void> markPermissionsAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeAskedKey, true);
  }

  /// Obtener el estado actual de las notificaciones
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Habilitar notificaciones
  static Future<void> enableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, true);
    
    // Solicitar permisos de Firebase
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Deshabilitar notificaciones
  static Future<void> disableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, false);
  }

  /// Mostrar diálogo de permisos de notificación
  static Future<void> showNotificationPermissionDialog(BuildContext context) async {
    if (!await isFirstTimeAskingPermissions()) {
      return; // Ya se preguntó antes
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Notificaciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF003B56),
            ),
          ),
          content: const Text(
            'Permita notificaciones para avisarle cuando pase el camión de basura. Podrá cambiarlas en ajustes de su dispositivo.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'No permitir',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41A5DE),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Permitir notificaciones'),
            ),
          ],
        );
      },
    );

    await markPermissionsAsked();

    if (result == true) {
      await enableNotifications();
    } else {
      await disableNotifications();
    }
  }
}