import 'package:formz/formz.dart';

enum PhoneError {
  empty,
  invalid,
}

class Phone extends FormzInput<String, PhoneError> {
  const Phone.pure() : super.pure('');
  const Phone.dirty([String value = '']) : super.dirty(value);

  String? get errorMessage {
    if (isNotValid) {
      if (error == PhoneError.empty) {
        return 'El teléfono es obligatorio';
      } else if (error == PhoneError.invalid) {
        return 'Teléfono debe tener 9 dígitos';
      }
    }
    return null;
  }

  @override
  PhoneError? validator(String value) {
    final trimmedValue = value.trim();
    
    if (trimmedValue.isEmpty) {
      return PhoneError.empty;
    }
    
    if (trimmedValue.length != 9) {
      return PhoneError.invalid;
    }
    
    final phoneRegExp = RegExp(r'^[0-9]{9}$');
    if (!phoneRegExp.hasMatch(trimmedValue)) {
      return PhoneError.invalid;
    }
    
    return null;
  }
}
