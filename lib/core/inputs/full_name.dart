import 'package:formz/formz.dart';

enum FullNameError { empty, tooShort }

class FullName extends FormzInput<String, FullNameError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == FullNameError.empty) {
      return 'El nombre completo es obligatorio';
    }
    if (displayError == FullNameError.tooShort) {
      return 'Debe tener al menos 3 caracteres';
    }

    return null;
  }

  @override
  FullNameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return FullNameError.empty;
    if (value.length < 3) return FullNameError.tooShort;

    return null;
  }
}
