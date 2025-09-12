import 'package:flutter/material.dart';
import 'package:comaslimpio/core/exceptions/auth_exception.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class AuthErrorDialog extends StatelessWidget {
  final AuthException authException;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const AuthErrorDialog({
    super.key,
    required this.authException,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Text(
            authException.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              authException.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            authException.message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
          if (authException.code != 'unknown') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Código: ${authException.code}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (authException.canRetry && onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Reintentar',
              style: TextStyle(color: AppTheme.primary),
            ),
          ),
        TextButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: Text(
            authException.canRetry ? 'Cancelar' : 'Entendido',
            style: TextStyle(
              color: authException.canRetry ? Colors.grey[600] : AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Método estático para mostrar el diálogo fácilmente
  static Future<void> show(
    BuildContext context,
    AuthException authException, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AuthErrorDialog(
        authException: authException,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// Widget para mostrar errores en SnackBar
class AuthErrorSnackBar {
  static void show(
    BuildContext context,
    AuthException authException, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Text(
            authException.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authException.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  authException.message,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: _getSnackBarColor(authException.code),
      duration: const Duration(seconds: 4),
      action: authException.canRetry && onRetry != null
          ? SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Color _getSnackBarColor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return Colors.orange[700]!;
      case 'weak-password':
        return Colors.amber[700]!;
      case 'invalid-email':
        return Colors.red[700]!;
      case 'network-request-failed':
        return Colors.blue[700]!;
      case 'user-disabled':
        return Colors.red[900]!;
      default:
        return Colors.red[600]!;
    }
  }
}

/// Extensión para facilitar el uso en cualquier parte de la app
extension AuthErrorHelpers on BuildContext {
  Future<void> showAuthError(
    AuthException authException, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool useDialog = true,
  }) {
    if (useDialog) {
      return AuthErrorDialog.show(
        this,
        authException,
        onRetry: onRetry,
        onDismiss: onDismiss,
      );
    } else {
      AuthErrorSnackBar.show(this, authException, onRetry: onRetry);
      return Future.value();
    }
  }
}