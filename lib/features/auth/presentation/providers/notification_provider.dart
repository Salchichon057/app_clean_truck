import 'package:comaslimpio/features/auth/domain/models/notification.dart';
import 'package:comaslimpio/features/auth/presentation/viewmodels/notification_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import '../../infrastructure/datasources/notification_firebase_datasource.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return NotificationFirebaseDatasource(firestoreService);
});

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return NotificationViewModel(repo);
    });

// Provider para obtener notificaciones del usuario actual
final userNotificationsProvider = FutureProvider<List<Notification>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotificationsForUser(user.uid);
});

// Provider para contar notificaciones no leídas
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationViewModelProvider);
  return notificationState.unreadCount;
});
