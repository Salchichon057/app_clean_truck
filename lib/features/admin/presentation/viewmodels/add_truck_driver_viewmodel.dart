import 'package:comaslimpio/features/admin/presentation/providers/add_truck_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:comaslimpio/core/models/location.dart';

class AddTruckDriverViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AddTruckDriverViewModel(this.ref) : super(const AsyncValue.data(null));

  static final Location defaultLocation = Location(
    lat: -11.9498,
    long: -77.0622,
  );

  Future<void> submit() async {
    final form = ref.read(addTruckDriverFormProvider);
    if (!form.isValid) {
      ref
          .read(addTruckDriverFormProvider.notifier)
          .setError('Formulario inválido');
      return;
    }
    state = const AsyncValue.loading();
    ref.read(addTruckDriverFormProvider.notifier).setSubmitting(true);
    try {
      // Verifica si ya existe el usuario
      final existing = await FirebaseFirestore.instance
          .collection('app_users')
          .where('email', isEqualTo: form.email.value.trim())
          .get();
      if (existing.docs.isNotEmpty) {
        ref
            .read(addTruckDriverFormProvider.notifier)
            .setError('Ya existe un usuario con ese correo.');
        state = const AsyncValue.data(null);
        ref.read(addTruckDriverFormProvider.notifier).setSubmitting(false);
        return;
      }

      // Crea usuario en Firebase Auth
      final auth = FirebaseAuth.instance;
      final userCred = await auth.createUserWithEmailAndPassword(
        email: form.email.value.trim(),
        password: form.password.value.trim(),
      );
      final uid = userCred.user?.uid;
      if (uid == null) throw Exception('No se pudo crear el usuario');

      // Crea AppUser
      final appUser = AppUser(
        uid: uid,
        name: form.name.value.trim(),
        email: form.email.value.trim(),
        phoneNumber: form.phone.trim(),
        dni: form.dni.value.trim(),
        role: 'truck_driver',
        location: defaultLocation,
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

      await FirebaseFirestore.instance
          .collection('app_users')
          .doc(uid)
          .set(AppUserMapper.toJson(appUser));

      ref.read(addTruckDriverFormProvider.notifier).clear();
      state = const AsyncValue.data(null);
    } catch (e) {
      ref
          .read(addTruckDriverFormProvider.notifier)
          .setError('Error: ${e.toString()}');
      state = AsyncValue.error(e, StackTrace.current);
    }
    ref.read(addTruckDriverFormProvider.notifier).setSubmitting(false);
  }
}

final addTruckDriverViewModelProvider =
    StateNotifierProvider<AddTruckDriverViewModel, AsyncValue<void>>(
      (ref) => AddTruckDriverViewModel(ref),
    );
