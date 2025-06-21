import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/incident_provider.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';

final incidentsByDateProvider = StreamProvider<List<Incident>>((ref) {
  final repo = ref.watch(incidentRepositoryProvider);
  return repo.watchAllIncidents().map((incidents) {
    final sorted = [...incidents];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  });
});
