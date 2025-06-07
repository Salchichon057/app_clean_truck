import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class GoRouterNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  AuthStatus _authStatus = AuthStatus.checking;
  String _userRole = 'citizen';

  GoRouterNotifier(this._authNotifier) {
    _authNotifier.addListener((state) {
      _authStatus = state.authStatus;
      _userRole = state.userRole ?? 'citizen';
      notifyListeners();
    });
  }

  AuthStatus get authStatus => _authStatus;
  String get userRole => _userRole;

  set authStatus(AuthStatus value) {
    _authStatus = value;
    notifyListeners();
  }

  set userRole(String value) {
    _userRole = value;
    notifyListeners();
  }
}

final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return GoRouterNotifier(authNotifier);
});
