import '../models/notification.dart';

abstract class NotificationRepository {
  // Métodos Future
  Future<List<Notification>> getNotificationsForUser(String userId);
  Future<void> addNotification(String userId, Notification notification);
  Future<void> markNotificationAsRead(String userId, String notificationId);
  Future<void> deleteNotification(String userId, String notificationId);
  Future<void> deleteAllNotifications(String userId);

  // Métodos Stream
  Stream<List<Notification>> watchNotificationsForUser(String userId);
  Stream<List<Notification>> watchUnreadNotificationsForUser(String userId);
}
