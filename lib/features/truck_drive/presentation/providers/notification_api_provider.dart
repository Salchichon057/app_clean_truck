import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/services/notification_api_service.dart';
import 'package:comaslimpio/core/models/location.dart';

/// Estado del servicio de notificaciones API
class NotificationApiState {
  final bool isConnected;
  final bool isLoading;
  final String? lastError;
  final List<String> logs;
  final DateTime? lastUpdate;
  final int notificationsSent;

  const NotificationApiState({
    this.isConnected = false,
    this.isLoading = false,
    this.lastError,
    this.logs = const [],
    this.lastUpdate,
    this.notificationsSent = 0,
  });

  NotificationApiState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? lastError,
    List<String>? logs,
    DateTime? lastUpdate,
    int? notificationsSent,
  }) {
    return NotificationApiState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError,
      logs: logs ?? this.logs,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      notificationsSent: notificationsSent ?? this.notificationsSent,
    );
  }
}

/// NotificationApiNotifier para manejar el estado de la API
class NotificationApiNotifier extends StateNotifier<NotificationApiState> {
  NotificationApiNotifier() : super(const NotificationApiState()) {
    checkApiHealth();
  }

  /// Agregar log al estado
  void _addLog(String message) {
    final timestamp = DateTime.now();
    final logMessage = '[${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}] $message';
    
    final newLogs = [...state.logs, logMessage];
    // Mantener solo los últimos 50 logs
    final logsToKeep = newLogs.length > 50 ? newLogs.sublist(newLogs.length - 50) : newLogs;
    
    state = state.copyWith(logs: logsToKeep);
  }

  /// Verificar estado de la API
  Future<bool> checkApiHealth() async {
    state = state.copyWith(isLoading: true, lastError: null);
    _addLog('🔍 Verificando estado de la API...');

    try {
      final response = await NotificationApiService.healthCheck();
      
      if (response.success) {
        state = state.copyWith(
          isConnected: true,
          isLoading: false,
          lastError: null,
        );
        _addLog('✅ API conectada correctamente');
        return true;
      } else {
        state = state.copyWith(
          isConnected: false,
          isLoading: false,
          lastError: response.message,
        );
        _addLog('❌ API no disponible: ${response.message}');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isLoading: false,
        lastError: e.toString(),
      );
      _addLog('❌ Error al verificar API: $e');
      return false;
    }
  }

  /// Enviar ubicación del camión a la API
  Future<bool> updateTruckLocation({
    required String userId,
    required Location location,
  }) async {
    if (!state.isConnected) {
      _addLog('⚠️ Intentando actualizar ubicación sin conexión a API');
      await checkApiHealth();
      if (!state.isConnected) {
        _addLog('❌ No se puede actualizar ubicación: API no disponible');
        return false;
      }
    }

    state = state.copyWith(isLoading: true);
    _addLog('📍 Enviando ubicación: lat=${location.lat.toStringAsFixed(6)}, lng=${location.long.toStringAsFixed(6)}');

    try {
      final response = await NotificationApiService.updateTruckLocation(
        userId: userId,
        location: location,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          lastUpdate: DateTime.now(),
          notificationsSent: state.notificationsSent + 1,
          lastError: null,
        );
        _addLog('✅ Ubicación enviada exitosamente');
        
        // Log datos adicionales si están disponibles
        if (response.data != null) {
          final notificationsCount = response.data!['notificationsSent'] ?? 0;
          if (notificationsCount > 0) {
            _addLog('📢 Se enviaron $notificationsCount notificaciones a ciudadanos');
          }
        }
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          lastError: response.message,
        );
        _addLog('❌ Error al enviar ubicación: ${response.message}');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      _addLog('❌ Excepción al enviar ubicación: $e');
      return false;
    }
  }

  /// Enviar notificación de prueba
  Future<bool> sendTestNotification(String userId) async {
    if (!state.isConnected) {
      await checkApiHealth();
      if (!state.isConnected) {
        _addLog('❌ No se puede enviar notificación de prueba: API no disponible');
        return false;
      }
    }

    state = state.copyWith(isLoading: true);
    _addLog('🧪 Enviando notificación de prueba...');

    try {
      final response = await NotificationApiService.sendTestNotification(
        userId: userId,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          lastError: null,
        );
        _addLog('✅ Notificación de prueba enviada exitosamente');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          lastError: response.message,
        );
        _addLog('❌ Error en notificación de prueba: ${response.message}');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e.toString(),
      );
      _addLog('❌ Excepción en notificación de prueba: $e');
      return false;
    }
  }

  /// Limpiar logs
  void clearLogs() {
    state = state.copyWith(logs: []);
    _addLog('🗑️ Logs limpiados');
  }

  /// Reiniciar contador de notificaciones
  void resetNotificationCount() {
    state = state.copyWith(notificationsSent: 0);
    _addLog('🔄 Contador de notificaciones reiniciado');
  }
}

/// Provider para el estado de la API de notificaciones
final notificationApiProvider = StateNotifierProvider<NotificationApiNotifier, NotificationApiState>((ref) {
  return NotificationApiNotifier();
});

/// Provider para verificar si la API está conectada
final isApiConnectedProvider = Provider<bool>((ref) {
  return ref.watch(notificationApiProvider).isConnected;
});

/// Provider para obtener el último error de la API
final apiLastErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationApiProvider).lastError;
});

/// Provider para obtener los logs de la API
final apiLogsProvider = Provider<List<String>>((ref) {
  return ref.watch(notificationApiProvider).logs;
});
