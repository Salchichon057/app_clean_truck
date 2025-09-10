import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification.dart';

class NotificationMapper {
  static Notification fromJson(Map<String, dynamic> json) {
    return Notification(
      uid: json['uid'],
      type: json['type'],
      message: json['message'],
      routeId: json['routeId'],
      timestamp: json['timestamp'] as Timestamp,
      read: json['read'] ?? false,
    );
  }

  static Notification fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Notification(
      uid: doc.id, // Usar el ID del documento de Firestore
      type: data['type'],
      message: data['message'],
      routeId: data['routeId'],
      timestamp: data['timestamp'] as Timestamp,
      read: data['read'] ?? false,
    );
  }

  static Map<String, dynamic> toJson(Notification notification) {
    return {
      'uid': notification.uid,
      'type': notification.type,
      'message': notification.message,
      'routeId': notification.routeId,
      'timestamp': notification.timestamp,
      'read': notification.read,
    };
  }
}
