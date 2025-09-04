import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:comaslimpio/core/config/environmets.dart';
import 'package:comaslimpio/core/models/location.dart';

/// Modelo para la respuesta de la API de notificaciones
class NotificationApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  NotificationApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationApiResponse.fromJson(Map<String, dynamic> json) {
    return NotificationApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

/// Servicio para interactuar con la API TypeScript de notificaciones
class NotificationApiService {
  static const String _baseUrl = 'http://localhost:3000'; // Fallback
  static const int _timeoutSeconds = 30;

  /// URL base configurada desde variables de entorno
  static String get baseUrl {
    try {
      return Environment.apiUrl.isNotEmpty ? Environment.apiUrl : _baseUrl;
    } catch (e) {
      return _baseUrl;
    }
  }

  /// Headers comunes para todas las requests
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Cliente HTTP configurado con timeout
  static http.Client get _client => http.Client();

  /// Actualizar ubicación del camión
  static Future<NotificationApiResponse> updateTruckLocation({
    required String userId,
    required Location location,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/update-truck-location');
      final body = jsonEncode({
        'userId': userId,
        'location': {
          'lat': location.lat,
          'long': location.long,
        },
      });

      print('🚚 Sending location update to API: $url');
      print('📍 Payload: $body');

      final response = await _client
          .post(
            url,
            headers: _headers,
            body: body,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      print('📨 API Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NotificationApiResponse.fromJson(jsonResponse);
      } else {
        // Error del servidor
        try {
          final errorResponse = jsonDecode(response.body);
          return NotificationApiResponse(
            success: false,
            message: errorResponse['message'] ?? 'Error del servidor',
            data: errorResponse,
          );
        } catch (e) {
          return NotificationApiResponse(
            success: false,
            message: 'Error HTTP ${response.statusCode}: ${response.body}',
          );
        }
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      return NotificationApiResponse(
        success: false,
        message: 'Error de conexión: No se puede conectar al servidor. Verifica que la API esté ejecutándose.',
      );
    } on http.ClientException catch (e) {
      print('❌ HTTP Client error: $e');
      return NotificationApiResponse(
        success: false,
        message: 'Error de cliente HTTP: $e',
      );
    } on Exception catch (e) {
      print('❌ Unexpected error: $e');
      return NotificationApiResponse(
        success: false,
        message: 'Error inesperado: $e',
      );
    }
  }

  /// Enviar notificación de prueba
  static Future<NotificationApiResponse> sendTestNotification({
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/test-notification');
      final body = jsonEncode({
        'userId': userId,
      });

      print('🧪 Sending test notification to API: $url');
      print('📍 Payload: $body');

      final response = await _client
          .post(
            url,
            headers: _headers,
            body: body,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      print('📨 API Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NotificationApiResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return NotificationApiResponse(
            success: false,
            message: errorResponse['message'] ?? 'Error del servidor',
            data: errorResponse,
          );
        } catch (e) {
          return NotificationApiResponse(
            success: false,
            message: 'Error HTTP ${response.statusCode}: ${response.body}',
          );
        }
      }
    } on Exception catch (e) {
      print('❌ Test notification error: $e');
      return NotificationApiResponse(
        success: false,
        message: 'Error en notificación de prueba: $e',
      );
    }
  }

  /// Verificar estado de la API (health check)
  static Future<NotificationApiResponse> healthCheck() async {
    try {
      final url = Uri.parse('$baseUrl/health');

      print('❤️ Checking API health: $url');

      final response = await _client
          .get(
            url,
            headers: _headers,
          )
          .timeout(Duration(seconds: 10)); // Timeout más corto para health check

      print('📨 Health Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NotificationApiResponse(
          success: true,
          message: 'API funcionando correctamente',
          data: jsonResponse,
        );
      } else {
        return NotificationApiResponse(
          success: false,
          message: 'API no disponible (${response.statusCode})',
        );
      }
    } on Exception catch (e) {
      print('❌ Health check error: $e');
      return NotificationApiResponse(
        success: false,
        message: 'API no disponible: $e',
      );
    }
  }

  /// Dispose del cliente HTTP (llamar al cerrar la app)
  static void dispose() {
    _client.close();
  }
}
