import 'package:comaslimpio/features/citizen/domain/models/incident.dart';

abstract class IncidentRepository {
  Future<List<Incident>> getAllIncidents();
  Future<List<Incident>> getIncidentsByUser(String userId);
  Future<Incident?> getIncidentById(String id);
  Future<void> addIncident(Incident incident);
  Future<void> updateIncident(Incident incident);
  Future<void> deleteIncident(String id);
}
