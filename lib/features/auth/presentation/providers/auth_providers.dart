import 'dart:async';

import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/services/geocoding_service.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
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
  final AppUser? appUser;

  AuthState({required this.authStatus, this.userRole, this.appUser});

  AuthState copyWith({
    AuthStatus? authStatus,
    String? userRole,
    AppUser? appUser,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      userRole: userRole ?? this.userRole,
      appUser: appUser ?? this.appUser,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _authSub;

  AuthNotifier(this._authRepository)
    : super(AuthState(authStatus: AuthStatus.checking)) {
    _authSub = _authRepository.authStateChanges.listen((user) async {
      if (user == null) {
        state = state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          userRole: null,
          appUser: null,
        );
      } else {
        // Carga el usuario de Firestore
        final doc = await _firestore
            .collection('app_users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final appUser = AppUserMapper.fromJson(doc.data()!);
          state = state.copyWith(
            authStatus: AuthStatus.authenticated,
            userRole: appUser.role,
            appUser: appUser,
          );
        } else {
          state = state.copyWith(
            authStatus: AuthStatus.unauthenticated,
            userRole: null,
            appUser: null,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
      // El stream se encargará de actualizar el estado
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
      // El stream se encargará de actualizar el estado
    } catch (e) {
      state = state.copyWith(authStatus: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    // El stream se encargará de actualizar el estado
  }

  // Si fetchUserData lo usas en otros lados, puedes dejarlo.
  Future<void> fetchUserData() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      final doc = await _firestore.collection('app_users').doc(user.uid).get();
      if (doc.exists) {
        final appUser = AppUserMapper.fromJson(doc.data()!);
        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          userRole: appUser.role,
          appUser: appUser,
        );
      } else {
        state = state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          userRole: null,
          appUser: null,
        );
      }
    } else {
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        userRole: null,
        appUser: null,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

final currentUserNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.appUser?.name;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.appUser;
});

final userAddressProvider = FutureProvider<String?>((ref) async {
  final appUser = ref.watch(currentUserProvider);
  if (appUser?.location == null) return null;

  final mapboxToken = await MapToken.getMapToken();
  return await GeocodingService.getAddressFromLatLng(
    appUser!.location.lat,
    appUser.location.long,
    mapboxToken,
  );
});
