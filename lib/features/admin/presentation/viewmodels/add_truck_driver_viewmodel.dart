import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/admin/presentation/providers/add_truck_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    final firestoreService = ref.read(firestoreServiceProvider);

    if (!form.isValid) {
      ref
          .read(addTruckDriverFormProvider.notifier)
          .setError('Formulario inválido');
      return;
    }
    state = const AsyncValue.loading();
    ref.read(addTruckDriverFormProvider.notifier).setSubmitting(true);
    try {
      // Usa FirestoreService para verificar si ya existe el usuario
      final existingStream = firestoreService.streamCollectionWhere(
        'app_users',
        'email',
        form.email.value.trim(),
      );
      final existingSnapshot = await existingStream.first;
      if (existingSnapshot.docs.isNotEmpty) {
        ref
            .read(addTruckDriverFormProvider.notifier)
            .setError('Ya existe un usuario con ese correo.');
        state = const AsyncValue.data(null);
        ref.read(addTruckDriverFormProvider.notifier).setSubmitting(false);
        return;
      }

      // Llama a la Cloud Function para crear el usuario
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createTruckDriver',
      );
      final result = await callable.call({
        'email': form.email.value.trim(),
        'password': form.password.value.trim(),
        'name': form.name.value.trim(),
        'dni': form.dni.value.trim(),
        'phoneNumber': form.phone.trim(),
      });

      print('Resultado función Cloud: ${result.data}');
      ref.read(addTruckDriverFormProvider.notifier).clear();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('Error al crear usuario: $e');
      print('StackTrace: $st');
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
