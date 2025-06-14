import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';
import 'package:comaslimpio/features/citizen/presentation/viewmodels/incident_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/datasources/incident_firebase_datasource.dart';
import '../../domain/repositories/incident_repository.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return IncidentFirebaseDatasource(firestoreService);
});

final incidentViewModelProvider =
    StateNotifierProvider<IncidentViewModel, IncidentState>((ref) {
      final repo = ref.watch(incidentRepositoryProvider);
      return IncidentViewModel(repo);
    });

// Stream Providers
final incidentsStreamProvider = StreamProvider<List<Incident>>((ref) {
  final repo = ref.watch(incidentRepositoryProvider);
  return repo.watchAllIncidents();
});

final incidentsByUserStreamProvider =
    StreamProvider.family<List<Incident>, String>((ref, userId) {
      final repo = ref.watch(incidentRepositoryProvider);
      return repo.watchIncidentsByUser(userId);
    });

final pendingIncidentsStreamProvider = StreamProvider<List<Incident>>((ref) {
  final repo = ref.watch(incidentRepositoryProvider);
  return repo.watchIncidentsByStatus('pending');
});

final incidentByIdStreamProvider = StreamProvider.family<Incident?, String>((
  ref,
  id,
) {
  final repo = ref.watch(incidentRepositoryProvider);
  return repo.watchIncidentById(id);
});
