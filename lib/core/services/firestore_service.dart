import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // Instancia singleton para acceso global
  static final FirestoreService instance = FirestoreService(
    FirebaseFirestore.instance,
  );

  // Método para configurar las configuraciones de Firestore
  void configureSettings({
    bool persistenceEnabled = false,
    int cacheSizeBytes = Settings.CACHE_SIZE_UNLIMITED,
  }) {
    _firestore.settings = Settings(
      persistenceEnabled: persistenceEnabled,
      cacheSizeBytes: cacheSizeBytes,
    );
  }

  // Método para obtener una referencia a una colección
  CollectionReference collection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  // Método para obtener un documento
  Future<DocumentSnapshot> getDocument(
    String collectionPath,
    String documentId,
  ) async {
    return await _firestore.collection(collectionPath).doc(documentId).get();
  }

  // Método para agregar un documento
  Future<void> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).add(data);
  }

  // Método para establecer un documento
  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).doc(documentId).set(data);
  }

  // Método para actualizar un documento
  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  // Método para obtener una lista de documentos (query)
  Future<List<QueryDocumentSnapshot>> getDocuments(
    String collectionPath, {
    List<String>? whereConditions,
  }) async {
    Query query = _firestore.collection(collectionPath);
    if (whereConditions != null && whereConditions.isNotEmpty) {
      for (var condition in whereConditions) {
        query = query.where(condition);
      }
    }
    final snapshot = await query.get();
    return snapshot.docs;
  }

  // Método para escuchar cambios en tiempo real (stream)
  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }
}
