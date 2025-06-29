import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String uid;
  final String type;
  final String message;
  final String? routeId;
  final Timestamp timestamp;
  final bool read;

  Notification({
    required this.uid,
    required this.type,
    required this.message,
    this.routeId,
    required this.timestamp,
    required this.read,
  });

  Notification copyWith({
    String? uid,
    String? type,
    String? message,
    String? routeId,
    Timestamp? timestamp,
    bool? read,
  }) {
    return Notification(
      uid: uid ?? this.uid,
      type: type ?? this.type,
      message: message ?? this.message,
      routeId: routeId ?? this.routeId,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }
}
