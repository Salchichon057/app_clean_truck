import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/inputs/full_name.dart';
import 'package:comaslimpio/core/inputs/dni.dart';
import 'package:comaslimpio/core/inputs/email.dart';
import 'package:comaslimpio/core/inputs/password.dart';
import 'package:comaslimpio/core/inputs/phone.dart';

class AddTruckDriverFormState {
  final FullName name;
  final Dni dni;
  final Email email;
  final Password password;
  final Phone phone;
  final bool isValid;
  final String? errorMessage;
  final bool isSubmitting;

  AddTruckDriverFormState({
    this.name = const FullName.pure(),
    this.dni = const Dni.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phone = const Phone.pure(),
    this.isValid = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  AddTruckDriverFormState copyWith({
    FullName? name,
    Dni? dni,
    Email? email,
    Password? password,
    Phone? phone,
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
    final phone = Phone.dirty(value);
    state = state.copyWith(phone: phone, isValid: _isFormValid());
  }

  bool _isFormValid() {
    return state.name.isValid &&
        state.dni.isValid &&
        state.email.isValid &&
        state.password.isValid &&
        state.phone.isValid;
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  void validateAllFields() {
    state = state.copyWith(
      name: FullName.dirty(state.name.value),
      dni: Dni.dirty(state.dni.value),
      email: Email.dirty(state.email.value),
      phone: Phone.dirty(state.phone.value),
      password: Password.dirty(state.password.value),
      isValid: _isFormValid(),
    );
  }

  void clear() {
    state = AddTruckDriverFormState();
  }
}

final addTruckDriverFormProvider =
    StateNotifierProvider<AddTruckDriverFormNotifier, AddTruckDriverFormState>(
      (ref) => AddTruckDriverFormNotifier(),
    );
