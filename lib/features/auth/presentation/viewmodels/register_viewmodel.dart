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
    final formNotifier = _ref.read(registerFormProvider.notifier);
    
    // Marcar todos los campos como dirty para mostrar errores
    formNotifier.validateCurrentStepFields();
    
    final formState = _ref.read(registerFormProvider);
    
    // Validación inicial
    if (!formState.isValid || formState.location == null) {
      formNotifier.state = formState.copyWith(
        errorMessage: formState.location == null
            ? 'Debes seleccionar una ubicación'
            : 'Formulario inválido. Completa todos los campos',
        isSubmitting: false,
      );
      return;
    }

    // Marcar como submitting
    formNotifier.state = formState.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );
    
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

      // print('Iniciando registro para: ${appUser.email}');
      
      await _authRepository.register(
        formState.email.value,
        formState.password.value,
        appUser,
      );

      // print('Registro completado exitosamente');
      
      // Limpiar formulario y estado solo en éxito
      formNotifier.state = RegisterFormState();
      state = const AsyncValue.data(null);
      
    } on AuthException catch (e) {
      // print('AuthException en submit: ${e.message}');
      // Error de autenticación con mensaje user-friendly
      state = AsyncValue.error(e, StackTrace.current);
      formNotifier.state = formState.copyWith(
        errorMessage: e.message,
        isSubmitting: false,
      );
    } catch (e, st) {
      // print('Error inesperado en submit: $e');
      // print('StackTrace: $st');
      // Error genérico
      final authError = AuthException.generic(
        'Error inesperado al registrar usuario. Intenta de nuevo'
      );
      state = AsyncValue.error(authError, st);
      formNotifier.state = formState.copyWith(
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
