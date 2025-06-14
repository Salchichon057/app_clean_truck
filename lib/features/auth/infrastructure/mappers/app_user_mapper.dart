import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'notification_preferences_mapper.dart';

class AppUserMapper {
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      location: Location.fromJson(json['location']),
      status: json['status'],
      createdAt: (json['created_at'] as Timestamp),
      notificationPreferences: NotificationPreferencesMapper.fromJson(
        json['notification_preferences'],
      ),
      dni: json['dni']
    );
  }

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'role': user.role,
      'location': user.location.toJson(),
      'status': user.status,
      'created_at': user.createdAt,
      'notification_preferences': NotificationPreferencesMapper.toJson(
        user.notificationPreferences,
      ),
      'dni': user.dni
    };
  }
}
