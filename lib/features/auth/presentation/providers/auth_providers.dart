import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/infrastructure/datasources/auth_firebase_datasource.dart';
import 'package:comaslimpio/core/presentation/router/app_router_notifier.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthFirebaseDatasource();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

class AuthState {
  final AuthStatus authStatus;
  final String? userRole;

  AuthState({required this.authStatus, this.userRole});

  AuthState copyWith({AuthStatus? authStatus, String? userRole}) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      userRole: userRole ?? this.userRole,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier(this._authRepository)
    : super(AuthState(authStatus: AuthStatus.checking)) {
    _init();
  }

  Future<void> _init() async {
    await _fetchUserRole();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
      await _fetchUserRole();
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
      await _fetchUserRole();
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      userRole: null,
    );
  }

  Future<void> _fetchUserRole() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      final doc = await _firestore.collection('app_users').doc(user.uid).get();
      final role = doc.data()?['role'] ?? 'citizen';
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        userRole: role,
      );
    } else {
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        userRole: null,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

final currentUserNameProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance
      .collection('app_users')
      .doc(user.uid)
      .get();
  return doc.data()?['name'] as String?;
});
