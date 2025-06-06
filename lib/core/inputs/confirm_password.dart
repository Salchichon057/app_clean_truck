import 'package:formz/formz.dart';

enum ConfirmPasswordError { empty, mismatch }

class ConfirmPassword extends FormzInput<String, ConfirmPasswordError> {
  final String original;

  const ConfirmPassword.pure({this.original = ''}) : super.pure('');
  const ConfirmPassword.dirty({required this.original, required String value})
    : super.dirty(value);

  @override
  ConfirmPasswordError? validator(String value) {
    if (value.trim().isEmpty) return ConfirmPasswordError.empty;
    if (value != original) return ConfirmPasswordError.mismatch;
    return null;
  }

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == ConfirmPasswordError.empty) {
      return 'Confirma tu contraseña';
    }
    if (displayError == ConfirmPasswordError.mismatch) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
