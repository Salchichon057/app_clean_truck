import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification.dart';

class NotificationMapper {
  static Notification fromJson(Map<String, dynamic> json) {
    return Notification(
      uid: json['uid'],
      type: json['type'],
      message: json['message'],
      timestamp: json['timestamp'] as Timestamp,
      read: json['read'] ?? false,
    );
  }

  static Map<String, dynamic> toJson(Notification notification) {
    return {
      'uid': notification.uid,
      'type': notification.type,
      'message': notification.message,
      'timestamp': notification.timestamp,
      'read': notification.read,
    };
  }
}
