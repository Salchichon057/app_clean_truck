import 'package:comaslimpio/core/inputs/full_name.dart';
import 'package:comaslimpio/core/inputs/dni.dart';
import 'package:comaslimpio/core/presentation/router/app_router_notifier.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';

class EditProfileFormState {
  final FullName name;
  final Dni dni;
  final String phone;
  final Location? location;
  final String? address;
  final NotificationPreferences notificationPreferences;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;

  EditProfileFormState({
    this.name = const FullName.pure(),
    this.dni = const Dni.pure(),
    this.phone = '',
    this.location,
    this.address,
    required this.notificationPreferences,
    this.isValid = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  EditProfileFormState copyWith({
    FullName? name,
    Dni? dni,
    String? phone,
    Location? location,
    String? address,
    NotificationPreferences? notificationPreferences,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return EditProfileFormState(
      name: name ?? this.name,
      dni: dni ?? this.dni,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      address: address ?? this.address,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  // PARA DEBUGGING
  @override
  String toString() {
    return 'EditProfileFormState(name: $name, dni: $dni, phone: $phone, location: $location, address: $address, notificationPreferences: $notificationPreferences, isValid: $isValid, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
  }
}

class EditProfileFormNotifier extends StateNotifier<EditProfileFormState> {
  EditProfileFormNotifier(super.initialState) {
    print('EditProfileFormNotifier initialized with state: $state');
  }

  void updateName(String value) {
    final name = FullName.dirty(value);
    state = state.copyWith(
      name: name,
      isValid: _isFormValid(name: name),
    );
    print('Updated name: $value, isValid: ${state.isValid}');
  }

  void updateDni(String value) {
    final dni = Dni.dirty(value);
    state = state.copyWith(
      dni: dni,
      isValid: _isFormValid(dni: dni),
    );
    print('Updated DNI: $value, isValid: ${state.isValid}');
  }

  void updatePhone(String value) {
    state = state.copyWith(
      phone: value,
      isValid: _isFormValid(phone: value),
    );
    print('Updated phone: $value, isValid: ${state.isValid}');
  }

  void updateLocation(Location location) {
    state = state.copyWith(
      location: location,
      isValid: _isFormValid(location: location),
    );
    print('Updated location: $location, isValid: ${state.isValid}');
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
    print('updateAddress called with address: $address, new state: $state');
  }

  void updateNotificationPreferences(NotificationPreferences prefs) {
    state = state.copyWith(
      notificationPreferences: prefs,
      isValid: _isFormValid(notificationPreferences: prefs),
    );
    print(
      'updateNotificationPreferences called with prefs: $prefs, new state: $state',
    );
  }

  bool _isFormValid({
    FullName? name,
    Dni? dni,
    String? phone,
    Location? location,
    NotificationPreferences? notificationPreferences,
  }) {
    final n = name ?? state.name;
    final d = dni ?? state.dni;
    final p = phone ?? state.phone;
    final l = location ?? state.location;
    return n.isValid && d.isValid && p.isNotEmpty && l != null;
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
    print('setError called with error: $error, new state: $state');
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
    print(
      'setSubmitting called with submitting: $submitting, new state: $state',
    );
  }
}

final editProfileFormProvider =
    StateNotifierProvider.autoDispose<
      EditProfileFormNotifier,
      EditProfileFormState
    >((ref) {
      final authState = ref.watch(authProvider);

      if (authState.authStatus != AuthStatus.authenticated ||
          authState.appUser == null) {
        return EditProfileFormNotifier(
          EditProfileFormState(
            notificationPreferences: NotificationPreferences(
              daytimeAlerts: true,
              nighttimeAlerts: true,
              daytimeStart: '06:00',
              daytimeEnd: '20:00',
              nighttimeStart: '20:00',
              nighttimeEnd: '06:00',
            ),
          ),
        );
      }

      final user = authState.appUser!;
      print(
        'User authenticated, creating EditProfileFormNotifier with user data: $user',
      );
      return EditProfileFormNotifier(
        EditProfileFormState(
          name: FullName.dirty(user.name),
          dni: Dni.dirty(user.dni),
          phone: user.phoneNumber,
          location: user.location,
          address: null, // Se cargará asíncronamente
          notificationPreferences: user.notificationPreferences,
        ),
      );
    });
