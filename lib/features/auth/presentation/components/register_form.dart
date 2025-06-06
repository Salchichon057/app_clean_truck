import 'package:comaslimpio/core/models/location.dart';
import 'package:formz/formz.dart';

// Validación para el Nombre Completo
enum NameValidationError { empty }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');
  const Name.dirty([String value = '']) : super.dirty(value);

  @override
  NameValidationError? validator(String value) {
    return value.trim().isEmpty ? NameValidationError.empty : null;
  }
}

// Validación para el Correo
enum EmailValidationError { empty, invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([String value = '']) : super.dirty(value);

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.trim().isEmpty) return EmailValidationError.empty;
    if (!_emailRegExp.hasMatch(value)) return EmailValidationError.invalid;
    return null;
  }
}

// Validación para el Teléfono
enum PhoneValidationError { empty, invalid }

class Phone extends FormzInput<String, PhoneValidationError> {
  const Phone.pure() : super.pure('');
  const Phone.dirty([String value = '']) : super.dirty(value);

  static final RegExp _phoneRegExp = RegExp(r'^\d{10}$');

  @override
  PhoneValidationError? validator(String value) {
    if (value.trim().isEmpty) return PhoneValidationError.empty;
    if (!_phoneRegExp.hasMatch(value)) return PhoneValidationError.invalid;
    return null;
  }
}

// Validación para la Contraseña
enum PasswordValidationError { empty, tooShort }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 6) return PasswordValidationError.tooShort;
    return null;
  }
}

// Validación para la Ubicación (no puede ser nula)
enum LocationValidationError { empty }

class LocationInput extends FormzInput<Location?, LocationValidationError> {
  const LocationInput.pure() : super.pure(null);
  const LocationInput.dirty([Location? value]) : super.dirty(value);

  @override
  LocationValidationError? validator(Location? value) {
    return value == null ? LocationValidationError.empty : null;
  }
}
