import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mappers/notification_mapper.dart';

class NotificationFirebaseDatasource implements NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationFirebaseDatasource(this._firestoreService);

  @override
  Future<List<Notification>> getNotificationsForUser(String userId) async {
    final snapshot = await _firestoreService
        .collection('app_users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationMapper.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addNotification(String userId, Notification notification) async {
    await _firestoreService
        .collection('app_users')
        .doc(userId)
        .collection('notifications')
        .add(NotificationMapper.toJson(notification));
  }

  @override
  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    await _firestoreService
        .collection('app_users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }
}
