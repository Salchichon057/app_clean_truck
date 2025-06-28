// ignore_for_file: use_build_context_synchronously

import 'package:comaslimpio/core/inputs/email.dart';
import 'package:comaslimpio/core/inputs/password.dart';
import 'package:comaslimpio/core/services/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
  }) {
    return LoginFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final AuthNotifier authNotifier;

  LoginFormNotifier({required this.authNotifier}) : super(LoginFormState());

  void onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(email: newEmail, isValid: newEmail.isValid);
  }

  void onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([state.email, newPassword]),
    );
  }

  Future<bool> onFormSubmit() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isValid: email.isValid,
    );

    if (!state.isValid) return false;

    state = state.copyWith(isPosting: true);

    try {
      await authNotifier.signIn(email.value, password.value);

      await Future.delayed(const Duration(milliseconds: 500));

      final user = authNotifier.state.appUser;
      if (user != null) {
        await FcmService.instance.saveTokenToFirestore(user.uid);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }
}

final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      final authNotifier = ref.read(authProvider.notifier);
      return LoginFormNotifier(authNotifier: authNotifier);
    });
