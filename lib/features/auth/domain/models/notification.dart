import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String uid;
  final String type;
  final String message;
  final Timestamp timestamp;
  final bool read;

  Notification({
    required this.uid,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  Notification copyWith({
    String? uid,
    String? type,
    String? message,
    Timestamp? timestamp,
    bool? read,
  }) {
    return Notification(
      uid: uid ?? this.uid,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }
}
