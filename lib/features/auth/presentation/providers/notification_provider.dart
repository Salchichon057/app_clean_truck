import 'package:comaslimpio/features/auth/domain/models/notification.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/auth/presentation/viewmodels/notification_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/services/firestore_service.dart';
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

// Stream Providers
final notificationsStreamProvider = StreamProvider<List<Notification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotificationsForUser(user.uid);
});

final unreadNotificationsStreamProvider =
    StreamProvider.family<List<Notification>, String>((ref, userId) {
      final repo = ref.watch(notificationRepositoryProvider);
      return repo.watchUnreadNotificationsForUser(userId);
    });

final unreadNotificationsCountProvider = StreamProvider.family<int, String>((
  ref,
  userId,
) {
  final unreadNotifications = ref.watch(
    unreadNotificationsStreamProvider(userId),
  );
  return unreadNotifications.when(
    data: (notifications) => Stream.value(notifications.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});
