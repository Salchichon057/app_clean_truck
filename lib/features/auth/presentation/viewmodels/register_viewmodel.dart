import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

class RegisterViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  RegisterViewModel(this._authRepository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> submit() async {
    final formState = _ref.read(registerFormProvider);
    if (!formState.isValid || formState.location == null) {
      _ref.read(registerFormProvider.notifier).state = formState.copyWith(
        errorMessage: formState.location == null
            ? 'Debes seleccionar una ubicación'
            : 'Formulario inválido',
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final appUser = AppUser(
        uid: '',
        name: '${formState.name.value} ${formState.lastName.value}',
        email: formState.email.value,
        phoneNumber: '',
        role: 'citizen',
        location: formState.location!,
        status: 'active',
        createdAt: Timestamp.now(),
        notificationPreferences: NotificationPreferences(
          daytimeAlerts: formState.daytimeAlerts,
          nighttimeAlerts: formState.nighttimeAlerts,
          daytimeStart: formState.daytimeStart,
          daytimeEnd: formState.daytimeEnd,
          nighttimeStart: formState.nighttimeStart,
          nighttimeEnd: formState.nighttimeEnd,
        ),
        dni: formState.dni.value,
      );

      print('AppUser a registrar:');
      print('name: ${appUser.name}');
      print('dni: ${appUser.dni}');
      print('email: ${appUser.email}');
      print('location: ${appUser.location.lat}, ${appUser.location.long}');
      print('notificaciones: ${appUser.notificationPreferences.toString()}');
      print('status: ${appUser.status}');
      print('role: ${appUser.role}');
      print('createdAt: ${appUser.createdAt}');

      await _authRepository.register(
        formState.email.value,
        formState.password.value,
        appUser,
      );

      // _ref.read(registerFormProvider.notifier).state = formState.copyWith(
      //   errorMessage: null,
      //   isSubmitting: false,
      // );

      _ref.read(registerFormProvider.notifier).state = RegisterFormState();

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      print('Error al registrar usuario: $e');
      _ref.read(registerFormProvider.notifier).state = formState.copyWith(
        errorMessage: e.toString(),
        isSubmitting: false,
      );
    }
  }
}

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, AsyncValue<void>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return RegisterViewModel(authRepository, ref);
    });
