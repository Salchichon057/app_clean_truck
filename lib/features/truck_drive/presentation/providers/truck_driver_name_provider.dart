import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/services/firestore_service.dart';

final truckDriverNameProvider = FutureProvider.family<String?, String?>((
  ref,
  idAppUser,
) async {
  if (idAppUser == null) return null;
  final firestoreService = ref.watch(firestoreServiceProvider);
  final doc = await firestoreService.getDocument('app_users', idAppUser);
  if (!doc.exists) return null;
  final data = doc.data() as Map<String, dynamic>?;
  return data?['name'] as String?;
});
