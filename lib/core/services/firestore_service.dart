import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  static final FirestoreService instance = FirestoreService(
    FirebaseFirestore.instance,
  );

  void configureSettings({
    bool persistenceEnabled = false,
    int cacheSizeBytes = Settings.CACHE_SIZE_UNLIMITED,
  }) {
    _firestore.settings = Settings(
      persistenceEnabled: persistenceEnabled,
      cacheSizeBytes: cacheSizeBytes,
    );
  }

  CollectionReference collection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  Future<DocumentSnapshot> getDocument(
    String collectionPath,
    String documentId,
  ) async {
    return await _firestore.collection(collectionPath).doc(documentId).get();
  }

  Future<void> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).add(data);
  }

  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).doc(documentId).set(data);
  }

  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  Future<List<QueryDocumentSnapshot>> getDocuments(
    String collectionPath,
  ) async {
    final snapshot = await _firestore.collection(collectionPath).get();
    return snapshot.docs;
  }

  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  Stream<QuerySnapshot> streamCollectionWhere(
    String collectionPath,
    String field,
    dynamic value,
  ) {
    return _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .snapshots();
  }

  Stream<DocumentSnapshot> streamDocument(
    String collectionPath,
    String documentId,
  ) {
    return _firestore.collection(collectionPath).doc(documentId).snapshots();
  }
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreService(firestore);
});
