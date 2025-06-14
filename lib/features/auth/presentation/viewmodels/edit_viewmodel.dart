import 'package:comaslimpio/features/auth/presentation/providers/edit_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

class EditProfileViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  EditProfileViewModel(this._authRepository, this._ref)
    : super(const AsyncValue.data(null));

  Future<bool> submit() async {
    final formState = _ref.read(editProfileFormProvider);
    print('submit called, formState: $formState');

    if (!formState.isValid || formState.location == null) {
      String error;
      if (formState.location == null) {
        error = 'Debes seleccionar una ubicación';
      } else if (formState.phone.isEmpty) {
        error = 'Debes ingresar un teléfono';
      } else {
        error = 'Formulario inválido';
      }
      print('Form is invalid, setting error: $error');
      _ref.read(editProfileFormProvider.notifier).setError(error);
      return false;
    }

    state = const AsyncValue.loading();
    print('Setting state to loading');
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no encontrado');

      final updatedUser = user.copyWith(
        name: formState.name.value,
        dni: formState.dni.value,
        phoneNumber: formState.phone,
        location: formState.location,
        notificationPreferences: formState.notificationPreferences,
      );

      print('Updating user profile with data: $updatedUser');
      await _authRepository.updateUserProfile(updatedUser);
      print('User profile updated successfully');
      await _ref.read(authProvider.notifier).fetchUserData();
      print('User data fetched successfully');

      state = const AsyncValue.data(null);
      print('Setting state to data(null)');
      return true;
    } catch (e) {
      print('An error occurred: $e');
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(editProfileFormProvider.notifier).setError(e.toString());
      return false;
    }
  }
}

final editProfileViewModelProvider =
    StateNotifierProvider.autoDispose<EditProfileViewModel, AsyncValue<void>>((
      ref,
    ) {
      final authRepository = ref.watch(authRepositoryProvider);
      return EditProfileViewModel(authRepository, ref);
    });
