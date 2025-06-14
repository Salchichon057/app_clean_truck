import 'package:comaslimpio/core/services/firestore_service.dart';
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
