import 'package:comaslimpio/features/citizen/domain/models/incident.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/incident_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/report_incident_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/domain/repositories/incident_repository.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportIncidentViewModel extends StateNotifier<AsyncValue<void>> {
  final IncidentRepository _incidentRepository;
  final Ref _ref;

  ReportIncidentViewModel(this._incidentRepository, this._ref)
    : super(const AsyncValue.data(null));

  Future<bool> submit() async {
    final formState = _ref.read(reportIncidentFormProvider);

    if (!formState.isValid || formState.incidentLocation == null) {
      _ref
          .read(reportIncidentFormProvider.notifier)
          .setError('Formulario inválido');
      return false;
    }

    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no encontrado');

      final incident = Incident(
        uid: FirebaseFirestore.instance.collection('incidents').doc().id,
        idAppUsers: user.uid,
        description: formState.description.value,
        location: formState.incidentLocation!,
        status: 'pending',
        date: Timestamp.now(),
      );

      await _incidentRepository.addIncident(incident);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(reportIncidentFormProvider.notifier).setError(e.toString());
      return false;
    }
  }
}

final reportIncidentViewModelProvider =
    StateNotifierProvider.autoDispose<
      ReportIncidentViewModel,
      AsyncValue<void>
    >((ref) {
      final incidentRepository = ref.watch(incidentRepositoryProvider);
      return ReportIncidentViewModel(incidentRepository, ref);
    });
