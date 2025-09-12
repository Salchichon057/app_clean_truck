import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorHandler {
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      // Errores de registro
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'El registro con correo y contraseña no está habilitado.';
      
      // Errores de inicio de sesión
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son incorrectas o han expirado.';
      
      // Errores de red y conexión
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet e inténtalo de nuevo.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Espera un momento antes de intentar de nuevo.';
      
      // Errores de contraseña
      case 'requires-recent-login':
        return 'Por seguridad, necesitas iniciar sesión nuevamente para realizar esta acción.';
      
      // Errores de verificación
      case 'invalid-verification-code':
        return 'El código de verificación es inválido.';
      case 'invalid-verification-id':
        return 'El ID de verificación es inválido.';
      case 'session-expired':
        return 'La sesión ha expirado. Inicia sesión nuevamente.';
      
      // Errores de cuenta
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo pero con un método de inicio de sesión diferente.';
      case 'credential-already-in-use':
        return 'Esta credencial ya está asociada a otra cuenta.';
      
      // Errores de configuración
      case 'app-not-authorized':
        return 'La aplicación no está autorizada para usar Firebase Authentication.';
      case 'keychain-error':
        return 'Error en el almacén de credenciales del dispositivo.';
      
      // Errores de token
      case 'invalid-custom-token':
        return 'El token personalizado es inválido.';
      case 'custom-token-mismatch':
        return 'El token personalizado no coincide con la configuración.';
      
      // Errores de usuario
      case 'missing-email':
        return 'Debes proporcionar un correo electrónico.';
      case 'missing-password':
        return 'Debes proporcionar una contraseña.';
      case 'email-change-needs-verification':
        return 'Necesitas verificar tu nuevo correo electrónico.';
      
      // Errores de límites
      case 'quota-exceeded':
        return 'Se ha excedido la cuota de uso. Inténtalo más tarde.';
      case 'project-not-found':
        return 'El proyecto de Firebase no fue encontrado.';
      
      // Errores específicos de plataforma
      case 'web-storage-unsupported':
        return 'El almacenamiento web no es compatible con este navegador.';
      case 'web-context-already-presented':
        return 'Ya hay una operación de autenticación en progreso.';
      case 'web-context-cancelled':
        return 'La operación de autenticación fue cancelada.';
      
      // Errores de terceros (Google, Facebook, etc.)
      case 'popup-blocked':
        return 'El popup fue bloqueado por el navegador. Permite popups para esta página.';
      case 'popup-closed-by-user':
        return 'El popup fue cerrado antes de completar la autenticación.';
      case 'unauthorized-domain':
        return 'El dominio no está autorizado para operaciones OAuth.';
      
      // Error genérico
      default:
        return 'Ha ocurrido un error inesperado: ${e.message ?? 'Error desconocido'}';
    }
  }

  /// Obtiene el título para mostrar en diálogos según el tipo de error
  static String getErrorTitle(FirebaseAuthException e) {
    switch (e.code) {
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

  /// Determina si el error permite reintentar la operación
  static bool canRetry(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
      case 'too-many-requests':
      case 'quota-exceeded':
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

  /// Obtiene el ícono apropiado para mostrar según el error
  static String getErrorIcon(FirebaseAuthException e) {
    switch (e.code) {
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
}