import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/core/exceptions/auth_exception.dart';

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

      await _authRepository.register(
        formState.email.value,
        formState.password.value,
        appUser,
      );

      _ref.read(registerFormProvider.notifier).state = RegisterFormState();
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      // Error de autenticación con mensaje user-friendly
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(registerFormProvider.notifier).state = formState.copyWith(
        errorMessage: e.message,
        isSubmitting: false,
      );
    } catch (e) {
      // Error genérico
      final authError = AuthException.generic('Error inesperado al registrar usuario');
      state = AsyncValue.error(authError, StackTrace.current);
      _ref.read(registerFormProvider.notifier).state = formState.copyWith(
        errorMessage: authError.message,
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
