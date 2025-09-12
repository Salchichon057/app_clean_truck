import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String title;
  final String code;
  final bool canRetry;
  final String icon;

  AuthException({
    required this.message,
    required this.title,
    required this.code,
    required this.canRetry,
    required this.icon,
  });

  factory AuthException.fromFirebaseAuth(FirebaseAuthException e) {
    return AuthException(
      message: _getErrorMessage(e.code),
      title: _getErrorTitle(e.code),
      code: e.code,
      canRetry: _canRetry(e.code),
      icon: _getErrorIcon(e.code),
    );
  }

  factory AuthException.generic(String message) {
    return AuthException(
      message: message,
      title: 'Error',
      code: 'unknown',
      canRetry: true,
      icon: '⚠️',
    );
  }

  static String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'El registro con correo y contraseña no está habilitado.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son incorrectas o han expirado.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet e inténtalo de nuevo.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera un momento antes de intentar de nuevo.';
      default:
        return 'Ha ocurrido un error inesperado. Inténtalo de nuevo.';
    }
  }

  static String _getErrorTitle(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Correo ya registrado';
      case 'weak-password':
        return 'Contraseña muy débil';
      case 'invalid-email':
        return 'Correo inválido';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Error de inicio de sesión';
      case 'network-request-failed':
        return 'Error de conexión';
      case 'too-many-requests':
        return 'Demasiados intentos';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      default:
        return 'Error de autenticación';
    }
  }

  static bool _canRetry(String code) {
    switch (code) {
      case 'network-request-failed':
      case 'too-many-requests':
        return true;
      case 'email-already-in-use':
      case 'weak-password':
      case 'invalid-email':
      case 'user-disabled':
      case 'operation-not-allowed':
        return false;
      default:
        return true;
    }
  }

  static String _getErrorIcon(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '📧';
      case 'weak-password':
        return '🔒';
      case 'invalid-email':
        return '❌';
      case 'user-not-found':
      case 'wrong-password':
        return '🔐';
      case 'network-request-failed':
        return '🌐';
      case 'too-many-requests':
        return '⏱️';
      case 'user-disabled':
        return '🚫';
      default:
        return '⚠️';
    }
  }

  @override
  String toString() => 'AuthException: $message';
}