import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/incident.dart';
import '../../domain/repositories/incident_repository.dart';
import '../mappers/incident_mapper.dart';

class IncidentFirebaseDatasource implements IncidentRepository {
  final FirestoreService _firestoreService;

  IncidentFirebaseDatasource(this._firestoreService);

  // Métodos Future
  @override
  Future<List<Incident>> getAllIncidents() async {
    final docs = await _firestoreService.getDocuments('incidents');
    return docs
        .map(
          (doc) => IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<Incident>> getIncidentsByUser(String userId) async {
    final snapshot = await _firestoreService
        .collection('incidents')
        .where('id_users', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map(
          (doc) => IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<Incident?> getIncidentById(String id) async {
    final doc = await _firestoreService.getDocument('incidents', id);
    if (!doc.exists) return null;
    return IncidentMapper.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addIncident(Incident incident) async {
    await _firestoreService.setDocument(
      'incidents',
      incident.uid,
      IncidentMapper.toJson(incident),
    );
  }

  @override
  Future<void> updateIncident(Incident incident) async {
    await _firestoreService.updateDocument(
      'incidents',
      incident.uid,
      IncidentMapper.toJson(incident),
    );
  }

  @override
  Future<void> deleteIncident(String id) async {
    await _firestoreService.collection('incidents').doc(id).delete();
  }

  // Métodos Stream
  @override
  Stream<List<Incident>> watchAllIncidents() {
    return _firestoreService
        .streamCollection('incidents')
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Incident>> watchIncidentsByUser(String userId) {
    return _firestoreService
        .streamCollectionWhere('incidents', 'id_users', userId)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Incident>> watchIncidentsByStatus(String status) {
    return _firestoreService
        .streamCollectionWhere('incidents', 'status', status)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<Incident?> watchIncidentById(String id) {
    return _firestoreService
        .streamDocument('incidents', id)
        .map(
          (doc) => doc.exists
              ? IncidentMapper.fromJson(doc.data() as Map<String, dynamic>)
              : null,
        );
  }
}
