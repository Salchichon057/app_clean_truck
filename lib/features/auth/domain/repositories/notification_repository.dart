import 'package:comaslimpio/features/auth/domain/models/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotificationsForUser(String userId);
  Future<void> addNotification(String userId, Notification notification);
  Future<void> markNotificationAsRead(String userId, String notificationId);
}
