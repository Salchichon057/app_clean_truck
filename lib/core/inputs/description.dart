import 'package:formz/formz.dart';

enum DescriptionError { empty, tooShort }

class Description extends FormzInput<String, DescriptionError> {
  const Description.pure() : super.pure('');
  const Description.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == DescriptionError.empty) {
      return 'La descripción es obligatoria';
    }
    if (displayError == DescriptionError.tooShort) {
      return 'Debe tener al menos 10 caracteres';
    }

    return null;
  }

  @override
  DescriptionError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return DescriptionError.empty;
    if (value.length < 10) return DescriptionError.tooShort;

    return null;
  }
}
