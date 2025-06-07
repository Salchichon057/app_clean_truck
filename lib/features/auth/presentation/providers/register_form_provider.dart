import 'package:comaslimpio/core/inputs/confirm_password.dart';
import 'package:comaslimpio/core/inputs/email.dart';
import 'package:comaslimpio/core/inputs/full_name.dart';
import 'package:comaslimpio/core/inputs/password.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';

class RegisterFormState {
  final FullName name;
  final FullName lastName;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final Location? location;
  final String? address;
  final bool daytimeAlerts;
  final bool nighttimeAlerts;
  final String daytimeStart;
  final String daytimeEnd;
  final String nighttimeStart;
  final String nighttimeEnd;
  final bool isValid;
  final int step;
  final String? errorMessage;
  final bool isSubmitting;
  final bool showSuggestionsModal;

  RegisterFormState({
    this.name = const FullName.pure(),
    this.lastName = const FullName.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.location,
    this.address,
    this.daytimeAlerts = true,
    this.nighttimeAlerts = true,
    this.daytimeStart = '06:00',
    this.daytimeEnd = '20:00',
    this.nighttimeStart = '20:00',
    this.nighttimeEnd = '06:00',
    this.isValid = false,
    this.step = 0,
    this.errorMessage,
    this.isSubmitting = false,
    this.showSuggestionsModal = false,
  });

  RegisterFormState copyWith({
    FullName? name,
    FullName? lastName,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    Location? location,
    String? address,
    bool? daytimeAlerts,
    bool? nighttimeAlerts,
    String? daytimeStart,
    String? daytimeEnd,
    String? nighttimeStart,
    String? nighttimeEnd,
    bool? isValid,
    int? step,
    String? errorMessage,
    bool? isSubmitting,
    bool? showSuggestionsModal,
  }) {
    return RegisterFormState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      location: location ?? this.location,
      address: address ?? this.address,
      daytimeAlerts: daytimeAlerts ?? this.daytimeAlerts,
      nighttimeAlerts: nighttimeAlerts ?? this.nighttimeAlerts,
      daytimeStart: daytimeStart ?? this.daytimeStart,
      daytimeEnd: daytimeEnd ?? this.daytimeEnd,
      nighttimeStart: nighttimeStart ?? this.nighttimeStart,
      nighttimeEnd: nighttimeEnd ?? this.nighttimeEnd,
      isValid: isValid ?? this.isValid,
      step: step ?? this.step,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showSuggestionsModal: showSuggestionsModal ?? this.showSuggestionsModal,
    );
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(RegisterFormState());

  String? _validateStep() {
    if (state.step == 0) {
      if (!state.name.isValid) return 'El nombre no es válido';
      if (!state.lastName.isValid) return 'El apellido no es válido';
      if (!state.email.isValid) return 'El correo electrónico no es válido';
      if (!state.password.isValid) return 'La contraseña no es válida';
      if (!state.confirmPassword.isValid) return 'Las contraseñas no coinciden';
    } else if (state.step == 1) {
      if (state.location == null) return 'Debes seleccionar una ubicación';
    }
    return null;
  }

  bool _isFormValid() {
    return state.name.isValid &&
        state.lastName.isValid &&
        state.email.isValid &&
        state.password.isValid &&
        state.confirmPassword.isValid &&
        (state.step == 1 ? state.location != null : true);
  }

  void updateName(String value) {
    final name = FullName.dirty(value);
    state = state.copyWith(name: name, isValid: _isFormValid());
  }

  void updateLastName(String value) {
    final lastName = FullName.dirty(value);
    state = state.copyWith(lastName: lastName, isValid: _isFormValid());
  }

  void updateEmail(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(email: email, isValid: _isFormValid());
  }

  void updatePassword(String value) {
    final password = Password.dirty(value);
    final confirmPassword = ConfirmPassword.dirty(
      original: value,
      value: state.confirmPassword.value,
    );
    state = state.copyWith(
      password: password,
      confirmPassword: confirmPassword,
      isValid: _isFormValid(),
    );
  }

  void updateConfirmPassword(String value) {
    final confirmPassword = ConfirmPassword.dirty(
      original: state.password.value,
      value: value,
    );
    state = state.copyWith(
      confirmPassword: confirmPassword,
      isValid: _isFormValid(),
    );
  }

  void updateLocation(Location location) {
    state = state.copyWith(location: location, isValid: _isFormValid());
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void toggleSuggestionsModal(bool show) {
    state = state.copyWith(showSuggestionsModal: show);
  }

  void updateDaytimeAlerts(bool value) {
    state = state.copyWith(daytimeAlerts: value);
  }

  void updateNighttimeAlerts(bool value) {
    state = state.copyWith(nighttimeAlerts: value);
  }

  void updateDaytimeStart(String value) {
    state = state.copyWith(daytimeStart: value);
  }

  void updateDaytimeEnd(String value) {
    state = state.copyWith(daytimeEnd: value);
  }

  void updateNighttimeStart(String value) {
    state = state.copyWith(nighttimeStart: value);
  }

  void updateNighttimeEnd(String value) {
    state = state.copyWith(nighttimeEnd: value);
  }

  String? nextStep() {
    if (state.step < 2) {
      final error = _validateStep();
      if (error != null) {
        state = state.copyWith(errorMessage: error);
        return error;
      }
      state = state.copyWith(step: state.step + 1, errorMessage: null);
    }
    return null;
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(
        step: state.step - 1,
        errorMessage: null,
        showSuggestionsModal: false,
      );
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: null);
  }
}

final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
      return RegisterFormNotifier();
    });
