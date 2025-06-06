import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/domain/repositories/auth_repository.dart';
import 'package:comaslimpio/features/auth/presentation/components/register_form.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:formz/formz.dart';

class RegisterState {
  final Name name;
  final Email email;
  final Phone phone;
  final Password password;
  final LocationInput location;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;

  RegisterState({
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.phone = const Phone.pure(),
    this.password = const Password.pure(),
    this.location = const LocationInput.pure(),
    this.isValid = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    Name? name,
    Email? email,
    Phone? phone,
    Password? password,
    LocationInput? location,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      location: location ?? this.location,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  RegisterViewModel(this._authRepository, this._ref) : super(RegisterState());

  void onNameChanged(String value) {
    final name = Name.dirty(value);
    state = state.copyWith(
      name: name,
      isValid: Formz.validate([
        name,
        state.email,
        state.phone,
        state.password,
        state.location,
      ]),
    );
  }

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([
        state.name,
        email,
        state.phone,
        state.password,
        state.location,
      ]),
    );
  }

  void onPhoneChanged(String value) {
    final phone = Phone.dirty(value);
    state = state.copyWith(
      phone: phone,
      isValid: Formz.validate([
        state.name,
        state.email,
        phone,
        state.password,
        state.location,
      ]),
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isValid: Formz.validate([
        state.name,
        state.email,
        state.phone,
        password,
        state.location,
      ]),
    );
  }

  void onLocationChanged(Location? value) {
    final location = LocationInput.dirty(value);
    state = state.copyWith(
      location: location,
      isValid: Formz.validate([
        state.name,
        state.email,
        state.phone,
        state.password,
        location,
      ]),
    );
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    final mapLocationState = _ref.read(mapLocationProvider);
    if (mapLocationState.selectedLocation == null) {
      state = state.copyWith(errorMessage: 'Debes seleccionar una ubicación');
      return;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final appUser = AppUser(
        uid: '',
        name: state.name.value,
        email: state.email.value,
        phoneNumber: state.phone.value,
        role: 'citizen',
        location: mapLocationState.selectedLocation!,
        status: 'active',
        createdAt: Timestamp.now(),
        notificationPreferences: NotificationPreferences(
          daytimeAlerts: true,
          nighttimeAlerts: true,
          daytimeStart: '06:00',
          daytimeEnd: '20:00',
          nighttimeStart: '20:00',
          nighttimeEnd: '06:00',
        ),
      );

      await _authRepository.register(
        state.email.value,
        state.password.value,
        appUser,
      );
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }
}

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return RegisterViewModel(authRepository, ref);
    });
