import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class GoRouterNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  AuthStatus _authStatus = AuthStatus.checking;
  AuthStatus _lastValidAuthStatus = AuthStatus.unauthenticated;
  String _userRole = 'citizen';
  String _lastValidUserRole = 'citizen';

  GoRouterNotifier(this._authNotifier) {
    _authNotifier.addListener((state) {
      _authStatus = state.authStatus;
      _userRole = state.userRole ?? 'citizen';
      
      // Cachear el último estado válido (no-checking)
      if (_authStatus != AuthStatus.checking) {
        _lastValidAuthStatus = _authStatus;
        _lastValidUserRole = _userRole;
      }
      
      notifyListeners();
    });
  }

  // Retorna el estado actual, pero si está en checking, usa el último válido
  AuthStatus get authStatus {
    return _authStatus == AuthStatus.checking 
        ? _lastValidAuthStatus 
        : _authStatus;
  }
  
  // Retorna el rol actual, o el último válido si está en checking
  String get userRole {
    return _authStatus == AuthStatus.checking
        ? _lastValidUserRole
        : _userRole;
  }

  set authStatus(AuthStatus value) {
    _authStatus = value;
    
    // Cachear si no es checking
    if (value != AuthStatus.checking) {
      _lastValidAuthStatus = value;
    }
    
    notifyListeners();
  }

  set userRole(String value) {
    _userRole = value;
    
    // Cachear si el auth status no es checking
    if (_authStatus != AuthStatus.checking) {
      _lastValidUserRole = value;
    }
    
    notifyListeners();
  }
  
  // Getter para obtener el estado real (incluyendo checking) - útil para debug
  AuthStatus get rawAuthStatus => _authStatus;
  
  // Método para verificar si está actualmente en checking
  bool get isChecking => _authStatus == AuthStatus.checking;
}

final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return GoRouterNotifier(authNotifier);
});
