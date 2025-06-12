import 'package:formz/formz.dart';

enum DniError { empty, invalid, notNumeric }

class Dni extends FormzInput<String, DniError> {
  static final RegExp dniRegExp = RegExp(r'^\d{8}$');
  static final RegExp onlyNumbersRegExp = RegExp(r'^\d+$');

  const Dni.pure() : super.pure('');
  const Dni.dirty([String value = '']) : super.dirty(value);

  @override
  DniError? validator(String value) {
    if (value.isEmpty) return DniError.empty;
    if (!onlyNumbersRegExp.hasMatch(value)) return DniError.notNumeric;
    if (!dniRegExp.hasMatch(value)) return DniError.invalid;
    return null;
  }

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == DniError.empty) return 'El DNI es obligatorio';
    if (displayError == DniError.notNumeric) {
      return 'El DNI solo debe contener números';
    }
    if (displayError == DniError.invalid) {
      return 'El DNI debe tener exactamente 8 dígitos';
    }
    return null;
  }
}
