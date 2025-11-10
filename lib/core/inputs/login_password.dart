import 'package:formz/formz.dart';

enum LoginPasswordError { empty }

class LoginPassword extends FormzInput<String, LoginPasswordError> {
  const LoginPassword.pure() : super.pure('');
  const LoginPassword.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == LoginPasswordError.empty) {
      return 'La contraseña es obligatoria';
    }

    return null;
  }

  @override
  LoginPasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) {
      return LoginPasswordError.empty;
    }
    
    return null;
  }
}
