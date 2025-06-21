import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/inputs/full_name.dart';
import 'package:comaslimpio/core/inputs/dni.dart';
import 'package:comaslimpio/core/inputs/email.dart';
import 'package:comaslimpio/core/inputs/password.dart';

class AddTruckDriverFormState {
  final FullName name;
  final Dni dni;
  final Email email;
  final Password password;
  final String phone;
  final bool isValid;
  final String? errorMessage;
  final bool isSubmitting;

  AddTruckDriverFormState({
    this.name = const FullName.pure(),
    this.dni = const Dni.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phone = '',
    this.isValid = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  AddTruckDriverFormState copyWith({
    FullName? name,
    Dni? dni,
    Email? email,
    Password? password,
    String? phone,
    bool? isValid,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return AddTruckDriverFormState(
      name: name ?? this.name,
      dni: dni ?? this.dni,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AddTruckDriverFormNotifier
    extends StateNotifier<AddTruckDriverFormState> {
  AddTruckDriverFormNotifier() : super(AddTruckDriverFormState());

  void updateName(String value) {
    final name = FullName.dirty(value);
    state = state.copyWith(name: name, isValid: _isFormValid());
  }

  void updateDni(String value) {
    final dni = Dni.dirty(value);
    state = state.copyWith(dni: dni, isValid: _isFormValid());
  }

  void updateEmail(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(email: email, isValid: _isFormValid());
  }

  void updatePassword(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(password: password, isValid: _isFormValid());
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value, isValid: _isFormValid());
  }

  bool _isFormValid() {
    return state.name.isValid &&
        state.dni.isValid &&
        state.email.isValid &&
        state.password.isValid &&
        state.phone.trim().isNotEmpty;
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  void clear() {
    state = AddTruckDriverFormState();
  }
}

final addTruckDriverFormProvider =
    StateNotifierProvider<AddTruckDriverFormNotifier, AddTruckDriverFormState>(
      (ref) => AddTruckDriverFormNotifier(),
    );
