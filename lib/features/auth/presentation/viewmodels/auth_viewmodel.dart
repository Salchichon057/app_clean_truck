import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/core/presentation/router/app_router_notifier.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthViewModel(this._authRepository, this._ref)
    : super(AuthState(authStatus: AuthStatus.checking)) {
    _init();
  }

  Future<void> _init() async {
    state = await _fetchUserRole();
  }

  Future<AuthState> _fetchUserRole() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      final doc = await _ref
          .read(firestoreProvider)
          .collection('app_users')
          .doc(user.uid)
          .get();
      final role = doc.data()?['role'] ?? 'citizen';
      return AuthState(authStatus: AuthStatus.authenticated, userRole: role);
    }
    return AuthState(authStatus: AuthStatus.unauthenticated, userRole: null);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(authStatus: AuthStatus.checking);
    try {
      await _authRepository.signIn(email, password);
      state = await _fetchUserRole();
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> register(
    String email,
    String password,
    AppUser appUserData,
  ) async {
    state = state.copyWith(authStatus: AuthStatus.checking);
    try {
      await _authRepository.register(
        email,
        password,
        appUserData.copyWith(
          role: 'citizen',
          status: 'active',
          createdAt: Timestamp.now(),
          notificationPreferences: appUserData.notificationPreferences.copyWith(
            daytimeAlerts: true,
            nighttimeAlerts: true,
            daytimeStart: '06:00',
            daytimeEnd: '20:00',
            nighttimeStart: '20:00',
            nighttimeEnd: '06:00',
          ),
        ),
      );
      state = await _fetchUserRole();
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = AuthState(authStatus: AuthStatus.unauthenticated, userRole: null);
  }
}

// Proveedor para AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository, ref);
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
