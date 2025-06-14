import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/incident_provider.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';

final userIncidentsProvider = StreamProvider<List<Incident>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final incidentRepo = ref.watch(incidentRepositoryProvider);
  return incidentRepo.watchIncidentsByUser(user.uid);
});
