import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String dni;
  final String role;
  final Location location;
  final String status;
  final Timestamp createdAt;
  final NotificationPreferences notificationPreferences;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dni,
    required this.role,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.notificationPreferences,
  });

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? dni,
    String? role,
    Location? location,
    String? status,
    Timestamp? createdAt,
    NotificationPreferences? notificationPreferences,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dni: dni ?? this.dni,
      role: role ?? this.role,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}
