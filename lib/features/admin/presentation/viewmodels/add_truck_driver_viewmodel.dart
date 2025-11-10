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
    final formNotifier = ref.read(addTruckDriverFormProvider.notifier);
    
    // Marcar todos los campos como "dirty" para mostrar errores
    formNotifier.validateAllFields();
    
    final form = ref.read(addTruckDriverFormProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    if (!form.isValid) {
      formNotifier.setError('Formulario inválido. Complete los campos obligatorios');
      return;
    }
    
    state = const AsyncValue.loading();
    formNotifier.setSubmitting(true);
    
    try {
      // Usa FirestoreService para verificar si ya existe el usuario
      final existingStream = firestoreService.streamCollectionWhere(
        'app_users',
        'email',
        form.email.value.trim(),
      );
      final existingSnapshot = await existingStream.first;
      
      if (existingSnapshot.docs.isNotEmpty) {
        formNotifier.setError('Ya existe un usuario con ese correo.');
        state = const AsyncValue.data(null);
        formNotifier.setSubmitting(false);
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
        'phoneNumber': form.phone.value.trim(),
      });

      print('Conductor creado exitosamente: ${result.data}');
      
      // Solo limpiar formulario si fue exitoso
      formNotifier.clear();
      state = const AsyncValue.data(null);
      
    } catch (e, st) {
      print('Error al crear conductor: $e');
      print('StackTrace: $st');
      
      // Mensaje de error más amigable
      String errorMessage = 'Error al crear el conductor';
      if (e.toString().contains('email')) {
        errorMessage = 'El correo electrónico ya está en uso';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      }
      
      formNotifier.setError(errorMessage);
      state = AsyncValue.error(e, st);
    } finally {
      formNotifier.setSubmitting(false);
    }
  }
}

final addTruckDriverViewModelProvider =
    StateNotifierProvider<AddTruckDriverViewModel, AsyncValue<void>>(
      (ref) => AddTruckDriverViewModel(ref),
    );
