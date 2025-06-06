import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mappers/notification_mapper.dart';

class NotificationFirebaseDatasource implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Notification>> getNotificationsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('app_users')
        .doc(userId)
        .collection('notifications')
        .get();
    return snapshot.docs
        .map((doc) => NotificationMapper.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addNotification(String userId, Notification notification) async {
    await _firestore
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
    await _firestore
        .collection('app_users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }
}
