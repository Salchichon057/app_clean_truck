import '../models/incident.dart';

abstract class IncidentRepository {
  // Métodos Future
  Future<List<Incident>> getAllIncidents();
  Future<List<Incident>> getIncidentsByUser(String userId);
  Future<Incident?> getIncidentById(String id);
  Future<void> addIncident(Incident incident);
  Future<void> updateIncident(Incident incident);
  Future<void> deleteIncident(String id);

  // Métodos Stream
  Stream<List<Incident>> watchAllIncidents();
  Stream<List<Incident>> watchIncidentsByUser(String userId);
  Stream<List<Incident>> watchIncidentsByStatus(String status);
  Stream<Incident?> watchIncidentById(String id);
}
